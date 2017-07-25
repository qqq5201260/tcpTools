//
//  ViewController.m
//  TCP推送测试版
//
//  Created by czl on 2017/7/4.
//  Copyright © 2017年 chinapke. All rights reserved.
//

#import "ViewController.h"
#import "TCPClient.h"
#import <SVProgressHUD.h>
#import "NSDate+FZKExtension.h"
#import "QrCodeTools.h"
#import "NSString+code.h"




@interface ViewController ()<ReceiveDataDelagate>
@property (weak, nonatomic) IBOutlet UITextField *ip;
@property (weak, nonatomic) IBOutlet UITextField *port;
@property (weak, nonatomic) IBOutlet UITextField *carImei;
@property (weak, nonatomic) IBOutlet UITextField *bleImei;
@property (weak, nonatomic) IBOutlet UITextView *sendText;
@property (weak, nonatomic) IBOutlet UITextView *receiveView;
@property (weak, nonatomic) IBOutlet UISwitch *aliveView;

@property (nonatomic,strong) NSMutableString *log;

@property (weak, nonatomic) IBOutlet UIImageView *codeImage;

@property (weak, nonatomic) IBOutlet UITextField *codeText;
@property (weak, nonatomic) IBOutlet UILabel *codeLabel;
@property (weak, nonatomic) IBOutlet UISwitch *sendNowSwitch;

@end

@implementation ViewController
{
    
    UIButton *btn;
    BOOL isSendNow;//是否立即发送
}

-(void)awakeFromNib{
    
    [super awakeFromNib];
    
}

#pragma mark - getter
- (NSMutableString *)log{
    
    if (!_log) {
        _log = [NSMutableString new];
    }
    return _log;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _ip.text = [[NSUserDefaults standardUserDefaults]objectForKey:@"ip"];
    _port.text = [[NSUserDefaults standardUserDefaults]objectForKey:@"port"];
    _carImei.text = [[NSUserDefaults standardUserDefaults]objectForKey:@"carImei"];
    _bleImei.text = [[NSUserDefaults standardUserDefaults]objectForKey:@"bleImei"];
    _codeText.text = [[NSUserDefaults standardUserDefaults]objectForKey:@"codeText"];
    isSendNow = _sendNowSwitch.on;
    // Do any additional setup after loading the view, typically from a nib.
}

/**
 配置默认地址
 
 @param sender
 */
- (IBAction)defaults:(id)sender {
    _ip.text = @"192.168.6.52";
    _port.text = @"2103";
}


/**
 上线离线
 
 @param sender <#sender description#>
 */
- (IBAction)onlineOrdis:(UIButton *)sender {
    
    btn = sender;
    
    
    if (!_ip.text || !_port.text || !_carImei.text ||[_ip.text isEqualToString:@""]||[_port.text isEqualToString:@""]||(_carImei.text.length<=14)) {
        [SVProgressHUD showInfoWithStatus:@"请输入ip，port，和主机imei至少15位"];
        return;
    }
    if([[TCPClient instanceShare]connectionState]){
        [[TCPClient instanceShare]sendCommand:[[self params] objectForKey:@"离线"]];
        [[TCPClient instanceShare]disConnection];
        
    }else{
        [self clearSend:nil];
        [self clearReceived:nil];
        self.aliveView.on = false;
        
        [TCPClient instanceShare].deledate = self;
        [[TCPClient instanceShare]connectionIP:_ip.text port:_port.text];

    }
    
}


/**
 绑定蓝牙
 
 @param sender
 */
- (IBAction)bindBle:(id)sender {
    if (_bleImei.text.length<=14) {
        [SVProgressHUD showInfoWithStatus:@"请输入正确蓝牙imei至少15位"];
        return;
    }
    [[TCPClient instanceShare]sendCommand:[NSString stringWithFormat:@"(1*f5|7|315,8_btu.CC2640.0_0113.release.0_BT_M_B1b.0.00_mac%@_300,|)",self.bleImei.text]];
    [[NSUserDefaults standardUserDefaults]setObject:_bleImei.text forKey:@"bleImei"];
}



#pragma mark - 控制相关
/**
 引擎
 
 @param sender <#sender description#>
 */
- (IBAction)engine:(id)sender {
    self.sendText.text = [[self params] objectForKey:@"引擎"];
    if (isSendNow) {
        [self send:nil];
    }
}


/**
 是否点击按钮就发送数据

 @param sender <#sender description#>
 */
- (IBAction)lijiSend:(UISwitch *)sender {
    
    isSendNow = sender.on;
}


/**
 门锁
 
 @param sender <#sender description#>
 */
- (IBAction)door:(id)sender {
    self.sendText.text = [[self params] objectForKey:@"门锁"];
    if (isSendNow) {
        [self send:nil];
    }
}


/**
 电压
 
 @param sender <#sender description#>
 */
- (IBAction)v:(UIButton *)sender {
    self.sendText.text = [[self params] objectForKey:@"电压"];
    if (isSendNow) {
        [self send:nil];
    }
}


/**
 速度
 
 @param sender <#sender description#>
 */
- (IBAction)speed:(id)sender {
    self.sendText.text = [[self params] objectForKey:@"速度"];
    if (isSendNow) {
        [self send:nil];
    }
}


/**
 温度
 
 @param sender <#sender description#>
 */
- (IBAction)c:(id)sender {
    self.sendText.text = [[self params] objectForKey:@"温度"];
    if (isSendNow) {
        [self send:nil];
    }
}


/**
 车窗
 
 @param sender <#sender description#>
 */
- (IBAction)Windows:(id)sender {
    self.sendText.text = [[self params] objectForKey:@"车窗"];
    if (isSendNow) {
        [self send:nil];
    }
    
}


/**
 GSM
 
 @param sender <#sender description#>
 */
- (IBAction)GSM:(id)sender {
    self.sendText.text = [[self params] objectForKey:@"GSM"];
    if (isSendNow) {
        [self send:nil];
    }
}


/**
 星数
 
 @param sender <#sender description#>
 */
- (IBAction)xingshu:(id)sender {
    self.sendText.text = [[self params] objectForKey:@"星数"];
    if (isSendNow) {
        [self send:nil];
    }
    
}


/**
 位置
 
 @param sender <#sender description#>
 */
- (IBAction)position:(id)sender {
    NSDate *date = [NSDate date];
    
   NSString *location = [NSString stringWithFormat:@"(1*b2|7|30d,11,%x,%x,%x,%x,%x,E,%d.7228,N,2937.1144,0,10,c,1,1,-1,79|)",date.month,date.day,date.hour,date.minute,date.second,arc4random()%9929+3000];
    self.sendText.text = location;
    if (isSendNow) {
        [self send:nil];
    }
    
}


/**
 能力
 
 @param sender <#sender description#>
 */
- (IBAction)canDo:(id)sender {
    self.sendText.text = [[self params] objectForKey:@"能力"];
    if (isSendNow) {
        [self send:nil];
    }
   
}


/**
 设防
 
 @param sender
 */
- (IBAction)set:(id)sender {
    
    self.sendText.text = [[self params] objectForKey:@"设防"];
    if (isSendNow) {
        [self send:nil];
    }
}


/**
 车门
 
 @param sender <#sender description#>
 */
- (IBAction)carwindow:(id)sender {
    self.sendText.text = [[self params] objectForKey:@"车门"];
    if (isSendNow) {
        [self send:nil];
    }
}


/**
 清空发送界面
 
 @param sender <#sender description#>
 */
- (IBAction)clearSend:(id)sender {
    self.sendText.text = @"请输入指令";
}


/**
 清空接收界面
 
 @param sender <#sender description#>
 */
- (IBAction)clearReceived:(id)sender {
    self.receiveView.text = @"接收界面";
    self.log = nil;
}
- (IBAction)alives:(UISwitch *)sender {
    if ([[TCPClient instanceShare]connectionState]) {
        [[TCPClient instanceShare]isStartAliert:sender.on];
    }else{
        sender.on = false;
    }
}

- (IBAction)send:(id)sender {
    if ([_sendText.text isEqualToString:@"请输入指令"]) {
        [SVProgressHUD showInfoWithStatus:@"发送界面输入不正确"];
        return;
    }
    [[TCPClient instanceShare]sendCommand:self.sendText.text];
}



#pragma mark 接收信息代理
- (void)getString:(NSString *)dataString{
    
    [self.log appendString:[NSString stringWithFormat:@"%@\n",dataString]];
    self.receiveView.text = self.log;
    CGFloat offset = self.receiveView.contentSize.height - self.receiveView.bounds.size.height;
    if (offset > 0)
    {
        [self.receiveView setContentOffset:CGPointMake(0, offset) animated:YES];
        
    }
    
}

- (void)getConState:(BOOL)iscontect{
     self.aliveView.on = false;
    if (iscontect) {
        [self clearSend:nil];
        [self clearReceived:nil];
       
        
        [[TCPClient instanceShare]sendCommand:[NSString stringWithFormat:@"(1*7c|a3|106,201|101,%@|102,460079241205511|103,898600D23113837|104,otu.ost,01022300|105,a1,18|622,a1c2|)",self.carImei.text]];
        
        [[NSUserDefaults standardUserDefaults]setObject:_ip.text forKey:@"ip"];
        [[NSUserDefaults standardUserDefaults]setObject:_port.text forKey:@"port"];
        [[NSUserDefaults standardUserDefaults]setObject:_carImei.text forKey:@"carImei"];
        
        [btn setTitle:@"离线" forState:UIControlStateNormal];
        
    }else{
        
      [btn setTitle:@"上线" forState:UIControlStateNormal];
    }
}

#pragma mark - 二维码相关
/**
 生成展车二维码

 @param sender <#sender description#>
 */
- (IBAction)zhancheCode:(id)sender {
    if (!self.codeText.text || self.codeText.text.length<9) {
        [SVProgressHUD showInfoWithStatus:@"请输入正确蓝牙IMEI"];
        return;
    }
    [[NSUserDefaults standardUserDefaults]setObject:_codeText.text forKey:@"codeText"];
    NSString *code = [NSString stringWithFormat:@"%@_%@%@_0_copyright@sirui ChungKing",self.codeText.text,[self.codeText.text substringFromIndex:self.codeText.text.length-6],[self.codeText.text substringFromIndex:self.codeText.text.length-2]];
    NSString *newCode = [NSString stringWithFormat:@"exhibition_%@",[NSString base64StringFromText:code]];
    NSLog(@"oldCode:%@\n newCode:%@",code,newCode);
    [self initErCodeWithString:newCode];
}



/**
 生成普通二维码

 @param sender <#sender description#>
 */
- (IBAction)normalCode:(id)sender {
    if (!self.codeText.text || self.codeText.text.length<=14) {
        [SVProgressHUD showInfoWithStatus:@"请输入正确蓝牙imei至少15位"];
        return;
    }
    [[NSUserDefaults standardUserDefaults]setObject:_codeText.text forKey:@"codeText"];
    NSString *code = [NSString stringWithFormat:@"%@_%@_0_copyright@sirui ChungKing",self.codeText.text,[self.codeText.text substringWithRange:NSMakeRange(4, self.codeText.text.length-4-4)]];
    NSString *newCode = [NSString stringWithFormat:@"exhibition_%@",[NSString base64StringFromText:code]];
    NSLog(@"oldCode:%@\n newCode:%@",code,newCode);
    
    [self initErCodeWithString:newCode];
}


- (IBAction)clearCoce:(id)sender {
    self.codeImage.image = nil;
    self.codeText.text = @"";
    self.codeLabel.hidden = NO;
}



-(void)initErCodeWithString:(NSString *)dataString{
    
    self.codeLabel.hidden = YES;
    
    self.codeImage.layer.shadowOffset = CGSizeMake(0, 0.5);          // 设置阴影的偏移量
    
    self.codeImage.layer.shadowRadius = 1;  // 设置阴影的半径
    
    self.codeImage.layer.shadowColor = [UIColor     blackColor].CGColor; // 设置阴影的颜色为黑色
    
    self.codeImage.layer.shadowOpacity = 0.3; // 设置阴影的不透明度
    
    self.codeImage.image = [QrCodeTools initErCodeWithString:dataString size:self.codeImage.frame.size.width];
    
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{

    [self.view endEditing:YES];
}

- (NSDictionary *)params{
    
    int i = arc4random_uniform(3);
    
    return @{@"引擎":[NSString stringWithFormat:@"(1*12|7|302,%d,11,1)",i],
             @"门锁":[NSString stringWithFormat:@"(1*33|7|305,%d,2222|)",i],
             @"电压":[NSString stringWithFormat:@"(1*88|7|316,1,%d,4%d0,4F0|)",i,i],
             @"温度":[NSString stringWithFormat:@"(1*33|7|30B,%d,E0|)",i*15],
             @"GSM":[NSString stringWithFormat:@"(1*74|7|30f,%d,333e,331a,GSM850_EGSM_DCS_PCS_MODE|)",i*5],
             @"星数":[NSString stringWithFormat:@"(1*33|7|30C,1,1,%d,%d,1|)",i,i],
             @"设防":[NSString stringWithFormat:@"(1*a7|7|308,%d,1|)",i],
             @"速度":[NSString stringWithFormat:@"(1*88|7|31a,1,1,%d|)",i*5+50],
             @"车窗":[NSString stringWithFormat:@"(1*88|7|317,%d,11111|)",i],
             @"车门":[NSString stringWithFormat:@"(1*33|7|304,%d,11111|)",i],
             @"离线":@"(1*67|7|10c,100,100,100,100,100,100,100,100,100,100,100,100,100|)",
             @"能力":@"(1*67|7|10c,100,100,100,100,100,100,100,100,100,100,100,100,100|)"};
}
@end
