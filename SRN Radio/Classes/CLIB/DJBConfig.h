/*
 *  BJDConfig.h
 *  SRNOldies
 *
 *  Created by Sungjin Kim on 8/23/10.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef DJBCONFIG_H
#define DJBCONFIG_H

#include <CoreFoundation/CoreFoundation.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <sys/mman.h>

typedef struct  _DJBConfigInfo {
	float		m_ver;
	int			m_backGndRunEnabled;
	char		m_stationName[128];
} DJBConfigInfo;

// GLOBAL VARIABLEs
extern char		g_iphoneAppDirectory[1024];
extern char		g_iphoneDocDirectory[1024];

// PUBLIC FUNCTIONs
extern void		InitDJBConfig(char * pConfigName);
extern bool		LoadDJBData(void);
extern void		SaveDJBData(void);
extern void		SetStation(char * pStationName);
extern char *	GetStation(void);
extern void		SetBackGndEnabled(int enabled);
extern int		GetBackGndEnabled(void);

#endif
