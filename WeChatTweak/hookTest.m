//
//  hookTest.m
//  WeChatTweak
//
//  Created by ZhouGang on 2022/9/1.
//  Copyright © 2022 Sunnyyoung. All rights reserved.
//

#import <Foundation/Foundation.h>
//
//  AntiRevoke.m
//  WeChatTweak
//
//  Created by Sunny Young on 2021/5/9.
//  Copyright © 2021 Sunnyyoung. All rights reserved.
//

#import "WeChatTweak.h"
#import "NSBundle+WeChatTweak.h"

@implementation NSObject (hookTest)

static void __attribute__((constructor)) hookTest(void) {
//    [objc_getClass("FFProcessReqsvrZZ") jr_swizzleMethod:NSSelectorFromString(@"FFToNameFavChatZZ:sessionMsgList:") withMethod:@selector(tweak_FFToNameFavChatZZ:sessionMsgList:) error:nil];
    
//    [objc_getClass("JSOperateWxDataRequest") jr_swizzleMethod:NSSelectorFromString(@"data") withMethod:@selector(reqData) error:nil];
//    [objc_getClass("JSOperateWxDataResponse") jr_swizzleMethod:NSSelectorFromString(@"data") withMethod:@selector(resData) error:nil];
    
//    [objc_getClass("JSLoginResponse") jr_swizzleMethod:NSSelectorFromString(@".cxx_destruct") withMethod:@selector(login_cxx_destruct) error:nil];
//    [objc_getClass("JSLoginResponse") jr_swizzleMethod:NSSelectorFromString(@"SetCode:") withMethod:@selector(hook_SetCode:) error:nil];
//    [objc_getClass("MMMessageCellView") jr_swizzleMethod:NSSelectorFromString(@"populateWithMessage:") withMethod:@selector(tweak_populateWithMessage:) error:nil];
//    [objc_getClass("MMMessageCellView") jr_swizzleMethod:NSSelectorFromString(@"layout") withMethod:@selector(tweak_layout) error:nil];
    
//    func:::(0x600002af90b0) WAIPCServer - requestCGI:withResponse:
//    requestCGI:  (WAIPCCgiWrap)<WAIPCCgiWrap: 0x600000025c80>
//    withResponse:  (__NSStackBlock__)<__NSStackBlock__: 0x700003516118>
//    signature::types:v16@?0@8 retType:void size:0
//    argTypes:0 pointer size:8
//    argTypes:1 pointer size:8
    
//    [objc_getClass("WAIPCServer") jr_swizzleMethod:NSSelectorFromString(@"requestCGI:withResponse:") withMethod:@selector(hk_requestCGI:withResponse:) error:nil];
}

struct ZBBlockLiteral {
    void *isa; // initialized to &_NSConcreteStackBlock or &_NSConcreteGlobalBlock
    int flags;
    int reserved;
    void (*invoke)(void *, ...);
    struct block_descriptor {
        unsigned long int reserved;    // NULL
        unsigned long int size;         // sizeof(struct Block_literal_1)
        // optional helper functions
        void (*copy_helper)(void *dst, void *src);     // IFF (1<<25)
        void (*dispose_helper)(void *src);             // IFF (1<<25)
        // required ABI.2010.3.16
        const char *signature;                         // IFF (1<<30)
    } *descriptor;
    // imported variables
};

// flags enum
enum {
    ZBBlockDescriptionFlagsHasCopyDispose = (1 << 25),
    ZBBlockDescriptionFlagsHasCtor = (1 << 26), // helpers have C++ code
    ZBBlockDescriptionFlagsIsGlobal = (1 << 28),
    ZBBlockDescriptionFlagsHasStret = (1 << 29), // IFF BLOCK_HAS_SIGNATURE
    ZBBlockDescriptionFlagsHasSignature = (1 << 30)
};
typedef int ZBBlockDescriptionFlags;

+ (NSMethodSignature *)getSignatureWithBlock:(id)block{
    struct ZBBlockLiteral *blockRef = (__bridge struct ZBBlockLiteral *)block;
    ZBBlockDescriptionFlags _flags = blockRef->flags;
    if (_flags & ZBBlockDescriptionFlagsHasSignature) {
        void *signatureLocation = blockRef->descriptor;
        signatureLocation += sizeof(unsigned long int);
        signatureLocation += sizeof(unsigned long int);

        if (_flags & ZBBlockDescriptionFlagsHasCopyDispose) {
            signatureLocation += sizeof(void(*)(void *dst, void *src));
            signatureLocation += sizeof(void (*)(void *src));
        }

        const char *signature = (*(const char **)signatureLocation);
        return [NSMethodSignature signatureWithObjCTypes:signature];
    }
    return nil;
}

//(0x600003b81b90) JSLoginResponse - SetCode:
//SetCode:  (__NSCFString)06131l0008jiwO16pY100aRuOe031l0s
-(void) hk_requestCGI:(id) arg1 withResponse:(void(^)(id)) cbk{
    
    NSMethodSignature *sign = [NSObject getSignatureWithBlock:cbk];

        if (sign) {

            NSLog(@"----参数个数：%@", @(sign.numberOfArguments));
            NSLog(@"----返回值类型：%@", [NSString stringWithUTF8String:sign.methodReturnType]);
            for (int i=0; i<sign.numberOfArguments; i++) {
                NSLog(@"----第%@个参数：%@", @(i), [NSString stringWithUTF8String:[sign getArgumentTypeAtIndex:i]]);
            }
//            NSString *str1 = @"111";
//            NSString *str2 = @"111";
//            NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sign];
//            [inv setArgument:&str1 atIndex:1];
//            [inv setArgument:&str2 atIndex:2];
//            inv.target = cbk;
//            [inv invoke];
//            BOOL res;
//            [inv getReturnValue:&res];

//            NSLog(@"----返回结果：%@", @(res));

        }else {
            NSLog(@"------参数签名为空");
        }
    NSString *reqUrl = [arg1 performSelector:@selector(cgiUrl)];
    NSString *requestClassName = [arg1 performSelector:@selector(requestClassName)];
    NSString *responseClassName = [arg1 performSelector:@selector(responseClassName)];
    NSData *reqData = [arg1 performSelector:@selector(requestPb)];
    NSLog(@"reqUrl url: %@", reqUrl);
    
    [self hk_requestCGI:arg1 withResponse:^(id o1){
        NSString *reqUrl = [o1 performSelector:@selector(cgiUrl)];
        NSString *requestClassName = [o1 performSelector:@selector(requestClassName)];
        NSString *responseClassName = [o1 performSelector:@selector(responseClassName)];
        NSData *reqData = [o1 performSelector:@selector(requestPb)];
        NSLog(@"response url: %@", reqUrl);
        NSLog(@"requestClassName:%@ responseClassName:%@", requestClassName, responseClassName);
        
        if(cbk){
            cbk(o1);
        }
    }];
}
- (void)login_cxx_destruct{
    NSString *code = [self performSelector:@selector(code)];
    NSLog(@"login_cxx_destruct::: %@ \n", code );
    [self login_cxx_destruct];
}
- (void)hook_SetCode:(NSString*) code{
    
    NSLog(@"SetCode:::%@ \n ",code );
    [self hook_SetCode:code];
}

- (id)reqData{
    NSData *data =  [self reqData];
    NSString *str2 = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"req = %@ \n ",str2 );

    return data;
    
}
- (id)resData{
    NSData *data =  [self resData];
    NSString *str2 = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"resData = %@ \n ",str2 );

    return data;
    
}


@end
