//
//  PFScrollNavigation.m
//  PFScrollNavigation
//
//  Created by PFei_He on 15/4/17.
//  Copyright (c) 2015年 PF-Lib. All rights reserved.
//
//  https://github.com/PFei-He/PFScrollNavigation
//
//  vesion: 0.1.0
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "PFScrollNavigation.h"

/**
 *  滑动方向
 */
typedef NS_ENUM(NSUInteger, PFScrollDirection) {
    PFScrollDirectionNone = 0,
    PFScrollDirectionUp,
    PFScrollDirectionDown,
};

/**
 *  检测滑动方向
 *
 *  参数解释
 *  currentOffsetY：当前位移值
 *  previousOffsetY：上个位移值
 */
PFScrollDirection detectScrollDirection(currentOffsetY, previousOffsetY)
{
    return  currentOffsetY > previousOffsetY ? PFScrollDirectionUp  : //若当前位移值比上个位移值大，则表示上滑
            currentOffsetY < previousOffsetY ? PFScrollDirectionDown: //否则表示下滑
                                               PFScrollDirectionNone; //两者皆非则表示没有滑动
}

typedef void(^scrollBlock)(CGFloat);
typedef void(^endDraggingBlock)(void);
typedef CGFloat(^heightForRowBlock)(UITableView *, NSIndexPath *);
typedef void(^rowBlock)(UITableView *, NSIndexPath *);

@interface PFScrollNavigation ()

///前一滑动方向
@property (nonatomic) PFScrollDirection                 previousScrollDirection;

///前一位移值
@property (nonatomic) CGFloat                           previousOffsetY;

///累积的位移值
@property (nonatomic) CGFloat                           accumulatedY;

///上滑
@property (nonatomic, copy) scrollBlock                 scrollUpBlock;

///下滑
@property (nonatomic, copy) scrollBlock                 scrollDownBlock;

///停止上滑
@property (nonatomic, copy) endDraggingBlock            upEndDraggionBlock;

///停止下滑
@property (nonatomic, copy) endDraggingBlock            downEndDraggingBlock;

///行高
@property (nonatomic, copy) heightForRowBlock           heightForRowBlock;

///点击
@property (nonatomic, copy) rowBlock                    didSelectRowBlock;

///取消
@property (nonatomic, copy) rowBlock                    didDeselectRowBlock;

@end

@implementation PFScrollNavigation

#pragma mark - Initialization Methods
//初始化
- (id)init
{
    self = [super init];
    if (self) {
        [self reset];
        _downThresholdY = 200.0;
        _upThresholdY = 0.0;
    }
    return self;
}

#pragma mark - Public Methods

//重置
- (void)reset
{
    _previousOffsetY = 0.0;
    _accumulatedY = 0.0;
    _previousScrollDirection = PFScrollDirectionNone;
}

#pragma mark -

//导航栏上滑
- (void)scrollUpUsingBlock:(void (^)(CGFloat))block
{
    _scrollUpBlock = block;
}

//导航栏下滑
- (void)scrollDownUsingBlock:(void (^)(CGFloat))block
{
    _scrollDownBlock = block;
}

//停止上滑
- (void)scrollUpDidEndDraggingUsingBlock:(void (^)(void))block
{
    _upEndDraggionBlock = block;
}

//停止下滑
- (void)scrollDownDidEndDraggingUsingBlock:(void (^)(void))block
{
    _downEndDraggingBlock = block;
}

#pragma mark -

//行高
- (void)heightForRowUsingBlock:(CGFloat (^)(UITableView *, NSIndexPath *))block
{
    _heightForRowBlock = block;
}

//点击
- (void)didSelectRowUsingBlock:(void (^)(UITableView *, NSIndexPath *))block
{
    _didSelectRowBlock = block;
}

//取消
- (void)didDeselectRowUsingBlock:(void (^)(UITableView *, NSIndexPath *))block
{
    _didDeselectRowBlock = block;
}

#pragma mark - UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat currentOffsetY = scrollView.contentOffset.y;
    
    PFScrollDirection currentScrollDirection = detectScrollDirection(currentOffsetY, _previousOffsetY);
    CGFloat topBoundary = -scrollView.contentInset.top;
    CGFloat bottomBoundary = scrollView.contentSize.height + scrollView.contentInset.bottom;
    
    BOOL isExceedTopBoundary = currentOffsetY <= topBoundary;
    BOOL isExceedBottomBoundary = currentOffsetY >= bottomBoundary;
    
    BOOL isBouncing = (isExceedTopBoundary && currentScrollDirection != PFScrollDirectionDown) || (isExceedBottomBoundary && currentScrollDirection != PFScrollDirectionUp);
    if (isBouncing || !scrollView.isDragging) {
        return;
    }
    
    CGFloat y = _previousOffsetY - currentOffsetY;
    _accumulatedY += y;
    
    switch (currentScrollDirection) {
        case PFScrollDirectionUp:
        {
            BOOL isExceedThreshold = _accumulatedY < -_upThresholdY;
            
            if (isExceedThreshold || isExceedBottomBoundary)  {
                if ([_delegate respondsToSelector:@selector(scrollNavigation:scrollUpWithOriginY:)]) {
                    [_delegate scrollNavigation:self scrollUpWithOriginY:y];
                } else if (_scrollUpBlock) {
                    _scrollUpBlock(y);
                }
            }
        }
            break;
        case PFScrollDirectionDown:
        {
            BOOL isExceedThreshold = _accumulatedY > _downThresholdY;
            
            if (isExceedThreshold || isExceedTopBoundary) {
                if ([_delegate respondsToSelector:@selector(scrollNavigation:scrollDownWithOriginY:)]) {
                    [_delegate scrollNavigation:self scrollDownWithOriginY:y];
                } else if (_scrollDownBlock) {
                    _scrollDownBlock(y);
                }
            }
        }
            break;
        case PFScrollDirectionNone:
            break;
    }
    
    //当向反方向移动时，重置积累的位移值
    if (!isExceedTopBoundary && !isExceedBottomBoundary && _previousScrollDirection != currentScrollDirection) {
        _accumulatedY = 0;
    }
    
    _previousScrollDirection = currentScrollDirection;
    _previousOffsetY = currentOffsetY;
    
    //移动状态栏
    UIWindow *statusBarWindow = (UIWindow *)[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"];
    statusBarWindow.tintColor = [UIColor clearColor];
    if(_accumulatedY < -_upThresholdY) {
        [statusBarWindow setFrame:CGRectMake(0,
                                             _accumulatedY,
                                             statusBarWindow.frame.size.width,
                                             statusBarWindow.frame.size.height)];
    } else if (_accumulatedY > _downThresholdY) {
        [statusBarWindow setFrame:CGRectMake(0,
                                             (y <= 0) ? y : 0,
                                             statusBarWindow.frame.size.width,
                                             statusBarWindow.frame.size.height)];
    }
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    CGFloat currentOffsetY = scrollView.contentOffset.y;
    
    CGFloat topBoundary = -scrollView.contentInset.top;
    CGFloat bottomBoundary = scrollView.contentSize.height + scrollView.contentInset.bottom;
    
    switch (_previousScrollDirection) {
        case PFScrollDirectionUp:
        {
            BOOL isExceedThreshold = _accumulatedY < -_upThresholdY;
            BOOL isExceedBottomBoundary = currentOffsetY >= bottomBoundary;
            
            if (isExceedThreshold || isExceedBottomBoundary) {
                if ([_delegate respondsToSelector:@selector(scrollUpDidEndDragging:)]) {
                    [_delegate scrollUpDidEndDragging:self];
                } else if (_upEndDraggionBlock) {
                    _upEndDraggionBlock();
                }
            }
            break;
        }
        case PFScrollDirectionDown:
        {
            BOOL isExceedThreshold = _accumulatedY > _downThresholdY;
            BOOL isExceedTopBoundary = currentOffsetY <= topBoundary;
            
            if (isExceedThreshold || isExceedTopBoundary) {
                if ([_delegate respondsToSelector:@selector(scrollDownDidEndDragging:)]) {
                    [_delegate scrollDownDidEndDragging:self];
                } else if (_downEndDraggingBlock) {
                    _downEndDraggingBlock();
                }
            }
            break;
        }
        case PFScrollDirectionNone:
            break;
    }
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView
{
    if ([_delegate respondsToSelector:@selector(scrollDownDidEndDragging:)]) {
        [_delegate scrollDownDidEndDragging:self];
    } else if (_downEndDraggingBlock) {
        _downEndDraggingBlock();
    }
    return YES;
}

#pragma mark - UITableViewDelegate Methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_delegate respondsToSelector:@selector(tableView:heightForRowAtIndexPath:)]) {
        return [_delegate tableView:tableView heightForRowAtIndexPath:indexPath];
    } else if (_heightForRowBlock) {
        return _heightForRowBlock(tableView, indexPath);
    } else {
        return 0;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
        [_delegate tableView:tableView didSelectRowAtIndexPath:indexPath];
    } else if (_didSelectRowBlock) {
        _didSelectRowBlock(tableView, indexPath);
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_delegate respondsToSelector:@selector(tableView:didDeselectRowAtIndexPath:)]) {
        [_delegate tableView:tableView didDeselectRowAtIndexPath:indexPath];
    } else if (_didDeselectRowBlock) {
        _didDeselectRowBlock(tableView, indexPath);
    }
}

@end
