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

#import <Foundation/Foundation.h>

@interface NSString(Stemming)

- (BOOL)startsWith:(NSString *)word;
- (BOOL)endsWith:(NSString *)word;

@end
