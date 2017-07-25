//
//  QrCodeTools.h
//  tcpTest
//
//  Created by czl on 2017/7/4.
//  Copyright © 2017年 chinapke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface QrCodeTools : NSObject



/**
 生成高清二维码

 @param ciImage <#ciImage description#>
 @param widthAndHeight <#widthAndHeight description#>
 @return <#return value description#>
 */
+(UIImage *)initErCodeWithString:(NSString *)dataString size:(CGFloat)widthAndHeight;


/**
 生成普通清晰二维码

 @param dataString <#dataString description#>
 @return <#return value description#>
 */
+(UIImage *)generaterSmallErcode:(NSString *)dataString;
@end
