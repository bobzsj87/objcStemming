//
//  Stemmer.m
//  objCStemming
//
//  Created by Bob Zhou on 5/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Stemmer.h"
#import "RegexKitLite.h"


#define r_exp       @"[^aeiouy]*[aeiouy]+[^aeiouy](\w*)"
#define ewss_exp1   @"^[aeiouy][^aeiouy]$"
#define ewss_exp2   @".*[^aeiouy][aeiouy][^aeiouywxY]$"
#define ccy_exp     @"([aeiouy])y"
#define s1a_exp     @"[aeiouy]."
#define s1b_exp     @"[aeiouy]"



@interface Stemmer ()

- (int)get_r1:(NSString *)word;


@end

@implementation Stemmer

+ (Stemmer *)stemmer
{
    static Stemmer * _dInstance;
    
    @synchronized (self) {
        if (_dInstance == nil){
            _dInstance = [[Stemmer alloc] init];
        }
        return _dInstance;
    }
    return nil;
}

- (void)dealloc
{
    [super dealloc];
}

// private functions

- (int)get_r1:(NSString *)word
{
    
}

@end
