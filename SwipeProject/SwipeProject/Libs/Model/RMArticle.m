//
//  RMArticle.m
//  SwipeProject
//
//  Created by Ramonqlee on 7/22/13.
//  Copyright (c) 2013 ramonqlee. All rights reserved.
//

#import "RMArticle.h"
#import "NSDictionaryAdditions.h"

@implementation RMArticle
@synthesize title,content,category;

- (RMArticle*)initWithJsonDictionary:(NSDictionary*)dict
{
    if (self = [super init]) {
		self.title = [dict getStringValueForKey:@"标题" defaultValue:@""];
        self.content = [dict getStringValueForKey:@"内容" defaultValue:@""];
        self.category = [dict getStringValueForKey:@"类别" defaultValue:@""];
    }
    return self;
}
-(void)dealloc
{
    self.title = nil;
    self.content = nil;
    self.category = nil;
    
    [super dealloc];
}
+ (RMArticle*)statusWithJsonDictionary:(NSDictionary*)dict
{
    return [[[RMArticle alloc]initWithJsonDictionary:dict]autorelease];
}
@end
