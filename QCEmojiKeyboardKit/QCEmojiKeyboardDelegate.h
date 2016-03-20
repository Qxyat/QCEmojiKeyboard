//
//  kCustomEmojiKeyboardDelegate.h
//  YYTextTest
//
//  Created by 邱鑫玥 on 16/1/11.
//  Copyright © 2016年 qiu. All rights reserved.
//

#import <Foundation/Foundation.h>

@class YYImage;

@protocol QCEmojiKeyboardDelegate <NSObject>

-(void)addEmojiWithImage:(YYImage*)image
         withImageString:(NSString *)imageString;

-(void)deleteEmoji;

@end
