//
//  Tool.m
//  VPlus
//
//  Created by Donal on 13-5-22.
//  Copyright (c) 2013年 vikaa. All rights reserved.
//

#import "Tool.h"
#import <CommonCrypto/CommonDigest.h>
#import <sys/utsname.h>
#import <sys/sysctl.h>
#import "MTStatusBarOverlay.h"

#define TextWidth 290
#define ImageFilePathName @"WOWOFile"

@implementation Tool

#pragma mark ——————————声音播放——————————

+ (BOOL)CreateSoundFileID:(NSString *)name withType:(NSString *)type SoundID:(SystemSoundID *)soundID inDirectory:(NSString *)directory
{
    BOOL bret = NO;
    id sndpath = [[NSBundle mainBundle]
                  pathForResource:name
                  ofType:type
                  inDirectory:directory];
    CFURLRef baseURL = (CFURLRef) CFBridgingRetain([NSURL fileURLWithPath:sndpath]);
    
    if( AudioServicesCreateSystemSoundID (baseURL, soundID) )
    {
        bret = YES;
    }
    return bret;
}

+ (void)playSoundIDwithFileID:(NSString *)FileId inDirectory:(NSString *)Directory withType:(NSString *)type
{
    SystemSoundID soundID;
    if (![self CreateSoundFileID:FileId withType:type SoundID:&(soundID) inDirectory:Directory]) {
        NSLog(@"读取声音失败" );
    }
    AudioServicesPlaySystemSound(soundID);
}

+(int)getViewHeightWithUIFont:(UIFont *)font andText:(NSString *)txt andFixedWidth:(int)width minHeight:(int)minHeight {
    CGSize constraint = CGSizeMake(width, CGFLOAT_MAX);
    CGSize size       = [txt sizeWithFont:font constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
    float fHeight     = size.height ;
    if (fHeight < minHeight) {
        fHeight = minHeight;
    }
    return fHeight;
}

+(int)getViewWidthWithUIFont:(UIFont *)font andText:(NSString *)txt andFixedHeigth:(int)height minWidth:(int)minWidth {
    CGSize constraint = CGSizeMake(CGFLOAT_MAX, height);
    CGSize size       = [txt sizeWithFont:font constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
    float width       = size.width;
    if (width < minWidth) {
        width = minWidth;
    }
    return width;
}


+ (NSString *)sha1:(NSString *)str {
    const char *cstr = [str cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:str.length];
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, data.length, digest);
    
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }
    
    return output;
}

+(NSString *)md5:(NSString *)str
{
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, strlen(cStr), result); // This is the md5 call
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

//16位MD5加密方式
+ (NSString *)getMd5_16Bit_String:(NSString *)srcString{
    //提取32位MD5散列的中间16位
    NSString *md5_32Bit_String=[self getMd5_32Bit_String:srcString];
    NSString *result = [[md5_32Bit_String substringToIndex:24] substringFromIndex:8];//即9～25位
    
    return result;
}

//32位MD5加密方式
+ (NSString *)getMd5_32Bit_String:(NSString *)srcString{
    const char *cStr = [srcString UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, strlen(cStr), digest );
    NSMutableString *result = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [result appendFormat:@"%02x", digest[i]];
    
    return result;
}

+ (NSString*)getTimeStamp
{
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[date timeIntervalSince1970]];
    return timeSp;
}

+(NSString*)phplong2Data:(NSString *)dateNumber
{
    NSDateFormatter *DateFormatter=[[NSDateFormatter alloc] init];
    [DateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSDate *date=[NSDate dateWithTimeIntervalSince1970:[dateNumber intValue]];
    NSString *dateString=[DateFormatter stringFromDate:date];
    return dateString;
}

+(NSString*)phpBirthday2Data:(NSString *)dateNumber
{
    NSDateFormatter *DateFormatter=[[NSDateFormatter alloc] init];
    [DateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *date=[NSDate dateWithTimeIntervalSince1970:[dateNumber intValue]];
    NSString *dateString=[DateFormatter stringFromDate:date];
    return dateString;
}

+ (NSString *)intervalSinceNow: (NSString *) theDate
{
    NSDateFormatter *date = [[NSDateFormatter alloc] init];
    [date setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSDate *d = [date dateFromString:theDate];
    NSTimeInterval late = [d timeIntervalSince1970]*1;
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval now = [dat timeIntervalSince1970]*1;
    NSString *timeString = @"";
    NSTimeInterval cha = now-late;
    if (cha/3600<1) {
        if (cha/60<1) {
            timeString = @"1";
        }
        else
        {
            timeString = [NSString stringWithFormat:@"%f", cha/60];
            timeString = [timeString substringToIndex:timeString.length-7];
        }
        
        timeString = [NSString stringWithFormat:@"%@分钟前", timeString];
    }
    else if (cha/3600>1&&cha/86400<1) {
        timeString = [NSString stringWithFormat:@"%f", cha/3600];
        timeString = [timeString substringToIndex:timeString.length-7];
        timeString=[NSString stringWithFormat:@"%@小时前", timeString];
    }
    else
    {
        timeString = theDate;
    }
    return timeString;
}

//解析新浪微博中的日期
+ (NSString*)resolveSinaWeiboDate:(NSString*)date{
	NSDateFormatter *iosDateFormater=[[NSDateFormatter alloc]init];
    iosDateFormater.dateFormat=@"EEE MMM d HH:mm:ss Z yyyy";
    //必须设置，否则无法解析
    iosDateFormater.locale=[[NSLocale alloc]initWithLocaleIdentifier:@"en_US"];
    NSDate *date1 = [iosDateFormater dateFromString:date];
    return [NSString stringWithFormat:@"%ld", (long)[date1 timeIntervalSince1970]];
}

/*
 *日期转化为日期格式的字符串
 */
+(NSString*)NSDateToNSString:(NSDate*)date withFormatter:(NSDateFormatter*)formatter{
	NSString	*dateString=[formatter stringFromDate:date];
	return dateString;
}

//压缩图片
+ (UIImage*)imageWithImageSimple:(UIImage*)image scaledToSize:(CGSize)newSize
{
    // Create a graphics image context
    UIGraphicsBeginImageContext(newSize);
    
    // Tell the old image to draw in this new context, with the desired
    // new size
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    
    // Get the new image from the context
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // End the context
    UIGraphicsEndImageContext();
    
    // Return the new image.
    return newImage;
}

+(NSString*)returnDataFilePath:(NSString*)fileName
{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *doc = [paths objectAtIndex:0];
    NSString *filePath = [doc stringByAppendingPathComponent:[NSString stringWithFormat:@"JsonData/%@",fileName]];
    return filePath;
}

+(BOOL)saveDataIntoFile:(NSObject*)obj key:(NSString*)key fileName:(NSString*)fileName
{
    NSString* filePath = [self returnDataFilePath:fileName];
    NSMutableDictionary *data;
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        data=[[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
    }
    else {
        data=[[NSMutableDictionary alloc] initWithCapacity:0];
    }
    [data setObject:obj forKey:key];
    BOOL suss = [data writeToFile:filePath atomically:YES];
    return suss;
}

+(NSObject*)readDataFromFile:(NSString*)fileName key:(NSString*)key
{
    NSString *filePath = [self returnDataFilePath:fileName];
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
    if([data count]!=0)
    {
        if([(NSMutableDictionary *)[data objectForKey:key] count]>0)
        {
            NSMutableDictionary *dic=[NSMutableDictionary dictionaryWithDictionary:[data objectForKey:key]];
            return dic;
        }
    }
    else
    {
        return nil;
    }
    return nil;
}


+(NSString*)returnRecordFilePath:(NSString*)fileName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *doc = [paths objectAtIndex:0];
    NSString *filePath = [doc stringByAppendingPathComponent:[NSString stringWithFormat:@"record%@",fileName]];
    return filePath;
}

+(NSString*)returnCompressedPhotoFilePath:(NSString*)fileName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *doc = [paths objectAtIndex:0];
    NSString *filePath = [doc stringByAppendingPathComponent:[NSString stringWithFormat:@"CompressedPhoto/%@",fileName]];
    return filePath;
}

+(NSString*)returnImageFilePath
{
    NSString *homePath = [[NSBundle mainBundle] executablePath];
    NSArray *strings = [homePath componentsSeparatedByString:@"/"];
    NSString *executableName = [strings objectAtIndex:[strings count]-1];
    NSString *baseDir = [homePath substringToIndex:[homePath length]-[executableName length]-1];
    NSString *resourePath = [NSString stringWithFormat:@"%@/%@",baseDir,ImageFilePathName];
    return resourePath;
}

+ (long)fileSizeForDir:(NSString*)path//计算文件夹下文件的总大小
{
    long size = 0;
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSArray* array = [fileManager contentsOfDirectoryAtPath:path error:nil];
    for(int i = 0; i<[array count]; i++)
    {
        NSString *fullPath = [path stringByAppendingPathComponent:[array objectAtIndex:i]];
        
        BOOL isDir;
        if ( !([fileManager fileExistsAtPath:fullPath isDirectory:&isDir] && isDir) )
        {
            NSDictionary *fileAttributeDic = [fileManager attributesOfItemAtPath:fullPath error:nil];
            size += fileAttributeDic.fileSize;
        }
        else
        {
            [self fileSizeForDir:fullPath];
        }
    }
    return size;
}

+(NSString *) platformString {
    // Gets a string with the device model
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    free(machine);
//    if ([platform isEqualToString:@"iPhone1,1"])    return @"iPhone 2G";
//    else if ([platform isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
//    else if ([platform isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
//    else if ([platform isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
//    else if ([platform isEqualToString:@"iPhone3,2"])    return @"iPhone 4";
//    else if ([platform isEqualToString:@"iPhone3,3"])    return @"iPhone 4 (CDMA)";
//    else if ([platform isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
//    else if ([platform isEqualToString:@"iPhone5,1"])    return @"iPhone 5";
//    else if ([platform isEqualToString:@"iPhone5,2"])    return @"iPhone 5 (GSM+CDMA)";
//    else if ([platform isEqualToString:@"iPhone6,1"])    return @"iPhone 5S";
//    else if ([platform isEqualToString:@"iPhone6,2"])    return @"iPhone 5S";
//    
//    else if ([platform isEqualToString:@"iPod1,1"])      return @"iPod Touch (1 Gen)";
//    else if ([platform isEqualToString:@"iPod2,1"])      return @"iPod Touch (2 Gen)";
//    else if ([platform isEqualToString:@"iPod3,1"])      return @"iPod Touch (3 Gen)";
//    else if ([platform isEqualToString:@"iPod4,1"])      return @"iPod Touch (4 Gen)";
//    else if ([platform isEqualToString:@"iPod5,1"])      return @"iPod Touch (5 Gen)";
//    
//    else if ([platform isEqualToString:@"iPad1,1"])      return @"iPad";
//    else if ([platform isEqualToString:@"iPad1,2"])      return @"iPad 3G";
//    else if ([platform isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
//    else if ([platform isEqualToString:@"iPad2,2"])      return @"iPad 2";
//    else if ([platform isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
//    else if ([platform isEqualToString:@"iPad2,4"])      return @"iPad 2";
//    else if ([platform isEqualToString:@"iPad2,5"])      return @"iPad Mini (WiFi)";
//    else if ([platform isEqualToString:@"iPad2,6"])      return @"iPad Mini";
//    else if ([platform isEqualToString:@"iPad2,7"])      return @"iPad Mini (GSM+CDMA)";
//    else if ([platform isEqualToString:@"iPad3,1"])      return @"iPad 3 (WiFi)";
//    else if ([platform isEqualToString:@"iPad3,2"])      return @"iPad 3 (GSM+CDMA)";
//    else if ([platform isEqualToString:@"iPad3,3"])      return @"iPad 3";
//    else if ([platform isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
//    else if ([platform isEqualToString:@"iPad3,5"])      return @"iPad 4";
//    else if ([platform isEqualToString:@"iPad3,6"])      return @"iPad 4 (GSM+CDMA)";
//    
//    else if ([platform isEqualToString:@"i386"])         return @"Simulator";
//    else if ([platform isEqualToString:@"x86_64"])       return @"Simulator";
    return platform;
}

+ (void)showCompletedTextOnStatusBar:(NSString *)text {
    MTStatusBarOverlay *overlay = [MTStatusBarOverlay sharedInstance];
    overlay.animation = MTStatusBarOverlayAnimationShrink;
    overlay.detailViewMode = MTDetailViewModeHistory;
    [overlay postImmediateFinishMessage:text duration:2.0 animated:YES];
    overlay.progress = 1.0;
}

+(void)showLoadingTextOnStatuBar:(NSString *)text
{
    MTStatusBarOverlay *overlay = [MTStatusBarOverlay sharedInstance];
    overlay.animation = MTStatusBarOverlayAnimationShrink;
    overlay.detailViewMode = MTDetailViewModeHistory;
    [overlay postMessage:text];
}

+ (void)showErrorTextOnStatusBar:(NSString *)text {
    MTStatusBarOverlay *overlay = [MTStatusBarOverlay sharedInstance];
    overlay.animation = MTStatusBarOverlayAnimationShrink;
    overlay.detailViewMode = MTDetailViewModeHistory;
    [overlay postErrorMessage:text duration:2.0 animated:YES];
    overlay.progress = 1.0;
}

+(void)showNothingOnStatuBar
{
    MTStatusBarOverlay *overlay = [MTStatusBarOverlay sharedInstance];
    overlay.alpha = 0.0;
}

+(NSString *)getAlpha:(NSString *)str
{
    if (str.length == 0) {
        return @"#";
    }
    if ([str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0) {
        return @"#";
    }
    NSString *c = [[str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] substringToIndex:1];
    NSString *Regex         = @"^[A-Za-z]+$";
    NSString *result = [c stringByMatching:Regex];
    if ([result length] != 0) {
        return [c uppercaseString];
    } else {
        return @"#";
    }
}

@end

