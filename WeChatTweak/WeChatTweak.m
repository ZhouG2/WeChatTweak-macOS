//
//  WeChatTweak.m
//  WeChatTweak
//
//  Created by Sunnyyoung on 2017/8/11.
//  Copyright © 2017年 Sunnyyoung. All rights reserved.
//

#import "WeChatTweak.h"

static NSString * const WeChatTweakRevokedMessageStyleKey = @"WeChatTweakRevokedMessageStyleKey";
static NSInteger count = 0;

@implementation WeChatTweak
+ (NSInteger) appCount{
    
    if(count ==0){
        NSArray* apps =  [NSRunningApplication runningApplicationsWithBundleIdentifier:[NSBundle mainBundle].bundleIdentifier];
        count = apps.count;
    }
    return count;
}

+ (WTRevokedMessageStyle)revokedMessageStyle {
    return [NSUserDefaults.standardUserDefaults integerForKey:WeChatTweakRevokedMessageStyleKey];
}

+ (void)setRevokedMessageStyle:(WTRevokedMessageStyle)revokedMessageStyle {
    [NSUserDefaults.standardUserDefaults setInteger:revokedMessageStyle forKey:WeChatTweakRevokedMessageStyleKey];
    [NSUserDefaults.standardUserDefaults synchronize];
}

@end
