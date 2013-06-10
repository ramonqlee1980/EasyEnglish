//
//  RMDailySentenceJson.h
//  SwipeProject
//
//  Created by Ramonqlee on 6/11/13.
//  Copyright (c) 2013 ramonqlee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RMDailySentenceJson : NSObject
@property(nonatomic,retain) NSString* foreignText;
@property(nonatomic,retain) NSString* chineseText;
@property(nonatomic,retain) NSString* date;
@property(nonatomic,retain) NSString* audioUrl;
@property(nonatomic,retain) NSString* imageUrl;

- (RMDailySentenceJson*)initWithJsonDictionary:(NSDictionary*)dict;

+ (RMDailySentenceJson*)statusWithJsonDictionary:(NSDictionary*)dict;
@end
