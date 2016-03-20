//
//  CustomEmojiKeyboard.h
//  YYTextTest
//
//  Created by 邱鑫玥 on 16/1/10.
//  Copyright © 2016年 qiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QCEmojiKeyboardDelegate.h"

@interface QCEmojiKeyboard : UIView<UIScrollViewDelegate>

@property (weak,nonatomic) id<QCEmojiKeyboardDelegate> delegate;

+(instancetype)sharedQCEmojiKeyboard;

@end
