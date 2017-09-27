/*
 *  DJBConfig.c
 *  SRNOldies
 *
 *  Created by Sungjin Kim on 8/23/10.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

#include "DJBConfig.h"

// GLOBAL IPHONE APP PATH
char				g_iphoneAppDirectory[1024];
char				g_iphoneDocDirectory[1024];

// DJB APP CONFIG DATA
DJBConfigInfo		g_config;
char				g_szConfigName[64];

// BASIC IO
unsigned char *
LoadDataFile(char * pFileName, int* pSize, char *pBuffer)
{
	int fd;
	char * pData;
	
	if ( (fd=open( pFileName, O_CREAT|O_RDONLY,S_IRWXU)) < 0 ) {
		//printf("LoadDataFile error %s [%s]\n", pFileName, strerror(errno));
		return NULL;
	} else if (pBuffer == NULL) {
		*pSize = lseek(fd, 0, SEEK_END);
		lseek(fd, 0, SEEK_SET);
		
		if ((pData = (char*)malloc(*pSize)) == NULL) {
			//printf("LoadDataFile malloc error\n");
			goto ERROR_LOADFILE;
		}
	} else {
		pData = pBuffer;
	}
	
	if( *pSize != read(fd, pData, *pSize) ) {
		if (pBuffer==NULL && pData != NULL) 
			free(pData);
		pData = NULL;
	}
	
ERROR_LOADFILE:	
	close(fd);
	return (unsigned char *)pData;
}

int	 
SaveDataFile(char * pFileName, char * pData, int size)
{
	int fd;
	
	if ( (fd=open( pFileName, O_CREAT|O_WRONLY|O_TRUNC)) < 0 ) {
		//printf("SaveDataFile error %s[%s] %d = %d\n", pFileName, strerror(errno), errno, EACCES);
		return 0;
	}
	
	// write data
	if( size != write(fd, (char *)pData, size) ) {
		//printf("SaveDataFile write error\n");
		close(fd);
		return 0;
	}
	
	close(fd);
	
	return size;	
}

// DJB CONFIG MANAGEMENT
bool	 			
LoadDJBData()
{
	int size = sizeof(DJBConfigInfo);
	char fileName[1024];
	sprintf(fileName,"%s/%s",g_iphoneDocDirectory, g_szConfigName);
	
	// if failed, simple use the default values which are already defined in Initialize
	if( LoadDataFile(fileName, &size, (char *)&g_config) != NULL ) {
		return true;
	}
	
	return false;
}

void				
SaveDJBData()
{
	char fileName[1024];
	sprintf(fileName,"%s/%s",g_iphoneDocDirectory, g_szConfigName);
	
	//printf(fileName);
	
	// if failed, simple use the default values which are already defined in Initialize
	SaveDataFile(fileName, (char *)&g_config, sizeof(DJBConfigInfo));
}

void				
InitDJBConfig(char * pConfigName)
{
	strcpy(g_szConfigName, pConfigName);
	
	if (!LoadDJBData()) {
		g_config.m_ver = 1.0;
        strcpy(g_config.m_stationName, (char *)"www.sunshineradionetwork.com/play/listen.pls");//"WebSiteName1");
	}
}

void		
SetStation(char * pStationName)
{
	strcpy(g_config.m_stationName, pStationName);
}

char *
GetStation()
{
	return g_config.m_stationName;
}

void		
SetBackGndEnabled(int enabled)
{
	g_config.m_backGndRunEnabled = enabled;
}

int		
GetBackGndEnabled()
{
	return g_config.m_backGndRunEnabled;
}

