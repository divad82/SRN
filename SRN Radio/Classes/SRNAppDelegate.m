
/* it appears the original coder has based some of the contents of this app off of the following sources
 Indie 103.1
 http://www.indie1031.com/
 
 iPhone Application
 Mike Jablonski
 http://www.mikejablonski.org/
 
 AudioStreamer Code
 Matt Gallagher
 http://cocoawithlove.com/
 
 This is free software.
 http://code.google.com/p/indie1031/
 
 This application is not sponsored or endorsed by Indie 103.1.
 
*/


#import "SRNAppDelegate.h"
#import	"MyViewController.h";

@implementation SRNAppDelegate

@synthesize window;
@synthesize ViewController;



- (void)applicationDidFinishLaunching:(UIApplication *)application {  
	
		
	
	ViewController = [[MyViewController alloc]init];
	//[ViewController initialAdjustment];
	[window addSubview: ViewController.view];
	
	// Override point for customization after application launch
    [window makeKeyAndVisible];
	
}


- (void)dealloc {
	
	[ViewController release];
    [window release];
    [super dealloc];
}

////////////////////////////////////
// DJB Configuration data support
////////////////////////////////////

- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
	
	// finish
	if (ViewController!=nil)
		[ViewController BackUpConfig];
}

////////////////////////////////////
// Multitasking Transition
////////////////////////////////////

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
	
	// finish
	if (ViewController!=nil)
		[ViewController BackUpConfig];
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
#if 0
	UIBackgroundTaskIdentifier bgTask;
	UIApplication*    app = [UIApplication sharedApplication];
	
    // Request permission to run in the background. Provide an
    // expiration handler in case the task runs long.
    NSAssert(bgTask == UIBackgroundTaskInvalid, nil);
	
    bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        // Synchronize the cleanup call on the main thread in case
        // the task actually finishes at around the same time.
        dispatch_async(dispatch_get_main_queue(), ^{
            if (bgTask != UIBackgroundTaskInvalid)
            {
                [app endBackgroundTask:bgTask];
                bgTask = UIBackgroundTaskInvalid;
            }
        });
    }];
	
    // Start the long-running task and return immediately.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		
        // Do the work associated with the task.
		
        // Synchronize the cleanup call on the main thread in case
        // the expiration handler is fired at the same time.
        dispatch_async(dispatch_get_main_queue(), ^{
            if (bgTask != UIBackgroundTaskInvalid)
            {
                [app endBackgroundTask:bgTask];
                bgTask = UIBackgroundTaskInvalid;
            }
        });
    });
#endif	
	
	// Enter background
	if (ViewController!=nil)
		[ViewController EnterBackground];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


@end
