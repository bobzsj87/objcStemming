//
//  AppDelegate.m
//  objCStemming
//
//  Created by Bob Zhou on 5/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "RegexKitLite.h"

@implementation AppDelegate

@synthesize window = _window;

- (void)dealloc
{
    [_window release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    [self performSelector:@selector(textCases)];
    return YES;
}

- (void)textCases
{
//    NSRange range = [@"123" rangeOfRegex:@"1(.*)"];
//    NSLog(@"%@", NSStringFromRange(range));
}

@end
