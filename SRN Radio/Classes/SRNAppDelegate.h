

#import <UIKit/UIKit.h>
@class MyViewController;


@interface SRNAppDelegate : NSObject <UIApplicationDelegate> {
	
    UIWindow                 *window;
	MyViewController         *ViewController;
}

@property (nonatomic, retain) IBOutlet UIWindow             *window;
@property (nonatomic, retain) MyViewController             *ViewController;

@end

