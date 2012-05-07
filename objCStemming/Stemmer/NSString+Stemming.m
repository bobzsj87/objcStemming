//
//  NSString+Stemming.m
//  objCStemming
//
//  Created by Bob Zhou on 5/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NSString+Stemming.h"

@implementation NSString(Stemming)

- (BOOL)startsWith:(NSString *)word
{
    if (word.length <= self.length)
        return [[self substringToIndex:word.length] isEqualToString:word];
    return NO;
}

- (BOOL)endsWith:(NSString *)word
{
    if (word.length <= self.length)
        return [[self substringFromIndex:self.length-word.length] isEqualToString:word];
    return NO;
}

@end
