//
//  StationPickerView.m
//  srn
//
//  Created by Sungjin Kim on 9/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "StationPickerView.h"

@implementation StationPickerView
@synthesize stationSize;
@synthesize stationContainerView;
@synthesize dataSource;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        // we will recycle stations by removing them from the view and storing them here
        reusableStations = [[NSMutableSet alloc] init];
        
        // we need a tile container view to hold all the stations. This is the view that is returned
        // in the -viewForZoomingInScrollView: delegate method, and it also detects taps.
        stationContainerView = [[UIView alloc] initWithFrame:CGRectZero];
        //[stationContainerView setBackgroundColor:[UIColor redColor]];
		[stationContainerView setBackgroundColor:[[[UIColor alloc] initWithWhite:1.0 alpha:0.0] autorelease]];
        [self addSubview:stationContainerView];
        [self setStationSize:CGSizeMake(DEFAULT_STATION_WIDTH, DEFAULT_STATION_HEIGHT)];
		
        // no rows or columns are visible at first; note this by making the firsts very high and the lasts very low
		firstVisibleRow = firstVisibleColumn = NSIntegerMax;
		lastVisibleRow  = lastVisibleColumn  = NSIntegerMin;
		
		// create timer
		m_pStationSelTimer = [NSTimer scheduledTimerWithTimeInterval:(1.0)
                                                           target:self 
                                                         selector:@selector(scrollTimerFired:) 
															userInfo:nil
                                                          repeats:YES];
    }
	
    return self;
}

- (void)dealloc {
	if (m_pStationSelTimer) {
		[m_pStationSelTimer invalidate];
		m_pStationSelTimer = nil;
	}
    [reusableStations release];
    [stationContainerView release];
    [super dealloc];
}

- (void)setMaxStation:(int)numStations
{
	m_maxStation = numStations;
}

- (int)getMaxStation
{
	return m_maxStation;
}

- (void)setStation:(int)curStation
{
	m_prevStation = m_curStation = curStation;
	
	[self setContentOffset:CGPointMake(curStation*DEFAULT_STATION_WIDTH, 0.0)];
}

- (void)setCurStation:(int)curStation
{
	m_curStation = curStation;
}

- (int)getCurStation
{
	return m_curStation;
}

- (void) scrollTimerFired:(NSTimer *)timer
{
	if (m_curStation != m_prevStation)
		[dataSource stationPickerView:(m_prevStation = m_curStation)];
}

- (UIView *)dequeueReusableStation {
    UIView *station = [reusableStations anyObject];
	
	//printf("removed station=%x\n", (unsigned int)station);
	
    if (station) {
        // the only object retaining the station is our reusableStations set, so we have to retain/autorelease it
        // before returning it so that it's not immediately deallocated when we remove it from the set
        [[station retain] autorelease];
        [reusableStations removeObject:station];
    }
    return station;
}

- (void)reloadData {
    // recycle all tiles so that every station will be replaced in the next layoutSubviews
    for (UIView *view in [stationContainerView subviews]) {
        [reusableStations addObject:view];
        [view removeFromSuperview];
    }
    
    // no rows or columns are now visible; note this by making the firsts very high and the lasts very low
    firstVisibleRow = firstVisibleColumn = NSIntegerMax;
    lastVisibleRow  = lastVisibleColumn  = NSIntegerMin;
    
    [self setNeedsLayout];
}

- (void)reloadDataWithNewContentSize:(CGSize)size {
    // now that we've reset our zoom scale and resolution, we can safely set our contentSize. 
    [self setContentSize:size];
    
    // we also need to change the frame of the tileContainerView so its size matches the contentSize
    [stationContainerView setFrame:CGRectMake(0, 0, size.width, size.height)];
    
    [self reloadData];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect visibleBounds = [self bounds];
	
    // calculate which rows and columns are visible by doing a bunch of math.
    float scaledStationWidth  = [self stationSize].width;	// scaling 1.0
    int maxCol = MIN(floorf([stationContainerView frame].size.width  / scaledStationWidth), m_maxStation-1);  // and the maximum possible column
    int firstNeededRow = 0;
    int lastNeededRow  = 0;
    int firstNeededCol = MAX(0, floorf(visibleBounds.origin.x / scaledStationWidth));
    int lastNeededCol  = MIN(maxCol, floorf(CGRectGetMaxX(visibleBounds) / scaledStationWidth));
	
	//printf("[verify station remove]\n");
	
    // first recycle all stations that are no longer visible
    for (UIView *station in [stationContainerView subviews]) {
        
        // We want to see if the stations intersect our (i.e. the scrollView's) bounds, so we need to convert their
        // frames to our own coordinate system
        CGRect scaledStationFrame = [stationContainerView convertRect:[station frame] toView:self];
		
        // If the tile doesn't intersect, it's not visible, so we can recycle it
        if (! CGRectIntersectsRect(scaledStationFrame, visibleBounds)) {

			// Even though scaledStationFrame is out of visible bound, if it is still in the needed bound by computation, don't remove it
			int removedCol = floorf(visibleBounds.origin.x / [self stationSize].width);
			
			if (firstNeededCol > removedCol || removedCol > lastNeededCol) {
#if 0			
				// adjust visible column
				if (firstVisibleColumn == removedCol)
					firstVisibleColumn++;
				if (lastVisibleColumn == removedCol)
					lastVisibleColumn--;
#endif			
				
				//printf("removed x=%f width=%f : x=%f width=%f\n", scaledStationFrame.origin.x, scaledStationFrame.size.width, visibleBounds.origin.x, visibleBounds.size.width);
				
				[reusableStations addObject:station];
				[station removeFromSuperview];
			}
        }
    }
    	
	//printf("[verify missing station x=%f maxX=%f] needed from %d to %d = visible from %d to %d]\n", visibleBounds.origin.x, CGRectGetMaxX(visibleBounds), firstNeededCol, lastNeededCol, firstVisibleColumn, lastVisibleColumn);
	
    // iterate through needed rows and columns, adding any stations that are missing
    for (int row = firstNeededRow; row <= lastNeededRow; row++) {
        for (int col = firstNeededCol; col <= lastNeededCol; col++) {
			
            BOOL stationIsMissing = (firstVisibleRow > row || firstVisibleColumn > col || 
									 lastVisibleRow  < row || lastVisibleColumn  < col);
            
            if (stationIsMissing) {
                UIView *station = [dataSource stationPickerView:self row:row column:col];
								
                // set the station's frame so we insert it at the correct position
                CGRect frame = CGRectMake([self stationSize].width * col, [self stationSize].height * row, [self stationSize].width, [self stationSize].height);
                [station setFrame:frame];
                [stationContainerView addSubview:station];
				
				//printf("missing station %d]=%x\n", col,  (unsigned int)station);
				//printf("missing station %d]=%f %f\n", col,  frame.origin.x, frame.origin.y);
            }
        }
    }
    
    // update our record of which rows/cols are visible
    firstVisibleRow = firstNeededRow; firstVisibleColumn = firstNeededCol;
    lastVisibleRow  = lastNeededRow;  lastVisibleColumn  = lastNeededCol;   
	
	// set station
	[self setCurStation:(int)(visibleBounds.origin.x / scaledStationWidth)];
}

#pragma mark UIScrollView overrides

// We override the setDelegate: method because we can't manage resolution changes unless we are our own delegate.
- (void)setDelegate:(id)delegate {
}

@end
