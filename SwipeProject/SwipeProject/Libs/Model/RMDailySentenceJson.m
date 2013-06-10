//
//  RMDailySentenceJson.m
//  SwipeProject
//
//  Created by Ramonqlee on 6/11/13.
//  Copyright (c) 2013 ramonqlee. All rights reserved.
//

#import "RMDailySentenceJson.h"
#import "NSDictionaryAdditions.h"

@implementation RMDailySentenceJson
@synthesize foreignText,chineseText,date,audioUrl,imageUrl;

- (RMDailySentenceJson*)initWithJsonDictionary:(NSDictionary*)dict
{
    if (self = [super init]) {
		self.foreignText = [dict getStringValueForKey:@"foreignText" defaultValue:@""];
        self.date = [dict getStringValueForKey:@"date" defaultValue:@""];
        self.chineseText = [dict getStringValueForKey:@"chineseText" defaultValue:@""];
        self.audioUrl = [dict getStringValueForKey:@"audioUrl" defaultValue:@""];
        self.imageUrl = [dict getStringValueForKey:@"imageUrl" defaultValue:@""];
    }
    return self;
}

+ (RMDailySentenceJson*)statusWithJsonDictionary:(NSDictionary*)dict
{
    return [[[RMDailySentenceJson alloc]initWithJsonDictionary:dict]autorelease];
}


-(void)dealloc
{
    self.foreignText = nil;
    self.date = nil;
    self.chineseText = nil;
    self.audioUrl = nil;
    self.imageUrl = nil;
    [super dealloc];
}
@end
