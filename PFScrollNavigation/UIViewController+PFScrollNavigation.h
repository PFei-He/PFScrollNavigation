//
//  UIViewController+PFScrollNavigation.h
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

#import <UIKit/UIKit.h>

@interface UIViewController (PFScrollNavigation)

#pragma mark - Navigation Bar Methods

/**
 *  @brief 显示导航栏
 */
- (void)showNavigationBar:(BOOL)animated;

/**
 *  @brief 隐藏导航栏
 */
- (void)hideNavigationBar:(BOOL)animated;

/**
 *  @brief 移动导航栏
 */
- (void)moveNavigationBar:(CGFloat)y animated:(BOOL)animated;

/**
 *  @brief 设置导航栏Y坐标
 */
- (void)setNavigationBarOriginY:(CGFloat)y animated:(BOOL)animated;

#pragma mark - Toolbar Methods

/**
 *  @brief 显示工具栏
 */
- (void)showToolbar:(BOOL)animated;

/**
 *  @brief 隐藏工具栏
 */
- (void)hideToolbar:(BOOL)animated;

/**
 *  @brief 移动工具栏
 */
- (void)moveToolbar:(CGFloat)y animated:(BOOL)animated;

/**
 *  @brief 设置工具栏Y坐标
 */
- (void)setToolbarOriginY:(CGFloat)y animated:(BOOL)animated;

#pragma mark - Tab Bar Methods

/**
 *  @brief 显示标签栏
 */
- (void)showTabBar:(BOOL)animated;

/**
 *  @brief 隐藏标签栏
 */
- (void)hideTabBar:(BOOL)animated;

/**
 *  @brief 移动标签栏
 */
- (void)moveTabBar:(CGFloat)y animated:(BOOL)animated;

/**
 *  @brief 设置标签栏Y坐标
 */
- (void)setTabBarOriginY:(CGFloat)y animated:(BOOL)animated;

@end
