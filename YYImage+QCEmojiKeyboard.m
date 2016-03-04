//
//  YYImage+Custom.m
//  YYTextTest
//
//  Created by 邱鑫玥 on 16/1/11.
//  Copyright © 2016年 qiu. All rights reserved.
//

#import "YYImage+QCEmojiKeyboard.h"

@implementation YYImage (QCEmojiKeyboard)

+(YYImage *)imageNamedFromEmojiBundleForEmojiKeyBoard:(NSString*)imageName{
    if(![imageName isEqualToString:@"delete"]){
        NSString *bundlePath=[[NSBundle mainBundle].resourcePath stringByAppendingPathComponent:@"Emoji.bundle"];
        NSBundle *bundle=[NSBundle bundleWithPath:bundlePath];
        return [YYImage imageWithContentsOfFile:[bundle pathForResource:imageName ofType:@"gif"]];
    }
    else
        return [YYImage imageNamed:@"emojikeyboarddelete"];
}

@end
