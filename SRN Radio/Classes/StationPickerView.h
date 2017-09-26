//
//  StationPickerView.h
//  srn
//
//  Created by Sungjin Kim on 9/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#define DEFAULT_STATION_WIDTH		280
#define DEFAULT_STATION_HEIGHT		250

@protocol StationPickerViewDataSource;

@interface StationPickerView : UIScrollView {
    id <StationPickerViewDataSource>	dataSource;
    CGSize								stationSize;
    UIView								*stationContainerView;
    NSMutableSet						*reusableStations;    
    
	// station controls
	unsigned long									m_maxStation;  // 64 bit update
	int									m_curStation;
	int									m_prevStation;
	NSTimer *							m_pStationSelTimer;
	
    // we use the following ivars to keep track of which rows and columns are visible
    int firstVisibleRow, firstVisibleColumn, lastVisibleRow, lastVisibleColumn;
}

@property (nonatomic, assign) id <StationPickerViewDataSource> dataSource;
@property (nonatomic, assign) CGSize stationSize;
@property (nonatomic, readonly) UIView *stationContainerView;

- (UIView *)dequeueReusableStation;  // Used by the delegate to acquire an already allocated station, in lieu of allocating a new one.
- (void)reloadData;
- (void)reloadDataWithNewContentSize:(CGSize)size;
- (void)setMaxStation:(unsigned long )numStations; //64 bit update
- (unsigned long )getMaxStation; //64 bit update
- (void)setStation:(int)curStation;
- (void)setCurStation:(int)curStation;
- (int)getCurStation;

- (void)scrollTimerFired:(NSTimer *)timer;

@end

@protocol StationPickerViewDataSource <NSObject>

- (UIView *)stationPickerView:(StationPickerView *)scrollView row:(int)row column:(int)column;
- (void)stationPickerView:(int)selStation;

@end


