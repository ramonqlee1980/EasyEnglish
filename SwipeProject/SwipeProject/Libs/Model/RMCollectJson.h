//
//  RMCollectJson.h
//  SwipeProject
//
//  Created by ramonqlee on 5/5/13.
//  Copyright (c) 2013 ramonqlee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RMCollectJson : NSObject
{
    NSString* title;
    NSString* date;
    NSString* author;
    NSString* url;
}
@property(nonatomic,retain) NSString* title;
@property(nonatomic,retain) NSString* date;
@property(nonatomic,retain) NSString* author;
@property(nonatomic,retain) NSString* url;

- (RMCollectJson*)initWithJsonDictionary:(NSDictionary*)dict;

+ (RMCollectJson*)statusWithJsonDictionary:(NSDictionary*)dict;

@end
