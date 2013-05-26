//
//  CommonHelper.m
//  Hayate
//
//  Created by 韩 国翔 on 11-12-2.
//  Copyright 2011年 山东海天软件学院. All rights reserved.
//

#import "CommonHelper.h"
#import <CommonCrypto/CommonDigest.h>


@implementation CommonHelper

+(NSString *)getFileSizeString:(NSString *)size
{
    if([size floatValue]>=1024*1024)//大于1M，则转化成M单位的字符串
    {
        return [NSString stringWithFormat:@"%fM",[size floatValue]/1024/1024];
    }
    else if([size floatValue]>=1024&&[size floatValue]<1024*1024) //不到1M,但是超过了1KB，则转化成KB单位
    {
        return [NSString stringWithFormat:@"%fK",[size floatValue]/1024];
    }
    else//剩下的都是小于1K的，则转化成B单位
    {
        return [NSString stringWithFormat:@"%fB",[size floatValue]];
    }
}

+(float)getFileSizeNumber:(NSString *)size
{

    NSInteger indexM=[size rangeOfString:@"M"].location;
    NSInteger indexK=[size rangeOfString:@"K"].location;
    NSInteger indexB=[size rangeOfString:@"B"].location;
    if(indexM<1000)//是M单位的字符串
    {
        return [[size substringToIndex:indexM] floatValue]*1024*1024;
    }
    else if(indexK<1000)//是K单位的字符串
    {
        return [[size substringToIndex:indexK] floatValue]*1024;
    }
    else if(indexB<1000)//是B单位的字符串
    {
        return [[size substringToIndex:indexB] floatValue];
    }
    else//没有任何单位的数字字符串
    {
        return [size floatValue];
    }
}
+(NSString *)getFileSizeStringWithFileName:(NSString *)fileName
{
    NSDictionary* dict = [[NSFileManager defaultManager]attributesOfItemAtPath:fileName error:nil];
    NSNumber* fileSize = [dict objectForKey:NSFileSize];
    
    return [CommonHelper getFileSizeString:fileSize.stringValue];
}
+(NSString*) getTargetBookPath:(NSString*)bookName
{
    NSString *documentsDirectory = [CommonHelper getTargetFolderPath];
    return [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"Data/%@",bookName]];

}

+(NSString *)getDocumentPath
{
    return [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches"];
}

+(NSString *)getTargetFolderPath
{
    return [self getDocumentPath];
}

+(NSString *)getTempFolderPath
{
    return [[self getDocumentPath] stringByAppendingPathComponent:@"Temp"];
}

+(BOOL)isExistFile:(NSString *)fileName
{
    if (!fileName || [fileName length]==0) {
        return NO;
    }
    NSFileManager *fileManager=[NSFileManager defaultManager];
    return [fileManager fileExistsAtPath:fileName];
}

+(float)getProgress:(float)totalSize currentSize:(float)currentSize
{
    const float kZero = 0.01;
    if (currentSize<kZero || totalSize < kZero) {
        return 0;
    }
    return currentSize/totalSize;
}

+(BOOL)copyFile:(NSString*)srcFile toFile:(NSString*)desFile
{
    NSMutableData *writer = [[NSMutableData alloc]init];
    [CommonHelper makesureDirExist:[desFile stringByDeletingLastPathComponent]];
    
    NSData *reader = [NSData dataWithContentsOfFile:srcFile];
    [writer appendData:reader];
    [writer writeToFile:desFile atomically:YES];
    [writer release];
    return YES;
}

+(void)makesureDirExist:(NSString*)directory
{
    NSError* err;
    //BOOL dir = NO;
    //if(![[NSFileManager defaultManager]fileExistsAtPath:directory isDirectory:&dir])
    {
        [[NSFileManager defaultManager]createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:&err];
    }
}


+(NSStringEncoding)dataEncoding:(const Byte*) header
{
    NSStringEncoding encoding = NSUTF8StringEncoding;
    if(header)
    {
        if ( !(header[0]==0xff || header[0] == 0xfe) ) {
            encoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        }
    }
    return encoding;
}
// 比较oldVersion和newVersion，如果oldVersion比newVersion旧，则返回YES，否则NO
// Version format[X.X.X]
+(BOOL)CompareVersionFromOldVersion : (NSString *)oldVersion
                         newVersion : (NSString *)newVersion
{
    NSArray*oldV = [oldVersion componentsSeparatedByString:@"."];
    NSArray*newV = [newVersion componentsSeparatedByString:@"."];
    NSUInteger len = MAX(oldV.count,newV.count);
    
    for (NSInteger i = 0; i < len; i++) {
        NSInteger old = (i<oldV.count)?[(NSString *)[oldV objectAtIndex:i] integerValue]:0;
        NSInteger new = (i<newV.count)?[(NSString *)[newV objectAtIndex:i] integerValue]:0;
        if (old != new) {
            return (new>old);
        }
    }
    return NO;
}

#pragma multiple params
+(id)performSelector:(NSObject*)obj selector:(SEL)selector withObject:(id)p1 withObject:(id)p2 withObject:(id)p3
{
    
    NSMethodSignature *sig = [obj methodSignatureForSelector:selector];
    
    if (sig)
    {
        NSInvocation* invo = [NSInvocation invocationWithMethodSignature:sig];
        
        [invo setTarget:obj];
        
        [invo setSelector:selector];
        
        [invo setArgument:&p1 atIndex:2];
        
        [invo setArgument:&p2 atIndex:3];
        
        [invo setArgument:&p3 atIndex:4];
        
        
        [invo invoke];
        
        if (sig.methodReturnLength) {
            
            id anObject;
            
            [invo getReturnValue:&anObject];
            
            return anObject;
        }
        else {
            return nil;
        }
    }
    else {
        return nil;
    }
}
+ (UIViewController *)getCurrentRootViewController {
    
    UIViewController *result = nil;
//    if (rootViewController)
//    {
//        // If developer provieded a root view controler, use it
//        result = rootViewController;
//    }
//    else
	{
		// Try to find the root view controller programmically
        
		// Find the top window (that is not an alert view or other window)
		UIWindow *topWindow = [[UIApplication sharedApplication] keyWindow];
		if (topWindow.windowLevel != UIWindowLevelNormal)
		{
			NSArray *windows = [[UIApplication sharedApplication] windows];
			for(topWindow in windows)
			{
				if (topWindow.windowLevel == UIWindowLevelNormal)
					break;
			}
		}
        
		UIView *rootView = [[topWindow subviews] objectAtIndex:0];
		id nextResponder = [rootView nextResponder];
        
		if ([nextResponder isKindOfClass:[UIViewController class]])
			result = nextResponder;
		else if ([topWindow respondsToSelector:@selector(rootViewController)] && topWindow.rootViewController != nil)
            result = topWindow.rootViewController;
		else
			NSAssert(NO, @"ShareKit: Could not find a root view controller.  You can assign one manually by calling [[SHK currentHelper] setRootViewController:YOURROOTVIEWCONTROLLER].");
	}
    return result;    
}
+(NSString*)appStoreUrl
{
    NSString *appName = [NSString stringWithString:[[[NSBundle mainBundle] infoDictionary]   objectForKey:@"CFBundleName"]];
    NSString *appStoreURL = [NSString stringWithFormat:@"itms-apps://itunes.com/app/%@",[appName stringByReplacingOccurrencesOfString:@" " withString:@""]];
    
    return appStoreURL;
}
+ (NSString *)cachePathForKey:(NSString *)key
{
    const char *str = [key UTF8String];
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), r);
    NSString *filename = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                          r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11], r[12], r[13], r[14], r[15]];
    
    return filename;
}
@end
