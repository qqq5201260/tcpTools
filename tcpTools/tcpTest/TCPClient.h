//
//  TCPClient.h
//  TCP_ControlTest
//
//  Created by czl on 2017/7/3.
//  Copyright © 2017年 chinapke. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ReceiveDataDelagate <NSObject>

- (void)getString:(NSString *)dataString;

- (void)getConState:(BOOL)iscontect;

@end

@interface TCPClient : NSObject

//单利
+(TCPClient *)instanceShare;






/**
 //连接TCP
 
 @param userNameEncode rsa加密后用户名
 @param userPwdEncode rsa加密后密码
 */
- (void)connectionIP:(NSString *)ip port:(NSString *)port;

//连接状态
- (BOOL)connectionState;

//断开TCP
- (void)disConnection;

//用户外部发送TCP控制指令 蓝牙调试回显 发送蓝牙状态
- (void)sendCommand:(NSString *)cmd;

@property (nonatomic,weak) id<ReceiveDataDelagate> deledate;


/**
 是否开启心跳包
 */
- (void)isStartAliert:(BOOL) isStart;



@end
