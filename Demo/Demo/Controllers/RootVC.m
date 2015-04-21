//
//  RootVC.m
//  Demo
//
//  Created by PFei_He on 14-12-17.
//  Copyright (c) 2014年 PF-Lib. All rights reserved.
//

#import "RootVC.h"
#import "UIViewController+PFScrollNavigation.h"

@interface RootVC ()

@property (nonatomic) NSArray *data;
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
    
    [self setupData];
    
    _scrollNavigation = [[PFScrollNavigation alloc] initWithScrollNavigationDelegate:nil];
    _scrollNavigation.delegate = self;
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 1000) style:UITableViewStylePlain];
    tableView.delegate = (id)_scrollNavigation; // cast for surpress incompatible warnings
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetBars) name:UIApplicationWillEnterForegroundNotification object:nil]; // resume bars when back to forground from other apps
    
    if (![[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        // support full screen on iOS 6
        self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
        self.navigationController.toolbar.barStyle = UIBarStyleBlackTranslucent;
    }
}

-(void)viewDidLayoutSubviews
{
    // remove bottom toolbar height from inset
//    UIEdgeInsets inset = self.tableView.contentInset;
//    inset.bottom = 0;
//    self.tableView.contentInset = inset;
//    inset = self.tableView.scrollIndicatorInsets;
//    inset.bottom = 0;
//    self.tableView.scrollIndicatorInsets = inset;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_scrollNavigation reset];
    [self showNavigationBar:animated];
    [self showToolbar:animated];
}

- (void)setupData
{
    NSMutableArray *data = [@[] mutableCopy];
    for (NSUInteger i = 0; i < 100; i++) {
        [data addObject:@(i)];
    }
    _data = [data copy];
}

- (void)refreshControlValueChanged:(id)sender
{
//    [self.refreshControl beginRefreshing];
    // simulate loading time
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//        [self.refreshControl endRefreshing];
    });
}

- (void)resetBars
{
    [_scrollNavigation reset];
    [self showNavigationBar:NO];
    [self showToolbar:NO];
}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *Identifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
    }
//    cell.textLabel.text = [_data[indexPath.row] stringValue];
    return cell;
}

#pragma mark -
#pragma mark NJKScrollFullScreenDelegate

//导航栏上滑
- (void)scrollNavigation:(PFScrollNavigation *)scrollNavigation scrollUpWithOriginY:(CGFloat)y
{
    
    [self moveNavigationBar:y animated:YES];
    [self moveToolbar:-y animated:YES]; // move to revese direction
    
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)])
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
}

//导航栏下滑
- (void)scrollNavigation:(PFScrollNavigation *)scrollNavigation scrollDownWithOriginY:(CGFloat)y
{
    [self moveNavigationBar:y animated:YES];
    [self moveToolbar:-y animated:YES];
}

//停止上滑
- (void)scrollUpDidEndDragging:(PFScrollNavigation *)scrollNavigation
{
    [self hideNavigationBar:YES];
    [self hideToolbar:YES];
}

//停止下滑
- (void)scrollDownDidEndDragging:(PFScrollNavigation *)scrollNavigation
{
    [self showNavigationBar:YES];
    [self showToolbar:YES];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [_scrollNavigation reset];
    [self showNavigationBar:YES];
    [self showToolbar:YES];
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
