/*
 This file is part of objCStemming 
 Copyright (C) 2012 Zhou Shijun
 More infomation: https://github.com/bobzsj87/objcStemming
 
 Migrated from https://bitbucket.org/mchaput/stemming
 An implementation of the Porter2 stemming algorithm.
 See http://snowball.tartarus.org/algorithms/english/stemmer.html
 
 
 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#import "AppDelegate.h"
#import "Stemmer.h"

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
    
    self.window.rootViewController = [[[UIViewController alloc] init] autorelease];
    
    [self performSelector:@selector(textCases)];
    
    return YES;
}

- (void)textCases
{
    NSLog(@"%@", [[Stemmer stemmer] stem:@"playing"]);
    NSLog(@"%@", [[Stemmer stemmer] stem:@"apples"]);
    NSLog(@"%@", [[Stemmer stemmer] stem:@"satisified"]);
    NSLog(@"%@", [[Stemmer stemmer] stem:@"bob's"]);

    [[Stemmer stemmer] destory];
}

@end
