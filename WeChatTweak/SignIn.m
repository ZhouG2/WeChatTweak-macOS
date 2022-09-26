//
//  SignIn.m
//  WeChatTweak
//
//  Created by ZhouGang on 2022/9/10.
//  Copyright © 2022 Sunnyyoung. All rights reserved.
//

#import "SignIn.h"
#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>

@implementation SignIn

static void __attribute__((constructor)) signin(void) {
    
    NSLog(@"###:signin  constructor");
    

//    [[[NSWorkspace sharedWorkspace]notificationCenter] addObserverForName:NSWorkspaceDidWakeNotification object:NULL queue:NULL usingBlock: ^(NSNotification* note){
//
//    }];
//
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:SignIn.sharedInstance
                selector: @selector(receiveWakeNote:)
                name: NSWorkspaceDidWakeNotification object: NULL];
   
}
- (void) onDPLink{
    
}
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static SignIn *shared;
    dispatch_once(&onceToken, ^{
        shared = [[SignIn alloc] init];
        NSTimer *t =  [NSTimer scheduledTimerWithTimeInterval:4*3600 repeats:true block:^(NSTimer *timer){
            [shared signIn];
        }];
        [[NSRunLoop currentRunLoop] addTimer:t forMode:NSDefaultRunLoopMode];
    });
    return shared;
}
- (NSString *) getDataFrom:(NSString *)url{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:@"GET"];
    [request setURL:[NSURL URLWithString:url]];

    NSError *error = nil;
    NSHTTPURLResponse *responseCode = nil;

    NSData *oResponseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&responseCode error:&error];

    if([responseCode statusCode] != 200){
        NSLog(@"Error getting %@, HTTP status code %i", url, [responseCode statusCode]);
        return nil;
    }

    return [[NSString alloc] initWithData:oResponseData encoding:NSUTF8StringEncoding];
}


//同步post
-(NSString *)postSyn:(NSString *)urlStr Data:(NSString *) data contentType:(NSString *)typ{
    NSLog(@"post_begin");
      
    NSData* postData = [data dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];//数据转码;
    NSString *length = [NSString stringWithFormat:@"%d", [postData length]];
      
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc]init];
    [request setURL:[NSURL URLWithString:urlStr]]; //设置地址
    [request setHTTPMethod:@"POST"]; //设置发送方式
    [request setTimeoutInterval: 20]; //设置连接超时
    [request setValue:length forHTTPHeaderField:@"Content-Length"]; //设置数据长度
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"]; //设置发送数据的格式
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"]; //设置预期接收数据的格式
    [request setHTTPBody:postData]; //设置编码后的数据
      
    //发起连接，接受响应
    NSHTTPURLResponse* urlResponse = nil;
    NSError *error = [[NSError alloc] init] ;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request
                                                 returningResponse:&urlResponse
                                                             error:&error];
    NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]; //返回数据，转码
      
    NSLog(responseString);
    NSLog(@"post_end");
    return responseString;
}
static int retryCount = 0;
-(void) signIn{
    
    
    
    Class cls = NSClassFromString(@"CUtility");
    NSString *user = [cls performSelector:NSSelectorFromString(@"GetCurrentUserName")];
    if(user == nil || [user isEqualToString:@""]){
        NSLog(@"用户名为空!!!");
        return;
    }
    NSString *key = [user stringByAppendingString:@"llsssd"];
    
    NSInteger lastDay = [[NSUserDefaults standardUserDefaults] integerForKey:key];
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
    NSInteger day = [components day];
    if(day == lastDay){
        NSLog(@"今天已经签到!!");
        return ;
    }
    [self getCode:@"wxa248624e3a00de92" withRespose:^(NSString *code){
        NSLog(@"code:::%@", code);
        if([code isEqualToString:@"error"]){
            [NSThread sleepForTimeInterval:2];
            NSLog(@"retry count:%d", ++retryCount);
            if(retryCount < 10)
                return [self signIn];
        }
        NSString * url = [NSString stringWithFormat:@"https://s.ziot.fun/s?c=%@", code];
//        {"data":{"code":"415","content":null,"msg":"今日已签到，请明天再来！"}
//        {"data":{"code":"200","content":"{\"coupons\":null,\"prizeType\":1,\"scoreValue\":1.00}","msg":"success"}
        NSString *rlt = [self getDataFrom:url];
        NSLog(@"SignIn:::%@", rlt);
        if(([rlt containsString:@"scoreValue"] && [rlt containsString:@"\"msg\":\"success\""])
           || [rlt containsString:@"今日已签到"]){
            [[NSUserDefaults standardUserDefaults] setInteger:day forKey:key];
        }
        
    }];
}
- (void) getCode:(NSString *) appid withRespose:(void(^)(NSString *code)) cbk{
    Class cls = NSClassFromString(@"WAIPCCgiWrap");
    
    id cw = [[cls alloc] init];
    [cw performSelector:NSSelectorFromString(@"setCgiUrl:") withObject:@"/cgi-bin/mmbiz-bin/js-login"];
    [cw performSelector:NSSelectorFromString(@"setResponseClassName:") withObject:@"JSLoginResponse"];
    [cw performSelector:NSSelectorFromString(@"setRequestClassName:") withObject:@"JSLoginRequest"];
    
    [cw performSelector:NSSelectorFromString(@"setRequestClassName:") withObject:@"JSLoginRequest"];
    
//    0x600003b30cd0: 0a 00 12 12 77 78 61 32 34 38 36 32 34 65 33 61  ....wxa248624e3a
//    0x600003b30ce0: 30 30 64 65 39 32 20 01 38 00 42 03 10 d0 08     00de92 .8.B....
    char head[] = {0x0a,0x00,0x12,0x12};
    char tail[] = {0x20,0x01,0x38,0x00,0x42,0x03,0x10,0xd0,0x08};
    NSMutableData *data = [NSMutableData dataWithCapacity:50];
    [data appendBytes:head length:sizeof(head)];
    [data appendData:[appid dataUsingEncoding:NSASCIIStringEncoding]];
    [data appendBytes:tail length:sizeof(tail)];

    
    [cw performSelector:NSSelectorFromString(@"setRequestPb:") withObject:data];
    
//    [cw performSelector:NSSelectorFromString() withObject:[NSNumber numberWithInteger:1029]];
    
    SEL selector = NSSelectorFromString(@"setM_functionId:");
    NSMethodSignature *signature = [cw methodSignatureForSelector:selector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    [invocation setSelector:selector];
    int x = 1029;
    [invocation setArgument:&x atIndex:2]; // 0 and 1 are reserved
   
    [invocation invokeWithTarget:cw];
    
    
    id iws = [[NSClassFromString(@"WAIPCServer") alloc] init];
    
    [iws performSelector:NSSelectorFromString(@"requestCGI:withResponse:") withObject:cw withObject:^(id o1){
        
        NSData *rb = [o1 performSelector:NSSelectorFromString(@"responsePb")];
        char *pb = [rb bytes];
        char *ps = NULL;
        for(int i=0;i<[rb length];i++){
            if(pb[i]=='o' && pb[i+1] == 'k' && pb[i+2] == 0x1a && pb[i+3] == 0x20){
                ps = pb + i + 4;
            }
            if(pb[i] == 'Z' && pb[i+1] == 0){
                pb[i] = 0;
                break;
            }
        }
        if(ps){
            NSString *code = [NSString stringWithCString:ps encoding:NSASCIIStringEncoding];
            cbk(code);
        }
        else
            cbk(@"error");
        
    }];
}

- (void) receiveWakeNote: (NSNotification*) note
{
    retryCount = 0;
    NSLog(@"receiveWakeNote: %@", [note name]);
//    [[NSApp  mainWindow] makeKeyAndOrderFront:nil];
//    [NSApp setActivationPolicy:<#(NSApplicationActivationPolicy)#>]
    
    //dispatch_time_t参数
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, (ino64_t)(2 * NSEC_PER_SEC));

    //dispatch_queue_t参数
    dispatch_queue_t queue = dispatch_get_main_queue();//主队列

    //dispatch_after函数
    dispatch_after(time, queue, ^{
        [self signIn];
    });
    
}



@end
