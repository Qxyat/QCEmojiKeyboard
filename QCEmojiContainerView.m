//
//  CustomEmojiView.m
//  YYTextTest
//
//  Created by 邱鑫玥 on 16/1/10.
//  Copyright © 2016年 qiu. All rights reserved.
//

#import "QCEmojiContainerView.h"
#import <YYKit.h>
#import "YYImage+QCEmojiKeyboard.h"
#import "CustomUtilities.h"
@interface CustomEmojiContainerView ()
@property (strong,nonatomic)YYAnimatedImageView *imageView;
@end

@implementation CustomEmojiContainerView

-(id)initWithFrame:(CGRect)frame{
    if(self=[super initWithFrame:frame]){
        self.backgroundColor=[UIColor clearColor];
        _imageView=[[YYAnimatedImageView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame)-4, CGRectGetHeight(frame)-4)];
        _imageView.center=CGPointMake(CGRectGetWidth(frame)/2,CGRectGetHeight(frame)/2);
        [_imageView setContentMode:UIViewContentModeScaleAspectFit];
        [_imageView setBackgroundColor:[UIColor clearColor]];
        [self addSubview:_imageView];
    }
    return self;
}
-(void)setImageString:(NSString *)imageString{
    _imageString=[NSString stringWithFormat:@"[%@]",imageString];
    _imageView.image=[YYImage imageNamedFromEmojiBundleForEmojiKeyBoard:imageString];
}
-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch *touch=[touches anyObject];
    CGPoint point=[touch locationInView:self];
    if(CGRectContainsPoint(self.bounds, point)){
        if(_delegate!=nil){
            if([_imageString isEqualToString:@"[delete]"]){
                [_delegate deleteEmoji];
            }
            else{
                [_delegate addEmojiWithImage:(YYImage*)_imageView.image withImageString:_imageString];
            }
        }
    }
}
@end
