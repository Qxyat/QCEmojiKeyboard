//
//  CustomEmojiKeyboard.m
//  YYTextTest
//
//  Created by 邱鑫玥 on 16/1/10.
//  Copyright © 2016年 qiu. All rights reserved.
//

#import "QCEmojiKeyboard.h"
#import "QCEmojiCell.h"
#import "QCEmojiUtilities.h"



#define kQCScreenWidth CGRectGetWidth([UIScreen mainScreen].bounds)

static NSString*  const kQCEmojiCellName=@"EmojiCell";

static NSString*  const kQCEmojiGroupName=@"EmojiGroupName";
static NSString*  const kQCEmojiGroupPreixID=@"EmojiGroupPrefixID";
static NSString * const kQCEmojiGroupCurCount=@"EmojiGroupCurCount";
static NSString*  const kQCEmojiGroupBeginIndex=@"EmojiGroupBeginIndex";
static NSString*  const kQCEmojiGroupEndIndex=@"EmojiGroupEndIndex";
static NSString*  const kQCEmojiGroupStartPageIndex=@"EmojiGroupStartPageIndex";
static NSString*  const kQCEmojiGroupPageCount=@"EmojiGroupPageCount";

static NSUInteger const kQCEmojiKeyboardHeight=216;
static NSUInteger const kQCEmojiOnePageCount=21;
static NSUInteger const kQCEmojiColCount=7;
static CGFloat    const kQCEmojiItemHeight=50.0;
static CGFloat    const kQCEmojiToolbarHeight=36.0;
static NSUInteger const kQCEmojiToolbarOnePageItemCount=3;

@interface QCEmojiKeyboard ()<UICollectionViewDataSource,UICollectionViewDelegate,UIScrollViewDelegate>

@property (strong,nonatomic)UIView* toolbar;
@property (strong,nonatomic)UIPageControl *pageControl;
@property (strong,nonatomic)UICollectionView *collectionView;
@property (copy,nonatomic)NSArray *toolbarButtons;
@property (strong,nonatomic)NSArray *emojiGroups;
@property (strong,nonatomic)NSArray *emojiGroupsInfo;
@property (nonatomic)NSUInteger emojiGroupsTotalPageCount;

@end

@implementation QCEmojiKeyboard

+(instancetype)sharedQCEmojiKeyboard{
    static QCEmojiKeyboard *qcEmojiKeyboard;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        qcEmojiKeyboard=[[QCEmojiKeyboard alloc]init];
    });
    return qcEmojiKeyboard;
}
-(id)init{
    if(self=[super init]){
        self.frame=CGRectMake(0, 0, kQCScreenWidth, kQCEmojiKeyboardHeight);
        self.backgroundColor=[QCEmojiUtilities getColor:@"f9f9f9"];
        [self _initEmojiGroups];
        [self _initCollectionView];
        [self _initPageControl];
        [self _initToolbar];
        [self _scrollToPage:0];
    }

    return self;
}
-(void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    CGContextRef context=UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 1.0);
    CGContextSetStrokeColorWithColor(context, [QCEmojiUtilities getColor:@"bfbfbf"].CGColor);
    CGContextMoveToPoint(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGContextAddLineToPoint(context, CGRectGetMaxX(rect), CGRectGetMinY(rect));
    CGContextStrokePath(context);
}

#pragma mark - 初始化各个view
-(void)_initEmojiGroups{
    NSString *emojiSettingFilePath=[[NSBundle mainBundle]pathForResource:@"Emoji" ofType:@"plist"];
    _emojiGroups=[[NSArray alloc]initWithContentsOfFile:emojiSettingFilePath];
    
    NSUInteger index=0;
    NSMutableArray *emojiGroupsInfo=[[NSMutableArray alloc]initWithCapacity:_emojiGroups.count];
    
    for(NSUInteger i=0;i<_emojiGroups.count;i++){
        NSUInteger numOfEmojis=[_emojiGroups[i][kQCEmojiGroupCurCount] integerValue];
        NSUInteger pageCount=numOfEmojis/(kQCEmojiOnePageCount-1);
        if(numOfEmojis%(kQCEmojiOnePageCount-1)!=0){
            pageCount+=1;
        }
        NSMutableDictionary *dic=[[NSMutableDictionary alloc]init];
        [dic setObject:@(index) forKey:kQCEmojiGroupStartPageIndex];
        [dic setObject:@(pageCount) forKey:kQCEmojiGroupPageCount];
        [emojiGroupsInfo addObject:dic];
        index+=pageCount;
    }
    _emojiGroupsTotalPageCount=index;
    _emojiGroupsInfo=emojiGroupsInfo;
}
-(void)_initCollectionView{
    NSUInteger itemWitdh=(kQCScreenWidth-2*10)/kQCEmojiColCount;
    CGFloat padding=(kQCScreenWidth-kQCEmojiColCount*itemWitdh)/2.0;
    CGFloat leftPadding=padding;
    CGFloat rightPadding=kQCScreenWidth-leftPadding-kQCEmojiColCount*itemWitdh;
    
    UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc]init];
    layout.scrollDirection=UICollectionViewScrollDirectionHorizontal;
    layout.itemSize=CGSizeMake(itemWitdh, kQCEmojiItemHeight);
    layout.minimumLineSpacing=0;
    layout.minimumInteritemSpacing=0;
    layout.sectionInset=UIEdgeInsetsMake(0, leftPadding, 0, rightPadding);
    
    _collectionView=[[UICollectionView alloc]initWithFrame:CGRectMake(0, 5, kQCScreenWidth, kQCEmojiItemHeight*3) collectionViewLayout:layout];
    _collectionView.backgroundColor=[UIColor clearColor];
    _collectionView.pagingEnabled=YES;
    [_collectionView registerClass:[QCEmojiCell class] forCellWithReuseIdentifier:kQCEmojiCellName];
    _collectionView.dataSource=self;
    _collectionView.delegate=self;
    
    [self addSubview:_collectionView];
}
-(void)_initPageControl{
    _pageControl=[[UIPageControl alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_collectionView.frame), kQCScreenWidth, 20)];
    [_pageControl setCurrentPageIndicatorTintColor:[UIColor grayColor]];
    [_pageControl setPageIndicatorTintColor:[UIColor lightGrayColor]];
    _pageControl.userInteractionEnabled=NO;
    
    [self addSubview:_pageControl];
}
-(void)_initToolbar{
    _toolbar=[[UIView alloc]initWithFrame:CGRectMake(0, kQCEmojiKeyboardHeight-kQCEmojiToolbarHeight, kQCScreenWidth, kQCEmojiToolbarHeight)];
    UIImageView *bg=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_toolbar.frame), CGRectGetHeight(_toolbar.frame))];
    bg.image=[UIImage imageNamed:@"QCEmojiKeyboardToolbarBackground"];
    [_toolbar addSubview:bg];
    
    UIScrollView *scrollView=[[UIScrollView alloc]initWithFrame:bg.frame];
    scrollView.showsHorizontalScrollIndicator=NO;
    scrollView.showsVerticalScrollIndicator=NO;
    scrollView.alwaysBounceHorizontal=YES;
    [_toolbar addSubview:scrollView];
    
    NSMutableArray *buttons=[[NSMutableArray alloc]initWithCapacity:_emojiGroups.count];
    for(NSUInteger i=0;i<_emojiGroups.count;i++){
        UIButton *button=[self _createToolbarButtonAtIndex:i];
        [button setTitle:_emojiGroups[i][kQCEmojiGroupName] forState:UIControlStateNormal];
        [scrollView addSubview:button];
        [buttons addObject:button];
    }
    scrollView.contentSize=CGSizeMake(CGRectGetWidth(((UIButton*)[buttons lastObject]).frame)*_emojiGroups.count, CGRectGetHeight(((UIButton*)[buttons lastObject]).frame));
    _toolbarButtons=buttons;
    [self addSubview:_toolbar];
}


- (UIButton *)_createToolbarButtonAtIndex:(NSInteger)index{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.tag=index;
    btn.frame=CGRectMake(kQCScreenWidth/kQCEmojiToolbarOnePageItemCount*index, 0, kQCScreenWidth/kQCEmojiToolbarOnePageItemCount, kQCEmojiToolbarHeight);
    btn.exclusiveTouch = YES;
    
    btn.titleLabel.font = [UIFont systemFontOfSize:14];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setTitleColor:[QCEmojiUtilities getColor:@"5D5C5A"] forState:UIControlStateSelected];
    
    UIImage *img;
    img = [UIImage imageNamed:@"QCEmojiKeyboardToolbarItemNormal"];
    img = [img resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, img.size.width - 1) resizingMode:UIImageResizingModeStretch];
    [btn setBackgroundImage:img forState:UIControlStateNormal];
    
    img = [UIImage imageNamed:@"QCEmojiKeyboardToolbarItemSelected"];
    img = [img resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, img.size.width - 1) resizingMode:UIImageResizingModeStretch];
    [btn setBackgroundImage:img forState:UIControlStateSelected];

    [btn addTarget:self action:@selector(_toolbarButtonDidTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    return btn;
}

- (void)_toolbarButtonDidTapped:(UIButton *)item {
    [self _scrollToPage:[_emojiGroupsInfo[item.tag][kQCEmojiGroupStartPageIndex] integerValue]];
}

#pragma mark - 实现UIScrollviewDelegate
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    NSUInteger index=(scrollView.contentOffset.x/CGRectGetWidth(scrollView.frame));
    [self _refreshPageControlAndToolbar:index];
}
#pragma mark - 实现UICollectionViewDataSource协议
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return _emojiGroupsTotalPageCount;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return kQCEmojiOnePageCount;
}
-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    QCEmojiCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:kQCEmojiCellName forIndexPath:indexPath];
    cell.imageString=nil;
    if(indexPath.row!=kQCEmojiOnePageCount-1)
        cell.imageString=[self _getEmojiStringAtIndexPath:indexPath];
    else
        cell.imageString=@"delete";
    return cell;
}
-(NSString*)_getEmojiStringAtIndexPath:(NSIndexPath *)indexPath{
    for(int i=_emojiGroupsInfo.count-1;i>=0;i--){
        if(indexPath.section>=[_emojiGroupsInfo[i][kQCEmojiGroupStartPageIndex]integerValue]){
            NSString *prefix=_emojiGroups[i][kQCEmojiGroupPreixID];
            NSUInteger transferRow=(indexPath.row)%3;
            NSUInteger transferCol=(indexPath.row)/3;
            NSUInteger curEmojiGroupIndex=(indexPath.section-[_emojiGroupsInfo[i][kQCEmojiGroupStartPageIndex]integerValue])*(kQCEmojiOnePageCount-1)+transferRow*kQCEmojiColCount+transferCol+1;
            if(curEmojiGroupIndex>[_emojiGroups[i][kQCEmojiGroupCurCount] integerValue]){
                return nil;
            }
            NSString *postfix=[NSString stringWithFormat:@"%d",[_emojiGroups[i][kQCEmojiGroupBeginIndex] integerValue]+curEmojiGroupIndex-1];
            return [prefix stringByAppendingString:postfix];
        }
    }
    return nil;
}
#pragma mark - 实现UICollectionViewDelegate协议
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    QCEmojiCell *cell=(QCEmojiCell*)[collectionView cellForItemAtIndexPath:indexPath];
    
    if(cell.imageString!=nil){
        if([cell.imageString isEqualToString:@"[delete]"]){
            [_delegate deleteEmoji];
        }
        else{
            [_delegate addEmojiWithImage:cell.image withImageString:cell.imageString];
        }
    }
}


#pragma mark - 点击tabbar显示某一页
-(void)_scrollToPage:(NSInteger)pageIndex{
    CGRect rect=_collectionView.bounds;
    rect.origin.x=CGRectGetWidth(rect)*pageIndex;
    [_collectionView scrollRectToVisible:rect animated:NO];
    [self _refreshPageControlAndToolbar:pageIndex];
}


#pragma mark - 刷新Pagecontrol和Toolbar
-(void)_refreshPageControlAndToolbar:(NSInteger)pageIndex{
    NSInteger currentTag=0;
    for(int i=_emojiGroupsInfo.count-1;i>=0;i--){
        if(pageIndex>=[_emojiGroupsInfo[i][kQCEmojiGroupStartPageIndex]integerValue]){
            currentTag=i;
            NSInteger pageIndexForCurrentEmojiSet=pageIndex-[_emojiGroupsInfo[i][kQCEmojiGroupStartPageIndex]integerValue];
            _pageControl.numberOfPages=[_emojiGroupsInfo[i][kQCEmojiGroupPageCount] integerValue];
            _pageControl.currentPage=pageIndexForCurrentEmojiSet;
            break;
        }
    }
    [_toolbarButtons enumerateObjectsUsingBlock:^(UIButton* obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.selected=(obj.tag==currentTag);
    }];
}
@end
