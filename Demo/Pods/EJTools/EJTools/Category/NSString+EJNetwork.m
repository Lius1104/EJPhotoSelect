//
//  NSString+EJNetwork.m
//  JoyssomTool
//
//  Created by LiuShuang on 2019/6/19.
//  Copyright © 2019 LiuShuang. All rights reserved.
//

#import "NSString+EJNetwork.h"
#import <CommonCrypto/CommonDigest.h>
#import <ifaddrs.h>
#import <arpa/inet.h>
#import "API.h"

@implementation NSString (EJNetwork)

#pragma mark - API Config

#define kAppId          [API sharedApi].appId
#define kSecretKey      [API sharedApi].secretKey

#define kGapTime        [API sharedApi].gapTime

#define kApiUrl         [API sharedApi].apiUrl
#define kFileUrl        [API sharedApi].fileUrl

+ (NSString *)IP {
    return [[NSString getWifiIPAddress] isEqualToString:@"error"] ? [NSString getCellIPAddress] : [NSString getWifiIPAddress];
}

+ (NSString *)getWifiIPAddress {
    NSString *address = @"error";
    NSString *address6 = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0)
    {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                sa_family_t family = temp_addr->ifa_addr->sa_family;
                switch (family) {
                    case AF_INET: {
                        // Check if interface is en0 which is the wifi connection on the iPhone
                        // Get NSString from C String
                        address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                        
                    }
                        break;
                    case AF_INET6: {
                        char str[INET6_ADDRSTRLEN] = {0};
                        inet_ntop(family, &(((struct sockaddr_in6 *)temp_addr->ifa_addr)->sin6_addr), str, sizeof(str));
                        if (strlen(str) > 0) {
                            address6 = [NSString stringWithUTF8String:str];
                        }
                    }
                        break;
                        
                    default:
                        break;
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return [address isEqualToString:@"error"] ? ([address6 isEqualToString:@"error"] ? @"error" : address6) : address;
}

+ (NSString *)getCellIPAddress {
    // pdp_ip0
    NSString *address = @"error";
    NSString *address6 = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0)
    {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"pdp_ip0"]) {
                sa_family_t family = temp_addr->ifa_addr->sa_family;
                switch (family) {
                    case AF_INET: {
                        // Check if interface is en0 which is the wifi connection on the iPhone
                        // Get NSString from C String
                        address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                        
                    }
                        break;
                    case AF_INET6: {
                        char str[INET6_ADDRSTRLEN] = {0};
                        inet_ntop(family, &(((struct sockaddr_in6 *)temp_addr->ifa_addr)->sin6_addr), str, sizeof(str));
                        if (strlen(str) > 0) {
                            address6 = [NSString stringWithUTF8String:str];
                        }
                    }
                        break;
                        
                    default:
                        break;
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return [address isEqualToString:@"error"] ? ([address6 isEqualToString:@"error"] ? @"error" : address6) : address;
}

+ (NSString *)ej_MD5SignUrlAction:(NSString *)action params:(NSDictionary *)param timeSpan:(NSString *)timeSpan {
    
#if defined(kSecretKey)
    NSString * secretKey = kSecretKey;
#else
    NSString * secretKey = @"";
#endif
    if ([secretKey length] == 0) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:[NSString stringWithFormat:@"You must define kSecretKey %@ in %@", NSStringFromSelector(_cmd), self.class]
                                     userInfo:nil];
    }
    
    
#if defined(kAppId)
    NSString *appId = kAppId;
#else
    NSString * appId = @"";
#endif
    if ([appId length] == 0) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:[NSString stringWithFormat:@"You must define kAppId %@ in %@", NSStringFromSelector(_cmd), self.class]
                                     userInfo:nil];
    }
    
    NSString *string = secretKey;
    
    string = [string stringByAppendingString:[NSString stringWithFormat:@"%@/%@/%@", action, appId, timeSpan]];
    //#warning sign 获取方法改版
    string = [string stringByAppendingString:[self ej_addParams:param]];
    string = [string stringByReplacingOccurrencesOfString:@"/" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"\\" withString:@""];
    //字符串转全小写
    NSString *lowStr = [string lowercaseString];
    //字符串 MD5加密
    const char *cStr = [lowStr UTF8String];
    
    unsigned char result[16];
    
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
    
    NSString *signString = [NSString stringWithFormat:
                            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                            result[0], result[1], result[2], result[3],
                            result[4], result[5], result[6], result[7],
                            result[8], result[9], result[10], result[11],
                            result[12], result[13], result[14], result[15]
                            ];
    return signString;
}
//拼接参数
+ (NSString *)ej_addParams:(NSDictionary *)param {
    NSString *finStr = @"";
    NSString *charactersStr = @"!*';:@&=+$,/?%#[]";
    if (param != nil) {
        NSArray *keys = [param allKeys];
        for (NSString *key in keys) {
            if (key == [keys firstObject]) {
                finStr = [finStr stringByAppendingString:@"?"];
            }
            finStr = [finStr stringByAppendingString:key];
            finStr = [finStr stringByAppendingString:@"="];
            //对 value 进行编码
            NSString *str;
            if ([param[key] isKindOfClass:[NSString class]]) {
                if ([self ej_judgeStringIsDateWithString:param[key]]) {
                    str = (__bridge NSString *) CFURLCreateStringByAddingPercentEscapes(NULL, (__bridge CFStringRef) ([param[key] stringByReplacingOccurrencesOfString:@"T" withString:@" "]), NULL, (__bridge CFStringRef) charactersStr, kCFStringEncodingUTF8);
                } else {
                    str = (__bridge NSString *) CFURLCreateStringByAddingPercentEscapes(NULL, (__bridge CFStringRef) param[key], NULL, (__bridge CFStringRef) charactersStr, kCFStringEncodingUTF8);
                }
            } else if ([param[key] isKindOfClass:[NSNumber class]]) {
                str = [NSString stringWithFormat:@"%@", param[key]];
            } else {
                str = @"";
            }
            finStr = [finStr stringByAppendingString:str];
            if (key != [keys lastObject]) {
                finStr = [finStr stringByAppendingString:@"&"];
            }
        }
    }
    return finStr;
}

+ (BOOL)ej_judgeStringIsDateWithString:(NSString *)str {
    BOOL isStr;
    NSString *judgeStr = @"[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T[0-9][0-9]:[0-9][0-9]:[0-9][0-9]";
    NSPredicate *numberPre = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", judgeStr];
    isStr = [numberPre evaluateWithObject:str];
    return isStr;
}


#pragma mark - publish
+ (NSString *)ej_getURLWithServer:(NSString *)server Action:(NSString *)action Parameters:(NSDictionary *)param isSign:(BOOL)isSign {
    NSString * serverUrl = server;
    if ([serverUrl length] == 0) {
#if defined(kApiUrl)
        serverUrl = kApiUrl;
#else
//        NSString * serverUrl = @"";
        serverUrl = @"";
#endif
    }
//    if ([server rangeOfString:@"http://"].location == NSNotFound) {
//        server = [@"http://" stringByAppendingString:server];
//    }
    if ([serverUrl length] == 0 ) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:[NSString stringWithFormat:@"You must Incoming server %@ in %@", NSStringFromSelector(_cmd), self.class]
                                     userInfo:nil];
    }
    if ([action length] == 0 ) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:[NSString stringWithFormat:@"You must Incoming action %@ in %@", NSStringFromSelector(_cmd), self.class]
                                     userInfo:nil];
    }
    
#if defined(kSecretKey)
    NSString * secretKey = kSecretKey;
#else
    NSString * secretKey = @"";
#endif
    if ([secretKey length] == 0) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:[NSString stringWithFormat:@"You must define kSecretKey %@ in %@", NSStringFromSelector(_cmd), self.class]
                                     userInfo:nil];
    }
    
//    NSString * appId = @"";
#if defined(kAppId)
    NSString * appId = kAppId;
#else
    NSString * appId = @"";
#endif
    if ([appId length] == 0) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:[NSString stringWithFormat:@"You must define kAppId %@ in %@", NSStringFromSelector(_cmd), self.class]
                                     userInfo:nil];
    }
    
//    NSInteger gapTime = NSIntegerMax;
#if defined(kGapTime)
    NSInteger gapTime = kGapTime;
#else
    NSInteger gapTime = NSIntegerMax;
#endif
    if (gapTime == NSIntegerMax) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:[NSString stringWithFormat:@"You must define kGapTime %@ in %@", NSStringFromSelector(_cmd), self.class]
                                     userInfo:nil];
    }
    
    if (isSign) {
        NSDate *localDate = [[NSDate alloc] init];
        NSTimeInterval a = [localDate timeIntervalSince1970] * 1000 - gapTime * 1000;
        
        NSString *timeSpan = [NSString stringWithFormat:@"%.f", a];
        
        NSString *signString = [self ej_MD5SignUrlAction:action params:param timeSpan:timeSpan];
        NSString *finStr = [NSString stringWithFormat:@"%@/%@/%@/%@/%@", serverUrl, action, appId, signString, timeSpan];
        finStr = [finStr stringByAppendingString:[self ej_addParams:param]];
        return finStr;
    } else {
        NSString *finStr = [NSString stringWithFormat:@"%@/%@", serverUrl, action];
        finStr = [finStr stringByAppendingString:[self ej_addParams:param]];
        return finStr;
    }
}

//+ (NSString *)ej_getFileUrlWithAction:(NSString *)action Parameters:(NSDictionary *)param {
//    NSString * fileUrl;
//#if defined(kFileUrl)
//    fileUrl = kFileUrl;
//#endif
//    if ([fileUrl length] == 0) {
//        @throw [NSException exceptionWithName:NSInternalInconsistencyException
//                                       reason:[NSString stringWithFormat:@"You must define fileUrl %@ in %@", NSStringFromSelector(_cmd), self.class]
//                                     userInfo:nil];
//    }
//    return [NSString ej_getURLWithServer:fileUrl Action:action Parameters:param isSign:YES];
//}

@end
