//
//  CustomEmojiKeyboard.m
//  YYTextTest
//
//  Created by 邱鑫玥 on 16/1/10.
//  Copyright © 2016年 qiu. All rights reserved.
//

#import "QCEmojiKeyboard.h"
#import "QCEmojiContainerView.h"
#import "CustomUtilities.h"

#define kCustomScreenWidth [UIScreen mainScreen].bounds.size.width
#define kNumsOfClassicsEmoji    73
#define kNumsOfYouxihouEmoji    42
#define kNumsOfTusijiEmoji      25
#define kNumsOfYangcongtouEmoji 59
#define kPageControlHeight      10
#define kToolbarHeight          36

static CGFloat   kContainerViewMargin;
static CGFloat   kContainerViewWidthInOnePage;
static CGFloat   kContainerViewHeightInOnePage;
static NSInteger kRowCountForClassicsEmojiInOnePage;
static NSInteger kColCountForClassicsEmojiInOnePage;
static NSInteger kRowCountForOtherEmojiInOnePage;
static NSInteger kColCountForOtherEmojiInOnePage;
static CGFloat   kClassicsEmojiContainerViewWidth;
static CGFloat   kClassicsEmojiContainerViewHeight;
static CGFloat   kOtherEmojiContainerViewWidth;
static CGFloat   kOtherEmojiContainerViewHeight;
static NSInteger kNumsOfPageForClassicsEmoji;
static NSInteger kNumsOfPageForYouxihouEmoji;
static NSInteger kNumsOfPageForTusijiEmoji;
static NSInteger kNumsOfPageForYangcongtouEmoji;
static NSInteger kNumsOfPageForAllEmojiSets;

@interface QCEmojiKeyboard ()

@property (strong,nonatomic)UIView* toolbar;
@property (strong,nonatomic)UIPageControl *pageControl;
@property (strong,nonatomic)UIScrollView *scrollView;
@property (strong,nonatomic)NSArray *toolbarbuttons;

@end

@implementation QCEmojiKeyboard

-(id)initWithFrame:(CGRect)frame{
    [self preCaluate];
    frame.size.height=kToolbarHeight+kPageControlHeight+2*kContainerViewMargin+kContainerViewHeightInOnePage;
    frame.size.width=kCustomScreenWidth;
    if(self=[super initWithFrame:frame]){
        self.backgroundColor=[UIColor whiteColor];
        
        [self _initScrollView];
        [self _initPageControl];
        [self _initToolbar];
        
        [self refreshPageControlAndTabbar:0];
    }
    return self;
}
-(void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    CGContextRef context=UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 1.0);
    CGContextSetStrokeColorWithColor(context, [CustomUtilities getColor:@"bfbfbf"].CGColor);
    CGContextMoveToPoint(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGContextAddLineToPoint(context, CGRectGetMaxX(rect), CGRectGetMinY(rect));
    CGContextStrokePath(context);
    
}
-(void)preCaluate{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if(kCustomScreenWidth==320){
            kContainerViewWidthInOnePage=300;
            kColCountForOtherEmojiInOnePage=7;
        }
        else if(kCustomScreenWidth==375){
            kContainerViewWidthInOnePage=360;
            kColCountForOtherEmojiInOnePage=8;
        }
        else if(kCustomScreenWidth==414){
            kContainerViewWidthInOnePage=400;
            kColCountForOtherEmojiInOnePage=9;
        }
        kContainerViewMargin=(kCustomScreenWidth-kContainerViewWidthInOnePage)/2;
        kRowCountForOtherEmojiInOnePage=3;
        kRowCountForClassicsEmojiInOnePage=kRowCountForOtherEmojiInOnePage;
        kColCountForClassicsEmojiInOnePage=kColCountForOtherEmojiInOnePage+1;
        kClassicsEmojiContainerViewWidth=kContainerViewWidthInOnePage/kColCountForClassicsEmojiInOnePage;
        kClassicsEmojiContainerViewHeight=kClassicsEmojiContainerViewWidth;
        kOtherEmojiContainerViewWidth=kContainerViewWidthInOnePage/kColCountForOtherEmojiInOnePage;
        kOtherEmojiContainerViewHeight=kOtherEmojiContainerViewWidth;
        kContainerViewHeightInOnePage=kRowCountForOtherEmojiInOnePage*kOtherEmojiContainerViewHeight;
        
        //计算一页能显示多少个经典表情，并且需要多少页
        {
            NSInteger nums=kRowCountForClassicsEmojiInOnePage*kColCountForClassicsEmojiInOnePage-1;
            kNumsOfPageForClassicsEmoji=kNumsOfClassicsEmoji/nums+(kNumsOfClassicsEmoji%nums==0?0:1);
        }
        //计算一页能显示多少个悠嘻猴表情，并且需要多少页
        {
            NSInteger nums=kRowCountForOtherEmojiInOnePage*kColCountForOtherEmojiInOnePage-1;
            kNumsOfPageForYouxihouEmoji=kNumsOfYouxihouEmoji/nums+(kNumsOfYouxihouEmoji%nums==0?0:1);
        }
        //计算一页能显示多少个兔斯基表情，并且需要多少页
        {
            NSInteger nums=kRowCountForOtherEmojiInOnePage*kColCountForOtherEmojiInOnePage-1;
            kNumsOfPageForTusijiEmoji=kNumsOfTusijiEmoji/nums+(kNumsOfTusijiEmoji%nums==0?0:1);
        }
        //计算一页能显示多少个洋葱头表情，并且需要多少页
        {
            NSInteger nums=kRowCountForOtherEmojiInOnePage*kColCountForOtherEmojiInOnePage-1;
            kNumsOfPageForYangcongtouEmoji=kNumsOfYangcongtouEmoji/nums+(kNumsOfYangcongtouEmoji%nums==0?0:1);
        }
        kNumsOfPageForAllEmojiSets=kNumsOfPageForClassicsEmoji+kNumsOfPageForYouxihouEmoji+kNumsOfPageForTusijiEmoji+kNumsOfPageForYangcongtouEmoji;
    });
}


#pragma mark - 初始化各个view
-(void)_initScrollView{
    _scrollView=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, kCustomScreenWidth, 2*kContainerViewMargin+kContainerViewHeightInOnePage)];
    _scrollView.contentSize=CGSizeMake(kNumsOfPageForAllEmojiSets*CGRectGetWidth(self.scrollView.frame), CGRectGetHeight(_scrollView.frame));
    _scrollView.pagingEnabled=YES;
    _scrollView.showsHorizontalScrollIndicator=NO;
    _scrollView.showsVerticalScrollIndicator=NO;
    _scrollView.delegate=self;
    _scrollView.backgroundColor=[UIColor clearColor];
    
    for(int i=0;i<kNumsOfPageForAllEmojiSets;i++){
        [self loadScrollViewPage:i];
    }
    
    [self addSubview:_scrollView];
}

-(void)_initPageControl{
    _pageControl=[[UIPageControl alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_scrollView.frame), kCustomScreenWidth, kPageControlHeight)];
    _pageControl.numberOfPages=3;
    [_pageControl setPageIndicatorTintColor:[UIColor lightGrayColor]];
    [_pageControl setCurrentPageIndicatorTintColor:[UIColor grayColor]];
    _pageControl.userInteractionEnabled=NO;
    _pageControl.backgroundColor=[UIColor clearColor];
    [self addSubview:_pageControl];
}

-(void)_initToolbar{
    NSArray *buttonTitles=@[@"经典",@"悠嘻猴",@"兔斯基",@"洋葱头"];
    _toolbar = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_pageControl.frame), kCustomScreenWidth, kToolbarHeight)];
    
    UIImageView *bg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_toolbar.frame), CGRectGetHeight(_toolbar.frame))];
    bg.image=[UIImage imageNamed:@"emojitoobarbackground"];
    [_toolbar addSubview:bg];
    
    UIScrollView *scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_toolbar.frame), CGRectGetHeight(_toolbar.frame))];
    scroll.showsHorizontalScrollIndicator = NO;
    scroll.alwaysBounceHorizontal = YES;
    scroll.contentSize = _toolbar.frame.size;
    [_toolbar addSubview:scroll];
    
    NSMutableArray *btns = [NSMutableArray new];
    UIButton *btn;
    for (NSUInteger i = 0; i < 4; i++){
        btn = [self _createToolbarButton:i];
        [btn setTitle:buttonTitles[i] forState:UIControlStateNormal];
        btn.tag = i;
        [scroll addSubview:btn];
        [btns addObject:btn];
    }
    _toolbarbuttons=btns;
    
    [self addSubview:_toolbar];
}
- (UIButton *)_createToolbarButton:(NSInteger)index{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame=CGRectMake(kCustomScreenWidth/4.f*index, 0, kCustomScreenWidth/4.f, kToolbarHeight);
    btn.exclusiveTouch = YES;
    
    btn.titleLabel.font = [UIFont systemFontOfSize:14];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setTitleColor:[CustomUtilities getColor:@"5D5C5A"] forState:UIControlStateSelected];
    
    UIImage *img;
    img = [UIImage imageNamed:@"emojitoolbarnormal"];
    img = [img resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, img.size.width - 1) resizingMode:UIImageResizingModeStretch];
    [btn setBackgroundImage:img forState:UIControlStateNormal];
    
    img = [UIImage imageNamed:@"emojitoolbarselected"];
    img = [img resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, img.size.width - 1) resizingMode:UIImageResizingModeStretch];
    [btn setBackgroundImage:img forState:UIControlStateSelected];

    [btn addTarget:self action:@selector(_toolbarBtnDidTapped:) forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

- (void)_toolbarBtnDidTapped:(UIButton *)item {
    NSInteger page=0;
    if(item.tag==0){
        page=0;
    }
    else if(item.tag==1){
        page=kNumsOfPageForClassicsEmoji;
    }
    else if(item.tag==2){
        page=kNumsOfPageForClassicsEmoji+kNumsOfPageForYouxihouEmoji;
    }
    else if(item.tag==3){
        page=kNumsOfPageForClassicsEmoji+kNumsOfPageForYouxihouEmoji+kNumsOfPageForTusijiEmoji;
    }
    [self scrollToPage:page];
}

#pragma mark - 实现UIScrollViewDelegate协议
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    NSInteger page=(int)self.scrollView.contentOffset.x/(int)CGRectGetWidth(_scrollView.frame);
    [self refreshPageControlAndTabbar:page];
}


#pragma mark - 加载某一页
-(void)loadScrollViewPage:(NSInteger)page{
    UIView *view=[[UIView alloc]initWithFrame:CGRectMake(page*CGRectGetWidth(_scrollView.frame), 0, CGRectGetWidth(_scrollView.frame), CGRectGetHeight(_scrollView.frame))];
    UIView *containerView=[[UIView alloc]initWithFrame:CGRectMake(kContainerViewMargin, kContainerViewMargin, kContainerViewWidthInOnePage, kContainerViewHeightInOnePage)];
    
    NSInteger rowCountForEmojiInOnePage=0;
    NSInteger colCountForEmojiInOnePage=0;
    NSInteger numsOfEmojiInOnePage=0;
    NSInteger pageIndexForCurrentEmojiSet=0;
    NSInteger emojiIndexOffsetForCurrentEmojiSet=0;
    NSInteger emojiIndexOffsetForCurrentEmojiSetModify=0;
    NSInteger totalNumsOfEmoji=0;
    NSString *emojiStringFomrat=nil;
    CGFloat emojiContainerViewWidth=0;
    CGFloat emojiContainerViewHeight=0;
    
    if(page<kNumsOfPageForClassicsEmoji){
        rowCountForEmojiInOnePage=kRowCountForClassicsEmojiInOnePage;
        colCountForEmojiInOnePage=kColCountForClassicsEmojiInOnePage;
        numsOfEmojiInOnePage=rowCountForEmojiInOnePage*colCountForEmojiInOnePage-1;
        pageIndexForCurrentEmojiSet=page;
        emojiIndexOffsetForCurrentEmojiSet=pageIndexForCurrentEmojiSet*numsOfEmojiInOnePage;
        emojiIndexOffsetForCurrentEmojiSetModify=0;
        totalNumsOfEmoji=kNumsOfClassicsEmoji;
        emojiStringFomrat=@"em%d";
        emojiContainerViewWidth=kClassicsEmojiContainerViewWidth;
        emojiContainerViewHeight=kClassicsEmojiContainerViewHeight;
    }
    else if(page<kNumsOfPageForClassicsEmoji+kNumsOfPageForYouxihouEmoji){
        rowCountForEmojiInOnePage=kRowCountForOtherEmojiInOnePage;
        colCountForEmojiInOnePage=kColCountForOtherEmojiInOnePage;
        numsOfEmojiInOnePage=rowCountForEmojiInOnePage*colCountForEmojiInOnePage-1;
        pageIndexForCurrentEmojiSet=page-kNumsOfPageForClassicsEmoji;
        emojiIndexOffsetForCurrentEmojiSet=pageIndexForCurrentEmojiSet*numsOfEmojiInOnePage;
        emojiIndexOffsetForCurrentEmojiSetModify=1;
        totalNumsOfEmoji=kNumsOfYouxihouEmoji;
        emojiStringFomrat=@"ema%d";
        emojiContainerViewWidth=kOtherEmojiContainerViewWidth;
        emojiContainerViewHeight=kOtherEmojiContainerViewHeight;
    }
    else if(page<kNumsOfPageForClassicsEmoji+kNumsOfPageForYouxihouEmoji+kNumsOfPageForTusijiEmoji){
        rowCountForEmojiInOnePage=kRowCountForOtherEmojiInOnePage;
        colCountForEmojiInOnePage=kColCountForOtherEmojiInOnePage;
        numsOfEmojiInOnePage=rowCountForEmojiInOnePage*colCountForEmojiInOnePage-1;
        pageIndexForCurrentEmojiSet=page-kNumsOfPageForClassicsEmoji-kNumsOfPageForYouxihouEmoji;
        emojiIndexOffsetForCurrentEmojiSet=pageIndexForCurrentEmojiSet*numsOfEmojiInOnePage;
        emojiIndexOffsetForCurrentEmojiSetModify=1;
        totalNumsOfEmoji=kNumsOfTusijiEmoji;
        emojiStringFomrat=@"emb%d";
        emojiContainerViewWidth=kOtherEmojiContainerViewWidth;
        emojiContainerViewHeight=kOtherEmojiContainerViewHeight;
    }
    else{
        rowCountForEmojiInOnePage=kRowCountForOtherEmojiInOnePage;
        colCountForEmojiInOnePage=kColCountForOtherEmojiInOnePage;
        numsOfEmojiInOnePage=rowCountForEmojiInOnePage*colCountForEmojiInOnePage-1;
        pageIndexForCurrentEmojiSet=page-kNumsOfPageForClassicsEmoji-kNumsOfPageForYouxihouEmoji-kNumsOfPageForTusijiEmoji;
        emojiIndexOffsetForCurrentEmojiSet=pageIndexForCurrentEmojiSet*numsOfEmojiInOnePage;
        emojiIndexOffsetForCurrentEmojiSetModify=1;
        totalNumsOfEmoji=kNumsOfYangcongtouEmoji;
        emojiStringFomrat=@"emc%d";
        emojiContainerViewWidth=kOtherEmojiContainerViewWidth;
        emojiContainerViewHeight=kOtherEmojiContainerViewHeight;
    }
    
    for(int i=1;i<=MIN(numsOfEmojiInOnePage, totalNumsOfEmoji-emojiIndexOffsetForCurrentEmojiSet);i++){
        NSInteger pos=emojiIndexOffsetForCurrentEmojiSet+i-emojiIndexOffsetForCurrentEmojiSetModify;
        NSInteger row=(i-1)/colCountForEmojiInOnePage;
        NSInteger col=(i-1)%colCountForEmojiInOnePage;
        CustomEmojiContainerView *emojiView=[[CustomEmojiContainerView alloc]initWithFrame:CGRectMake(emojiContainerViewWidth*col, emojiContainerViewWidth*row, emojiContainerViewWidth, emojiContainerViewWidth)];
        emojiView.backgroundColor=[UIColor clearColor];
        emojiView.delegate=self;
        emojiView.imageString=[NSString stringWithFormat:emojiStringFomrat,pos];
        [containerView addSubview:emojiView];
    }
    CustomEmojiContainerView *emojiView=[[CustomEmojiContainerView alloc]initWithFrame:CGRectMake(emojiContainerViewWidth*(colCountForEmojiInOnePage-1), emojiContainerViewHeight*(rowCountForEmojiInOnePage-1), emojiContainerViewWidth, emojiContainerViewHeight)];
    emojiView.delegate=self;
    emojiView.imageString=@"delete";
    emojiView.backgroundColor=[UIColor clearColor];
    [containerView addSubview:emojiView];
    
    [view addSubview:containerView];
    [_scrollView addSubview:view];
}

#pragma mark - 点击tabbar显示某一页
-(void)scrollToPage:(NSInteger)page{
    CGRect rect=_scrollView.bounds;
    rect.origin.x=CGRectGetWidth(rect)*page;
    [_scrollView scrollRectToVisible:rect animated:YES];
    [self refreshPageControlAndTabbar:page];
}
#pragma mark - 刷新Pagecontrol和Tabbar
-(void)refreshPageControlAndTabbar:(NSInteger)page{
    NSInteger currentTag=0;
    if(page<kNumsOfPageForClassicsEmoji){
        currentTag=0;
        NSInteger pageIndexForCurrentEmojiSet=page;
        _pageControl.numberOfPages=kNumsOfPageForClassicsEmoji;
        [_pageControl setCurrentPage:pageIndexForCurrentEmojiSet];
    }
    else if(page<kNumsOfPageForClassicsEmoji+kNumsOfPageForYouxihouEmoji){
       currentTag=1;
        NSInteger pageIndexForCurrentEmojiSet=page-kNumsOfPageForClassicsEmoji;
        _pageControl.numberOfPages=kNumsOfPageForYouxihouEmoji;
        [_pageControl setCurrentPage:pageIndexForCurrentEmojiSet];
    }
    else if(page<kNumsOfPageForClassicsEmoji+kNumsOfPageForYouxihouEmoji+kNumsOfPageForTusijiEmoji){
       currentTag=2;
        NSInteger pageIndexForCurrentEmojiSet=page-kNumsOfPageForClassicsEmoji-kNumsOfPageForYouxihouEmoji;
        _pageControl.numberOfPages=kNumsOfPageForTusijiEmoji;
        [_pageControl setCurrentPage:pageIndexForCurrentEmojiSet];
        
    }
    else{
       currentTag=3;
        NSInteger pageIndexForCurrentEmojiSet=page-kNumsOfPageForClassicsEmoji-kNumsOfPageForYouxihouEmoji-kNumsOfPageForTusijiEmoji;
        _pageControl.numberOfPages=kNumsOfPageForYangcongtouEmoji;
        [_pageControl setCurrentPage:pageIndexForCurrentEmojiSet];
    }
    [_toolbarbuttons enumerateObjectsUsingBlock:^(UIButton* obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.selected=(obj.tag==currentTag);
    }];
}
#pragma  mark - 实现CustomEmojiKeyboardDelegate协议
-(void)addEmojiWithImage:(YYImage *)image withImageString:(NSString *)imageString{
    if(_delegate!=nil){
        [_delegate addEmojiWithImage:image withImageString:imageString];
    }
}
-(void)deleteEmoji{
    if(_delegate!=nil){
        [_delegate deleteEmoji];
    }
}
@end
