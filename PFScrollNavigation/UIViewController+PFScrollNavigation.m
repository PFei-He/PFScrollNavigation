//
//  UIViewController+PFScrollNavigation.m
//  PFScrollNavigation
//
//  Created by PFei_He on 15/4/17.
//  Copyright (c) 2015年 PF-Lib. All rights reserved.
//
//  https://github.com/PFei-He/PFScrollNavigation
//
//  vesion: 0.1.0-beta9
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

#if __IPHONE_7_0 && __IPHONE_OS_VERSION_MAX_ALLOWED >=  __IPHONE_7_0
        #define kVERSION_IS_IOS7 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
    #else
        #define kVERSION_IS_IOS7 NO
#endif

#if __IPHONE_8_0 && __IPHONE_OS_VERSION_MAX_ALLOWED >=  __IPHONE_8_0
        #define kVERSION_IS_IOS8 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    #else
        #define kVERSION_IS_IOS8 NO
#endif

#import "UIViewController+PFScrollNavigation.h"

#define kNearZero 0.000001f

@implementation UIViewController (PFScrollNavigation)

#pragma mark - State Bar Methods

//状态栏高度
- (CGFloat)statusBarHeight
{
    //获取状态栏尺寸
    CGSize statuBarFrameSize = [UIApplication sharedApplication].statusBarFrame.size;
    if (kVERSION_IS_IOS8) {
        return statuBarFrameSize.height;
    }
    return UIInterfaceOrientationIsPortrait(self.interfaceOrientation) ? statuBarFrameSize.height : statuBarFrameSize.width;
}

#pragma mark - Public Methods(Navigation Bar Methods)

//显示导航栏
- (void)showNavigationBar:(BOOL)animated
{
    CGFloat statusBarHeight = [self statusBarHeight];
    
    UIWindow *appKeyWindow = [UIApplication sharedApplication].keyWindow;
    UIView *appBaseView = appKeyWindow.rootViewController.view;
    CGRect viewControllerFrame =  [appBaseView convertRect:appBaseView.bounds toView:appKeyWindow];
    
    CGFloat overwrapStatusBarHeight = statusBarHeight - viewControllerFrame.origin.y;
    
    [self setNavigationBarOriginY:overwrapStatusBarHeight animated:animated];
}

//隐藏导航栏
- (void)hideNavigationBar:(BOOL)animated
{
    CGFloat navigationBarHeight = self.navigationController.navigationBar.frame.size.height;
    [self setNavigationBarOriginY:-navigationBarHeight animated:animated];
}

//移动导航栏
- (void)moveNavigationBar:(CGFloat)y animated:(BOOL)animated
{
    CGRect frame = self.navigationController.navigationBar.frame;
    CGFloat nextY = frame.origin.y + y;
    [self setNavigationBarOriginY:nextY animated:animated];
}

//设置导航栏坐标
- (void)setNavigationBarOriginY:(CGFloat)y animated:(BOOL)animated
{
    CGFloat statusBarHeight = [self statusBarHeight];
    
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    UIView *baseView = keyWindow.rootViewController.view;
    CGRect viewControllerFrame =  [baseView convertRect:baseView.bounds toView:keyWindow];
    
    statusBarHeight = statusBarHeight - viewControllerFrame.origin.y;
    
    CGRect frame = self.navigationController.navigationBar.frame;
    CGFloat navigationBarHeight = frame.size.height;
    
    frame.origin.y = fmin(fmax(y, -navigationBarHeight), statusBarHeight);
    
    CGFloat navBarHiddenRatio = statusBarHeight > 0 ? (statusBarHeight - frame.origin.y) / statusBarHeight : 0;
    CGFloat alpha = MAX(1.f - navBarHiddenRatio, kNearZero);
    [UIView animateWithDuration:animated ? 0.1 : 0 animations:^{
        self.navigationController.navigationBar.frame = frame;
        NSUInteger index = 0;
        for (UIView *view in self.navigationController.navigationBar.subviews) {
            index++;
            if (index == 1 || view.hidden || view.alpha <= 0.0f) continue;
            view.alpha = alpha;
        }
        if (kVERSION_IS_IOS7) {
            UIColor *tintColor = self.navigationController.navigationBar.tintColor;
            if (tintColor) {
                self.navigationController.navigationBar.tintColor = [tintColor colorWithAlphaComponent:alpha];
            }
        }
    }];
}

#pragma mark - Public Methods(Toolbar Methods)

//显示工具栏
- (void)showToolbar:(BOOL)animated
{
    CGSize viewSize = self.navigationController.view.frame.size;
    CGFloat viewHeight = [self bottomBarViewControlleViewHeightFromViewSize:viewSize];
    CGFloat toolbarHeight = self.navigationController.toolbar.frame.size.height;
    [self setToolbarOriginY:viewHeight - toolbarHeight animated:animated];
}

//隐藏工具栏
- (void)hideToolbar:(BOOL)animated
{
    CGSize viewSize = self.navigationController.view.frame.size;
    CGFloat viewHeight = [self bottomBarViewControlleViewHeightFromViewSize:viewSize];
    [self setToolbarOriginY:viewHeight animated:animated];
}

//移动工具栏
- (void)moveToolbar:(CGFloat)y animated:(BOOL)animated
{
    CGRect frame = self.navigationController.toolbar.frame;
    CGFloat nextY = frame.origin.y + y;
    [self setToolbarOriginY:nextY animated:animated];
}

//设置工具栏坐标
- (void)setToolbarOriginY:(CGFloat)y animated:(BOOL)animated
{
    CGRect frame = self.navigationController.toolbar.frame;
    CGFloat toolBarHeight = frame.size.height;
    CGSize viewSize = self.navigationController.view.frame.size;
    CGFloat viewHeight = [self bottomBarViewControlleViewHeightFromViewSize:viewSize];
    
    CGFloat topLimit = viewHeight - toolBarHeight;
    CGFloat bottomLimit = viewHeight;
    
    frame.origin.y = fmin(fmax(y, topLimit), bottomLimit); // limit over moving
    
    [UIView animateWithDuration:animated ? 0.1 : 0 animations:^{
        self.navigationController.toolbar.frame = frame;
    }];
}

#pragma mark - Public Methods(Tab Bar Methods)

//显示标签栏
- (void)showTabBar:(BOOL)animated
{
    CGSize viewSize = self.tabBarController.view.frame.size;
    CGFloat viewHeight = [self bottomBarViewControlleViewHeightFromViewSize:viewSize];
    CGFloat toolbarHeight = self.tabBarController.tabBar.frame.size.height;
    [self setTabBarOriginY:viewHeight - toolbarHeight animated:animated];
}

//隐藏标签栏
- (void)hideTabBar:(BOOL)animated
{
    CGSize viewSize = self.tabBarController.view.frame.size;
    CGFloat viewHeight = [self bottomBarViewControlleViewHeightFromViewSize:viewSize];
    [self setTabBarOriginY:viewHeight animated:animated];
}

//移动标签栏
- (void)moveTabBar:(CGFloat)y animated:(BOOL)animated
{
    CGRect frame =  self.tabBarController.tabBar.frame;
    CGFloat newY = frame.origin.y + y;
    [self setTabBarOriginY:newY animated:animated];
}

//设置标签栏坐标
- (void)setTabBarOriginY:(CGFloat)y animated:(BOOL)animated
{
    CGRect frame = self.tabBarController.tabBar.frame;
    CGFloat toolBarHeight = frame.size.height;
    CGSize viewSize = self.tabBarController.view.frame.size;
    
    CGFloat viewHeight = [self bottomBarViewControlleViewHeightFromViewSize:viewSize];
    
    CGFloat topLimit = viewHeight - toolBarHeight;
    CGFloat bottomLimit = viewHeight;
    
    frame.origin.y = fmin(fmax(y, topLimit), bottomLimit); // limit over moving
    
    [UIView animateWithDuration:animated ? 0.1 : 0 animations:^{
        self.tabBarController.tabBar.frame = frame;
    }];
}

#pragma mark -

- (CGFloat)bottomBarViewControlleViewHeightFromViewSize:(CGSize)viewSize
{
    CGFloat viewHeight = 0.f;
    if (kVERSION_IS_IOS8) {
        viewHeight = viewSize.height;
    } else {
        viewHeight = UIInterfaceOrientationIsPortrait(self.interfaceOrientation) ? viewSize.height : viewSize.width;
    }
    return viewHeight;
}

@end
