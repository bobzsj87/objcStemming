//
//  NSString+Stemming.h
//  objCStemming
//
//  Created by Bob Zhou on 5/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString(Stemming)

- (BOOL)startsWith:(NSString *)word;
- (BOOL)endsWith:(NSString *)word;

@end
