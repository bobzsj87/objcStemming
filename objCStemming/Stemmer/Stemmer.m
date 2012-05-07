//
//  Stemmer.m
//  objCStemming
//
//  Created by Bob Zhou on 5/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Stemmer.h"
#import "RegexKitLite.h"
#import "NSString+Stemming.h"

#define r_exp       @"[^aeiouy]*[aeiouy]+[^aeiouy](\\w*)"
#define ewss_exp1   @"^[aeiouy][^aeiouy]$"
#define ewss_exp2   @".*[^aeiouy][aeiouy][^aeiouywxY]$"
#define ccy_exp     @"([aeiouy])y"
#define s1a_exp     @"[aeiouy]."
#define s1b_exp     @"[aeiouy]"

static Stemmer * _dInstance;


@interface Stemmer ()

@property (nonatomic, retain) NSArray *doubles;
@property (nonatomic, retain) NSArray *s1b_suffixes;
@property (nonatomic, retain) NSArray *s2_triples;
@property (nonatomic, retain) NSArray *s3_triples;
@property (nonatomic, retain) NSArray *s4_delete_list;
@property (nonatomic, retain) NSDictionary *exceptional_forms;
@property (nonatomic, retain) NSSet *exceptional_early_exit_post_1a;

- (int)get_r1:(NSString *)word;
- (int)get_r2:(NSString *)word;

- (BOOL)ends_with_short_syllable:(NSString *)word;
- (BOOL)is_short_word:(NSString *)word;

- (NSString *)remove_initial_apostrophe:(NSString *)word;
- (NSString *)capitalize_consonant_ys:(NSString *)word;
- (NSString *)step_0:(NSString *)word;
- (NSString *)step_1a:(NSString *)word;
- (NSString *)step_1b_helper:(NSString *)word;
- (NSString *)step_1b:(NSString *)word r1:(int)r1;
- (NSString *)step_1c:(NSString *)word;
- (NSString *)step_2_helper:(NSString *)word r1:(int)r1 end:(NSString *)end repl:(NSString *)repl prev:(NSArray *)prev;
- (NSString *)step_2:(NSString *)word r1:(int)r1;
- (NSString *)step_3_helper:(NSString *)word r1:(int)r1 r2:(int)r2 end:(NSString *)end repl:(NSString *)repl r2_n:(BOOL)r2_necessary;
- (NSString *)step_3:(NSString *)word r1:(int)r1 r2:(int)r2;
- (NSString *)step_4:(NSString *)word r2:(int)r2;
- (NSString *)step_5:(NSString *)word r1:(int)r1 r2:(int)r2;

- (NSString *)normalize_ys:(NSString *)word;

// finally stem
- (NSString *)stem:(NSString *)word;

- (BOOL)ends_with_double:(NSString *)word;

@end

@implementation Stemmer

@synthesize doubles;
@synthesize s1b_suffixes;
@synthesize s2_triples;
@synthesize s3_triples;
@synthesize s4_delete_list;
@synthesize exceptional_forms;
@synthesize exceptional_early_exit_post_1a;

+ (Stemmer *)stemmer
{    
    @synchronized (self) {
        if (_dInstance == nil){
            _dInstance = [[Stemmer alloc] init];
        }
        return _dInstance;
    }
    return nil;
}

- (void)destory
{
    [_dInstance release];
    _dInstance = nil;
}

- (id)init
{
    self = [super init];
    if (self){
        self.doubles = [NSArray arrayWithObjects:@"bb",@"dd",@"ff",@"gg",@"mm",@"nn",@"pp",@"rr",@"tt", nil];
        self.s1b_suffixes = [NSArray arrayWithObjects:@"ed",@"edly",@"ing",@"ingly", nil];
        
        self.s2_triples = [NSArray arrayWithObjects:
                           [NSArray arrayWithObjects:@"ization", @"ize", [NSMutableArray array], nil],
                           [NSArray arrayWithObjects:@"ational", @"ate", [NSMutableArray array], nil],
                           [NSArray arrayWithObjects:@"fulness", @"ful", [NSMutableArray array], nil],
                           [NSArray arrayWithObjects:@"ousness", @"ous", [NSMutableArray array], nil],
                           [NSArray arrayWithObjects:@"iveness", @"ive", [NSMutableArray array], nil],
                           [NSArray arrayWithObjects:@"tional", @"tion", [NSMutableArray array], nil],
                           [NSArray arrayWithObjects:@"biliti", @"ble", [NSMutableArray array], nil],
                           [NSArray arrayWithObjects:@"lessli", @"less", [NSMutableArray array], nil],
                           [NSArray arrayWithObjects:@"entli", @"ent", [NSMutableArray array], nil],
                           [NSArray arrayWithObjects:@"ation", @"ate", [NSMutableArray array], nil],
                           [NSArray arrayWithObjects:@"alism", @"al", [NSMutableArray array], nil],
                           [NSArray arrayWithObjects:@"aliti", @"al", [NSMutableArray array], nil],
                           [NSArray arrayWithObjects:@"ousli", @"ous", [NSMutableArray array], nil],
                           [NSArray arrayWithObjects:@"iviti", @"ive", [NSMutableArray array], nil],
                           [NSArray arrayWithObjects:@"fulli", @"ful", [NSMutableArray array], nil],
                           [NSArray arrayWithObjects:@"enci", @"ence", [NSMutableArray array], nil],
                           [NSArray arrayWithObjects:@"anci", @"ance", [NSMutableArray array], nil],
                           [NSArray arrayWithObjects:@"abli", @"able", [NSMutableArray array], nil],
                           [NSArray arrayWithObjects:@"izer", @"ize", [NSMutableArray array], nil],
                           [NSArray arrayWithObjects:@"ator", @"ate", [NSMutableArray array], nil],
                           [NSArray arrayWithObjects:@"alli", @"al", [NSMutableArray array], nil],
                           [NSArray arrayWithObjects:@"bli", @"ble", [NSMutableArray array], nil],
                           [NSArray arrayWithObjects:@"ogi", @"og", [NSMutableArray arrayWithObject:@"l"], nil],
                           [NSArray arrayWithObjects:@"li", @"", [NSMutableArray arrayWithObjects:
                                                                  @"c",@"d",@"e",@"g",@"h",@"k",@"m",@"n",@"r",@"t", nil], nil],
                           nil];
        
        self.s3_triples = [NSArray arrayWithObjects:
                           [NSArray arrayWithObjects:@"ational", @"ate", [NSNumber numberWithBool:NO], nil],
                           [NSArray arrayWithObjects:@"tional", @"tion", [NSNumber numberWithBool:NO], nil],
                           [NSArray arrayWithObjects:@"alize", @"al", [NSNumber numberWithBool:NO], nil],
                           [NSArray arrayWithObjects:@"icate", @"ic", [NSNumber numberWithBool:NO], nil],
                           [NSArray arrayWithObjects:@"iciti", @"ic", [NSNumber numberWithBool:NO], nil],
                           [NSArray arrayWithObjects:@"ative", @"", [NSNumber numberWithBool:YES], nil],
                           [NSArray arrayWithObjects:@"ical", @"ic", [NSNumber numberWithBool:NO], nil],
                           [NSArray arrayWithObjects:@"ness", @"", [NSNumber numberWithBool:NO], nil],
                           [NSArray arrayWithObjects:@"ful", @"", [NSNumber numberWithBool:NO], nil],
                           nil];
        
        self.s4_delete_list = [NSArray arrayWithObjects:@"al",@"ance",@"ence",@"er",@"ic",@"able",@"ible",@"ant",@"ement", @"ment",@"ent",@"ism",@"ate",@"iti",@"ous",@"ive",@"ize", nil];

        
        self.exceptional_forms = [NSDictionary dictionaryWithObjectsAndKeys:
                                  @"ski", @"skis",
                                  @"sky", @"skies",
                                  @"die", @"dying",
                                  @"lie", @"lying",
                                  @"tie", @"tying",
                                  @"idl", @"idly",
                                  @"gentl", @"gently",
                                  @"ugli", @"ugly",
                                  @"earli", @"early",
                                  @"onli", @"only",
                                  @"singl", @"singly",
                                  @"sky", @"sky",
                                  @"news", @"news",
                                  @"howe", @"howe",
                                  @"atlas", @"atlas",
                                  @"cosmos", @"cosmos",
                                  @"bias", @"bias",
                                  @"andes", @"andes",
                                  nil];
        
        self.exceptional_early_exit_post_1a = [NSSet setWithObjects:@"inning",@"outing",@"canning",@"herring",@"earring",@"proceed",@"exceed",@"succeed", nil];

    }
    return self;
}

- (void)dealloc
{
    self.doubles = nil;
    self.s1b_suffixes = nil;
    self.s2_triples = nil;
    self.s3_triples = nil;
    self.exceptional_forms = nil;
    self.exceptional_early_exit_post_1a = nil;
    [super dealloc];
}

// private functions

- (int)get_r1:(NSString *)word
{
    // exceptional forms
    if ([word startsWith:@"gener"] || [word startsWith:@"arsen"]){
        return 5;
    }
    if ([word startsWith:@"commun"]){
        return 6;
    }
    
    // normal form
    NSRange range = [word rangeOfRegex:r_exp capture:1];
    return range.location != NSNotFound ? range.location : word.length;
}

- (int)get_r2:(NSString *)word
{
    NSRange range = [word rangeOfRegex:r_exp capture:1];
    return range.location != NSNotFound ? range.location : word.length;
}

- (BOOL)ends_with_short_syllable:(NSString *)word
{
    if (word.length == 2){
        if ([word isMatchedByRegex:ewss_exp1])
            return YES;
    }
    if ([word isMatchedByRegex:ewss_exp2])
        return YES;
    return NO;
}

- (BOOL)is_short_word:(NSString *)word
{
    if ([self ends_with_short_syllable:word]){
        if ([self get_r1:word] == word.length)
            return YES;
    }
    return NO;
}


- (NSString *)remove_initial_apostrophe:(NSString *)word
{
    if ([word startsWith:@"'"])
        return [word substringFromIndex:1];
    return word;
}

- (NSString *)capitalize_consonant_ys:(NSString *)word
{
    if ([word startsWith:@"y"]){
        word = [NSString stringWithFormat:@"Y%@", [word substringFromIndex:1]];
    }
    return [word stringByReplacingOccurrencesOfRegex:ccy_exp withString:@"$1Y"];    
}

- (NSString *)step_0:(NSString *)word
{
    if ([word endsWith:@"'s'"])
        return [word substringToIndex:word.length-3];
    if ([word endsWith:@"'s"])
        return [word substringToIndex:word.length-2];
    if ([word endsWith:@"'"])
        return [word substringToIndex:word.length-1];
    return word;
}

- (NSString *)step_1a:(NSString *)word
{
    if ([word endsWith:@"sses"])
        return [NSString stringWithFormat:@"%@ss",[word substringToIndex:word.length-4]];
    if ([word endsWith:@"ied"] || [word endsWith:@"ies"]){
        if (word.length > 4)
            return [NSString stringWithFormat:@"%@i",[word substringToIndex:word.length-3]];
        else
            return [NSString stringWithFormat:@"%@ie",[word substringToIndex:word.length-3]];

    }
    
    if ([word endsWith:@"us"] || [word endsWith:@"ss"])
        return word;
    
    if ([word endsWith:@"s"]){
        NSString *preceding = [word substringToIndex:word.length-1];
        if ([preceding rangeOfRegex:s1a_exp].location != NSNotFound)
            return preceding;
        return word;
    }
    
    return word;
}

- (NSString *)step_1b_helper:(NSString *)word
{
    if ([word endsWith:@"at"] || [word endsWith:@"bl"] || [word endsWith:@"iz"])
        return [NSString stringWithFormat:@"%@e",[word substringToIndex:word.length-1]];
    if ([self ends_with_double:word])
        return [word substringToIndex:word.length-1];
    if ([self is_short_word:word])
        [NSString stringWithFormat:@"%@e", word];
    return word;
}

- (NSString *)step_1b:(NSString *)word r1:(int)r1
{
    if ([word endsWith:@"eddly"]){
        if (word.length - 5 >= r1)
            return [word substringToIndex:word.length-3];
        return word;
    }
    
    if ([word endsWith:@"eed"]){
        if (word.length - 3 >= r1)
            return [word substringToIndex:word.length-1];
        return word;
    }
    
    for (NSString *suffix in self.s1b_suffixes){
        if ([word endsWith:suffix]){
            NSString *preceding = [word substringToIndex:word.length-suffix.length];
            if ([preceding rangeOfRegex:s1b_exp].location != NSNotFound)
                return [self step_1b_helper:preceding];
            return word;
        }
    }
    
    return word;
}


- (NSString *)step_1c:(NSString *)word
{
    if ([word endsWith:@"y"] || ([word endsWith:@"Y"] && word.length > 1)){
        NSString *c = [word substringWithRange:NSMakeRange(word.length-2, 1)];
        if (![c isMatchedByRegex:@"[aeiouy]"] && word.length > 2)
            return [NSString stringWithFormat:@"%@1",[word substringToIndex:word.length-1]];
    }
    return word;
}


- (NSString *)step_2_helper:(NSString *)word r1:(int)r1 end:(NSString *)end repl:(NSString *)repl prev:(NSArray *)prev
{
    if ([word endsWith:end]){
        if (word.length - end.length >= r1){
            if (prev.count == 0)
                return [NSString stringWithFormat:@"%@%@", [word substringToIndex:word.length-end.length], repl];
            for (NSString *p in prev){
                if ([[word substringToIndex:word.length-end.length] endsWith:p])
                    return [NSString stringWithFormat:@"%@%@", [word substringToIndex:word.length-end.length], repl];
            }
        }
        return word;
    }
    
    return nil;
}

- (NSString *)step_2:(NSString *)word r1:(int)r1
{
    for (NSArray *trip in self.s2_triples){
        NSString *attempt = [self step_2_helper:word r1:r1 end:[trip objectAtIndex:0] repl:[trip objectAtIndex:1] prev:[trip objectAtIndex:2]];
        if (attempt)
            return attempt;
    }
    return word;
}

- (NSString *)step_3_helper:(NSString *)word r1:(int)r1 r2:(int)r2 end:(NSString *)end repl:(NSString *)repl r2_n:(BOOL)r2_necessary
{
    if ([word endsWith:end]){
        if (word.length - end.length >= r1)
            if (!r2_necessary)
                return [NSString stringWithFormat:@"%@%@", [word substringToIndex:word.length-end.length], repl];
            else if (word.length - end.length >= r2)
                return [NSString stringWithFormat:@"%@%@", [word substringToIndex:word.length-end.length], repl];
        return word;
    }
    return nil;
}


- (NSString *)step_3:(NSString *)word r1:(int)r1 r2:(int)r2
{
    for (NSArray *trip in self.s3_triples){
        NSString *attempt = [self step_3_helper:word r1:r1 r2:r2 end:[trip objectAtIndex:0] repl:[trip objectAtIndex:1] r2_n:[[trip objectAtIndex:2] boolValue]];
        if (attempt)
            return attempt;
    }
    return word;
}

- (NSString *)step_4:(NSString *)word r2:(int)r2
{
    for (NSString *end in self.s4_delete_list){
        if ([word endsWith:end]){
            if (word.length - end.length >= r2)
                return [word substringToIndex:word.length-end.length];
            return word;
        }
    }
    
    if ([word endsWith:@"sion"] || [word endsWith:@"tion"]){
        if (word.length -3 >= r2)
            return [word substringToIndex:word.length-3];
    }
    return word;
}

- (NSString *)step_5:(NSString *)word r1:(int)r1 r2:(int)r2
{
    if ([word endsWith:@"l"]){
        if (word.length -1 >= r2 && [[word substringWithRange:NSMakeRange(word.length-2, 1)] isEqualToString:@"l"])
            return [word substringToIndex:word.length-1];
        return word;
    }
    if ([word endsWith:@"e"]){
        if (word.length -1 >= r2)
            return [word substringToIndex:word.length-1];
        if (word.length -1 >= r1 && ![self ends_with_short_syllable:[word substringToIndex:word.length-1]])
            return [word substringToIndex:word.length-1];        
        return word;
    }
    return word;
}

- (NSString *)normalize_ys:(NSString *)word
{
    return [word stringByReplacingOccurrencesOfString:@"Y" withString:@"y"];
}

- (BOOL)ends_with_double:(NSString *)word
{
    for (NSString *db in self.doubles){
        if ([word endsWith:db])
            return YES;
    }
    return NO;
}


- (NSString *)stem:(NSString *)word
{
    if (word.length <= 2)
        return word;
    word = [self remove_initial_apostrophe:word];
    
    // handle some exceptional forms
    if ([self.exceptional_forms.allKeys containsObject:word])
        return [self.exceptional_forms objectForKey:word];
    
    word = [self capitalize_consonant_ys:word];
    int r1 = [self get_r1:word];
    int r2 = [self get_r2:word];
    word = [self step_0:word];
    word = [self step_1a:word];
    
    if ([self.exceptional_early_exit_post_1a containsObject:word])
        return word;
    
    word = [self step_1b:word r1:r1];
    word = [self step_1c:word];
    word = [self step_2:word r1:r1];
    word = [self step_3:word r1:r1 r2:r2];
    word = [self step_4:word r2:r2];
    word = [self step_5:word r1:r1 r2:r2];
    word = [self normalize_ys:word];
    
    return word;
}


@end
