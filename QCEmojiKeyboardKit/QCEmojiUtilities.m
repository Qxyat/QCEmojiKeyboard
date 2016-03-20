//
//  QCEmojiUtilities.m
//  bupt
//
//  Created by 邱鑫玥 on 16/3/7.
//  Copyright © 2016年 qiu. All rights reserved.
//

#import "QCEmojiUtilities.h"

@implementation QCEmojiUtilities

#pragma mark - 根据颜色代码获得颜色
+(UIColor*) getColor:(NSString *) hexColor
{
    unsigned int red,green,blue;
    NSRange range;
    
    range.length = 2;
    
    range.location = 0;
    [[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&red];
    
    range.location = 2;
    [[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&green];
    
    range.location = 4;
    [[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&blue];
    
    return [UIColor colorWithRed:(float)(red/255.0f) green:(float)(green / 255.0f) blue:(float)(blue / 255.0f) alpha:1.0f];
}

@end
