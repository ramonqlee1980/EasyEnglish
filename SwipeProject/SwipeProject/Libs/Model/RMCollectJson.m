//
//  RMCollectJson.m
//  SwipeProject
//
//  Created by ramonqlee on 5/5/13.
//  Copyright (c) 2013 ramonqlee. All rights reserved.
//

#import "RMCollectJson.h"
#import "NSDictionaryAdditions.h"

@implementation RMCollectJson
@synthesize title;
@synthesize date;
@synthesize author;
@synthesize url;

-(BOOL)isEqual:(id)object
{
    if(!object)
    {
        return NO;
    }
    RMCollectJson* cmp = (RMCollectJson*)object;
    if(0==[self.description length])
    {
        return [self.url isEqualToString:cmp.url];
    }
    else
    {
        return [self.description isEqualToString:cmp.description];
    }
}
- (RMCollectJson*)initWithJsonDictionary:(NSDictionary*)dict
{
    if (self = [super init]) {
		self.title = [dict getStringValueForKey:@"title" defaultValue:@""];
        self.date = [dict getStringValueForKey:@"date" defaultValue:@""];
        self.author = [dict getStringValueForKey:@"auther_name" defaultValue:@""];
        self.url = [dict getStringValueForKey:@"weburl" defaultValue:@""];
    }
    return self;
}

+ (RMCollectJson*)statusWithJsonDictionary:(NSDictionary*)dict
{
    return [[[RMCollectJson alloc]initWithJsonDictionary:dict]autorelease];
}


-(void)dealloc
{
    self.title = nil;
    self.date = nil;
    self.author = nil;
    self.url = nil;
    [super dealloc];
}
@end

