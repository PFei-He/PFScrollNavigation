//
//  RootVC.m
//  Demo
//
//  Created by PFei_He on 14-12-17.
//  Copyright (c) 2014年 PF-Lib. All rights reserved.
//

#import "RootVC.h"
#import "PFScrollNavigation.h"

@interface RootVC ()

@property (nonatomic) PFScrollNavigation *scrollNavigation;

@end

@implementation RootVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - Views Management

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"上移会消失的导航";
    
    if (![[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
        self.navigationController.toolbar.barStyle = UIBarStyleBlackTranslucent;
    }
    
    [self setupScrollNavigation];
    [self setupTableView];
}

- (void)setupScrollNavigation
{
    _scrollNavigation = [[PFScrollNavigation alloc] init];
    @weakify_self
    [_scrollNavigation scrollUpUsingBlock:^(CGFloat y) {
        @strongify_self
        [self moveNavigationBar:y animated:YES];
        [self moveToolbar:-y animated:YES];
    }];
    
    [_scrollNavigation scrollDownUsingBlock:^(CGFloat y) {
        @strongify_self
        [self moveNavigationBar:y animated:YES];
        [self moveToolbar:-y animated:YES];
    }];
    
    [_scrollNavigation scrollUpDidEndDraggingUsingBlock:^{
        @strongify_self
        [self hideNavigationBar:YES];
        [self hideToolbar:YES];
    }];
    
    [_scrollNavigation scrollDownDidEndDraggingUsingBlock:^{
        @strongify_self
        [self showNavigationBar:YES];
        [self showToolbar:YES];
    }];
    
    [_scrollNavigation heightForRowUsingBlock:^CGFloat(UITableView *tableView, NSIndexPath *indexPath) {
        return 200;
    }];
    
    [_scrollNavigation didSelectRowUsingBlock:^(UITableView *tableView, NSIndexPath *indexPath) {
        NSLog(@"%d", indexPath.row);
    }];
}

- (void)setupTableView
{
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(10, 10, self.view.frame.size.width - 20, self.view.frame.size.height - 10) style:UITableViewStylePlain];
    tableView.delegate = (id)_scrollNavigation; //将列表的代理给予导航
    tableView.dataSource = self;
    [self.view addSubview:tableView];
}

#pragma mark - UITableViewDelegate Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"identifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    return cell;
}

#pragma mark - Memory Management

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
