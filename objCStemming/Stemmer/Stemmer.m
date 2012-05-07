//
//  Stemmer.m
//  objCStemming
//
//  Created by Bob Zhou on 5/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Stemmer.h"

@interface Stemmer ()

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


// private functions

@end
