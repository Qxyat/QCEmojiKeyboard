//
//  CustomEmojiView.m
//  YYTextTest
//
//  Created by 邱鑫玥 on 16/1/10.
//  Copyright © 2016年 qiu. All rights reserved.
//

#import "QCEmojiCell.h"
#import "YYImage+QCEmojiKeyboard.h"
#import <YYKit.h>

@interface QCEmojiCell ()

@property (strong,nonatomic)YYAnimatedImageView *imageView;

@end

@implementation QCEmojiCell

-(id)initWithFrame:(CGRect)frame{
    if(self=[super initWithFrame:frame]){
        self.backgroundColor=[UIColor clearColor];
        _imageView=[[YYAnimatedImageView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame)-4, CGRectGetHeight(frame)-4)];
        _imageView.center=CGPointMake(CGRectGetWidth(frame)/2,CGRectGetHeight(frame)/2);
        _imageView.contentMode=UIViewContentModeScaleAspectFit;
        _imageView.backgroundColor=[UIColor clearColor];
        [self.contentView addSubview:_imageView];
    }
    return self;
}

-(void)setImageString:(NSString *)imageString{
    if(imageString==nil){
        _imageString=nil;
        _image=nil;
        _imageView.image=_image;
        return;
    }
    _imageString=[NSString stringWithFormat:@"[%@]",imageString];
    _image=[YYImage imageNamedFromEmojiBundleForEmojiKeyBoard:imageString];
    _imageView.image=_image;
}
@end
