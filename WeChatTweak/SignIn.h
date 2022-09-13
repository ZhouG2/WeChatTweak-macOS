//
//  SignIn.h
//  WeChatTweak
//
//  Created by ZhouGang on 2022/9/10.
//  Copyright © 2022 Sunnyyoung. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SignIn : NSObject
+ (instancetype)sharedInstance;
-(void) signIn;
@end

NS_ASSUME_NONNULL_END
