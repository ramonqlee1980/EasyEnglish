//
//  RMArticle.h
//  SwipeProject
//
//  Created by Ramonqlee on 7/22/13.
//  Copyright (c) 2013 ramonqlee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RMArticle : NSObject
@property(nonatomic,retain) NSString* title;
@property(nonatomic,retain) NSString* content;
@property(nonatomic,retain) NSString* category;

- (RMArticle*)initWithJsonDictionary:(NSDictionary*)dict;

+ (RMArticle*)statusWithJsonDictionary:(NSDictionary*)dict;
@end
