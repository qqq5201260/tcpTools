//
//  TCPClient.m
//  TCP_ControlTest
//
//  Created by czl on 2017/7/3.
//  Copyright © 2017年 chinapke. All rights reserved.
//

#import "TCPClient.h"
#import <CocoaAsyncSocket/GCDAsyncSocket.h>
#import <SVProgressHUD.h>
@interface TCPClient ()<GCDAsyncSocketDelegate>

@property (nonatomic,strong) GCDAsyncSocket *asyncSocket;

@property (nonatomic,strong) NSTimer *timer;

@end

@implementation TCPClient
{

    NSString *_ip;
    uint16_t _port;
}
//单利
+(TCPClient *)instanceShare{
    static TCPClient *manager = nil;
    static dispatch_once_t token;
    dispatch_once(&token,^{
        if(manager == nil){
            manager = [[TCPClient alloc]init];
           
        }
    } );
    return manager;
}






/**
 //连接TCP
 
 @param userNameEncode rsa加密后用户名
 @param userPwdEncode rsa加密后密码
 */
- (void)connectionIP:(NSString *)ip port:(NSString *)port{

    _ip = ip;
    _port = [port intValue];
//    dispatch_async(dispatch_get_main_queue(), ^{

        [self.asyncSocket connectToHost:_ip onPort:_port withTimeout:15 error:nil];
//    });
}

//连接状态
- (BOOL)connectionState{

    return _asyncSocket.isConnected;
}

//断开TCP
- (void)disConnection{
    [_asyncSocket disconnect];
}

//用户外部发送TCP控制指令 蓝牙调试回显 发送蓝牙状态
- (void)sendCommand:(NSString *)cmd{
    if (_asyncSocket.isConnected) {
        NSData *data = [cmd dataUsingEncoding:NSUTF8StringEncoding];
        [_asyncSocket writeData:data withTimeout:-1 tag:0];
    }else{
    
        [SVProgressHUD showInfoWithStatus:@"请点击上线，才可以发送"];
    }
 
}

#pragma mark - getter
- (GCDAsyncSocket *)asyncSocket{

    if (!_asyncSocket) {
        _asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self
                                                 delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    }
    return _asyncSocket;
}

- (NSTimer *)timer{
    
    if (!_timer) {
        
        _timer = [NSTimer timerWithTimeInterval:30.0f target:self selector:@selector(alikit) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
    return _timer;
}

#pragma mark -GCDAsyncSocketdelegate
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port{
    if ([self.deledate respondsToSelector:@selector(getConState:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.deledate getConState:YES];}
                );
    }
    NSLog(@"连接成功");
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    NSLog(@"socketDidDisconnect:%p withError: %@", sock, err);
    if ([self.deledate respondsToSelector:@selector(getConState:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.deledate getConState:NO];
        });
    }
}

- (void)socketDidSecure:(GCDAsyncSocket *)sock {
    [_asyncSocket readDataWithTimeout:-1 tag:0];
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    [_asyncSocket readDataWithTimeout:-1 tag:tag];
}


- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    [_asyncSocket readDataWithTimeout:-1 tag:0];
    
    NSString *parseStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    if ([self.deledate respondsToSelector:@selector(getString:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
             [self.deledate getString:parseStr];
        });
       
    }
    
    [self receive:parseStr];
    
}


- (void)receive:(NSString *)receiveString{

//    return;
//    NSPredicate *cate = [NSPredicate predicateWithFormat:@"SELF MATCHES '(*\\w\\w|7|\\d\\d\\w,\\w*?,1|)'"];
    
    if ([receiveString hasSuffix:@",1|)"] && [receiveString hasPrefix:@"(*"] && receiveString.length>10) {
        
        int cmd = [[receiveString substringWithRange:NSMakeRange(7, 3)] intValue];
        NSString *rectStr = [[self receiDic] objectForKey:@(cmd).description];
      
        NSString *a = [NSString stringWithFormat:@"(1%@8%@",[receiveString substringWithRange:NSMakeRange(1, 4)],[receiveString substringFromIndex:6]] ;
        [self.asyncSocket writeData:[a dataUsingEncoding:NSUTF8StringEncoding] withTimeout:15 tag:0];
        
        
        NSString *b = [NSString stringWithFormat:@"%@7|4%@1,1|)",[a substringToIndex:6],[a substringWithRange:NSMakeRange(9, 3)]];
        [self.asyncSocket writeData:[b dataUsingEncoding:NSUTF8StringEncoding] withTimeout:15 tag:0];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.deledate getString:[NSString stringWithFormat:@"%@:%@",rectStr,a]];
            [self.deledate getString:[NSString stringWithFormat:@"%@:%@",rectStr,b]];
        });
        
        
    }
    
    
    
}

- (NSDictionary *)receiDic{

    return @{
        @"511":@"上锁",@"512":@"解锁",@"513":@"寻车",@"514":@"静音",@"515":@"点火",
        @"516":@"熄火",@"517":@"关门窗",@"518":@"开门窗",@"519":@"关天窗",@"51A":@"开天窗",
        @"51B":@"通油",@"51C":@"断油"
    };
}

- (void)isStartAliert:(BOOL) isStart{

    if (isStart) {
        [self.timer fire];
    }else{
    
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)alikit{

    
        if(!_ip || !_port)return;
        if ([self connectionState]) {
            [self.asyncSocket writeData:[@"()" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [_asyncSocket connectToHost:_ip onPort:_port withTimeout:15 error:nil];
            });
        }
        
        
    
}

@end
