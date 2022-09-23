//
//  MultipleInstances.m
//  WeChatTweak
//
//  Created by Sunny Young on 2022/2/1.
//  Copyright © 2022 Sunnyyoung. All rights reserved.
//

#import "WeChatTweak.h"
#import "NSBundle+WeChatTweak.h"
#import "SignIn.h"

@implementation NSObject (MultipleInstances)

static NSInteger appCount = 0;
static void __attribute__((constructor)) tweak(void) {
    
    NSLog(@"###:tweak_ constructor");
    
    [objc_getClass("CUtility") jr_swizzleClassMethod:NSSelectorFromString(@"HasWechatInstance") withClassMethod:@selector(tweak_HasWechatInstance) error:nil];
    appCount == [WeChatTweak appCount];
    [objc_getClass("NSRunningApplication") jr_swizzleClassMethod:NSSelectorFromString(@"runningApplicationsWithBundleIdentifier:") withClassMethod:@selector(tweak_runningApplicationsWithBundleIdentifier:) error:nil];
    class_addMethod(objc_getClass("AppDelegate"), @selector(applicationDockMenu:), method_getImplementation(class_getInstanceMethod(objc_getClass("AppDelegate"), @selector(tweak_applicationDockMenu:))), "@:@");
    
    
    [objc_getClass("CUtility") jr_swizzleClassMethod:NSSelectorFromString(@"isBeingDebugged") withClassMethod:@selector(tweak_isBeingDebugged) error:nil];
    [objc_getClass("CUtility") jr_swizzleClassMethod:NSSelectorFromString(@"GetUUID") withClassMethod:@selector(tweak_GetUUID) error:nil];
    
    

}

+ (id)tweak_GetUUID {
    NSLog(@"###:tweak_HasWechatInstance");
   
//    Class cls = NSClassFromString(@"CUtility");
//    NSString *user = [self performSelector:NSSelectorFromString(@"GetCurrentUserName")];
    
    NSString *uid = [self tweak_GetUUID];
    NSLog(@"UUID0:%@", uid);
    if(appCount>1){
        
        NSString *key = [NSString stringWithFormat:@"_uid_%lu", appCount];
        NSString *uid1 =  [[NSUserDefaults standardUserDefaults] objectForKey:key];

        if(uid1 ==nil || uid1.length <=0){
            uid1  = [self performSelector:NSSelectorFromString(@"GetRandomUUID")];
            uid1 = [uid1 lowercaseString];
            uid =  [uid1 stringByReplacingOccurrencesOfString:@"-" withString:@""];
            [[NSUserDefaults standardUserDefaults] setObject:uid forKey:key];
            
        }
        uid = uid1;
        NSLog(@"UUID1:%@", uid);
    }
    
        
    return uid;
}

+ (BOOL)tweak_isBeingDebugged {
    NSLog(@"###:tweak_HasWechatInstance");
    [self tweak_HasWechatInstance];
    return NO;
}

+ (BOOL)tweak_HasWechatInstance {
    NSLog(@"###:tweak_HasWechatInstance");
    [self tweak_HasWechatInstance];
    return NO;
}

+ (NSArray<NSRunningApplication *> *)tweak_runningApplicationsWithBundleIdentifier:(NSString *)bundleIdentifier {
    if ([bundleIdentifier isEqualToString:NSBundle.mainBundle.bundleIdentifier] ) {
        return @[NSRunningApplication.currentApplication];
    } else {
        return [self tweak_runningApplicationsWithBundleIdentifier:bundleIdentifier];
    }
}

- (NSMenu *)tweak_applicationDockMenu:(NSApplication *)sender {
    NSMenu *menu = [[NSMenu alloc] init];
    NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:[NSBundle.tweakBundle localizedStringForKey:@"Tweak.Title.LoginAnotherAccount"]
                                                      action:@selector(openNewWeChatInstace:)
                                               keyEquivalent:@""];
    [menu insertItem:menuItem atIndex:0];
    
    [menu insertItem:[[NSMenuItem alloc] initWithTitle:@"签到"
                                                action:@selector(test:)
                                         keyEquivalent:@""] atIndex:1];
    return menu;
}

- (void)test:(id)sender {
    [SignIn.sharedInstance signIn];
}

- (void)openNewWeChatInstace:(id)sender {
    NSString *applicationPath = NSBundle.mainBundle.bundlePath;
    NSTask *task = [[NSTask alloc] init];
    task.launchPath = @"/usr/bin/open";
    task.arguments = @[@"-n", applicationPath];
    [task launch];
    [task waitUntilExit];
}

@end
