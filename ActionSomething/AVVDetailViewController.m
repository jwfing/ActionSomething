//
//  AVVDetailViewController.m
//  ActionSomething
//
//  Created by Feng Junwen on 3/18/14.
//  Copyright (c) 2014 Feng Junwen. All rights reserved.
//

#import "AVVDetailViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AVOSCloudVideo/AVOSCloudVideo.h>
#import <AVOSCloud/AVOSCloud.h>
#import <AVOSCloud/AVPush.h>
#import "AVVMediaViewCell.h"

#define IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )
#define iOS7OrLater (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)

#define OFFSET_Y_FOR_IOS_7 (iOS7OrLater?64.0:0.0)
#define TABLEVIEW_DEFAULT_HEIGHT ((IS_IPHONE_5?456:368)+OFFSET_Y_FOR_IOS_7)
#define DEFAULT_CONTENT_HEIGHT 32.0

@interface AVVDetailViewController ()<UITableViewDataSource, UITableViewDelegate, AVOSCloudCaptureDelegate> {
    NSMutableArray *_msgs;
    NSString *_channelName;
    NSString *_currentVideo;
}
- (void)configureView;
@end

@implementation AVVDetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }
}

- (void)configureView
{
    // Update the user interface for the detail item.

    if (self.detailItem && [self.detailItem isKindOfClass:[AVUser class]]) {
        AVUser *currentUser = [AVUser currentUser];
        AVUser *partener = (AVUser*)_detailItem;
        [self establishChannel:currentUser withUser:partener];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [AVAnalytics beginLogPageView:@"ChatRoom"];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [AVAnalytics endLogPageView:@"ChatRoom"];
}

- (void)establishChannel:(AVUser*)here withUser:(AVUser*)there{
    if (NSOrderedAscending == [here.username compare:there.username]) {
        _channelName = [NSString stringWithFormat:@"%@2%@", here.username, there.username];
    } else {
        _channelName = [NSString stringWithFormat:@"%@2%@", there.username, here.username];
    }
    AVQuery *chQuery = [AVQuery queryWithClassName:@"Channel"];
    [chQuery whereKey:@"channelName" equalTo:_channelName];
    [chQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!objects || [objects count] < 1) {
            // create channel at first;
            AVObject *chObject = [AVObject objectWithClassName:@"Channel"];
            [chObject setObject:_channelName forKey:@"channelName"];
            [chObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!succeeded) {
                    return;
                }
                AVInstallation *currentInstallation = [AVInstallation currentInstallation];
                [currentInstallation addUniqueObject:_channelName forKey:@"channels"];
                [currentInstallation saveInBackground];

                AVQuery *msgQuery = [AVQuery queryWithClassName:@"Message"];
                [msgQuery whereKey:@"channelName" equalTo:_channelName];
                [msgQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    if (!error) {
                        NSLog(@"retrieve msg count: %d", [objects count]);
                        [self updateMsgs:objects refresh:YES];
                    }
                }];
            }];
        } else {
            AVInstallation *currentInstallation = [AVInstallation currentInstallation];
            [currentInstallation addUniqueObject:_channelName forKey:@"channels"];
            [currentInstallation saveInBackground];

            // retrieve messages.
            AVQuery *msgQuery = [AVQuery queryWithClassName:@"Message"];
            [msgQuery whereKey:@"channelName" equalTo:_channelName];
            [msgQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (!error) {
                    [self updateMsgs:objects refresh:YES];
                }
            }];

        }
    }];
}

- (void)updateMsgs:(NSArray*)objects refresh:(BOOL)flag {
    if (!_msgs) {
        _msgs = [[NSMutableArray alloc] init];
    }
    if (flag) {
        [_msgs removeAllObjects];
    }
    [_msgs addObjectsFromArray:objects];
    [self.chatHistory reloadData];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"numberOfRows: %d", [_msgs count]);
    return [_msgs count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath row] >= [_msgs count])
        return nil;
    AVObject *msg = [_msgs objectAtIndex:[indexPath row]];
    NSString *type = [msg valueForKey:@"type"];
    if ([type compare:@"text"] == NSOrderedSame) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TextCell" forIndexPath:indexPath];
        cell.textLabel.text = [msg valueForKey:@"content"];
        return cell;
    } else {
        AVVMediaViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"VideoCell" forIndexPath:indexPath];
        cell.mediaFile = [msg valueForKey:@"avfile"];
        return cell;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return nil;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath row] >= [_msgs count]) {
        return 0.0;
    }
    AVObject *msg = [_msgs objectAtIndex:[indexPath row]];
    NSString *type = [msg valueForKey:@"type"];
    if ([type compare:@"text"] == NSOrderedSame) {
        return 44.0f;
    } else {
        return 320.0f;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.0f;
}

#pragma mark - AVOSCloudCaptureDelegate
- (void)finished:(BOOL)cancelled {
    [self.navigationController popToRootViewControllerAnimated:YES];
    if (!cancelled) {
        AVFile *videoFile = [AVFile fileWithName:[NSString stringWithFormat:@"%f.mp4", [NSDate timeIntervalSinceReferenceDate]] contentsAtPath:_currentVideo];
        [videoFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            AVObject *msg = [AVObject objectWithClassName:@"Message"];
            [msg setObject:_channelName forKey:@"channelName"];
            [msg setObject:videoFile forKey:@"avfile"];
            [msg setObject:[AVUser currentUser] forKey:@"spoke"];
            [msg setObject:@"video" forKey:@"type"];
            [msg saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (error) {
                    return ;
                };
                AVPush *push = [[AVPush alloc] init];
                [push setChannel:_channelName];
                [push setMessage:@"Update"];
                [push sendPushInBackground];
                
                [self updateMsgs:[NSArray arrayWithObjects:msg, nil] refresh:NO];
            }];
        }];
    } else {
        [AVAnalytics event:@"CaptureCancelled"];
    }
}

- (IBAction)sendMsg:(id)sender {
    NSString *content = [self.inputText text];
    if ([content length] < 1) {
        return;
    }
    AVObject *msg = [AVObject objectWithClassName:@"Message"];
    [msg setObject:_channelName forKey:@"channelName"];
    [msg setObject:content forKey:@"content"];
    [msg setObject:[AVUser currentUser] forKey:@"spoke"];
    [msg setObject:@"text" forKey:@"type"];
    [msg saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            return ;
        };
        // push to channel subscribe. oop, forgot to subscribe this channel when establishing.....
        AVPush *push = [[AVPush alloc] init];
        [push setChannel:_channelName];
        [push setMessage:@"Update"];
        [push sendPushInBackground];
        [self updateMsgs:[NSArray arrayWithObjects:msg, nil] refresh:NO];
    }];
    [self.inputText resignFirstResponder];
}

- (IBAction)openCamera:(id)sender {
    // open camera view controller, provided by AVOS Cloud
    AVSquareCaptureViewController *avsc = [[AVSquareCaptureViewController alloc] initWithCapturePreset:nil];
    avsc.delegate = self;
    _currentVideo = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%f.mp4", [NSDate timeIntervalSinceReferenceDate]]];
    avsc.finalOutputFile = _currentVideo;
    [self.navigationController pushViewController:avsc animated:YES];
}

#pragma mark - Responding to keyboard events
- (CGFloat)currentDefaultTableViewHeight {
    return TABLEVIEW_DEFAULT_HEIGHT;
}

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSLog(@"%@", userInfo);
    
    CGRect keyboardRect = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    CGSize screenSize = [ [ UIScreen mainScreen ] bounds ].size;
    NSLog(@"screenH: %f, keyboardH: %f, tableViewH: %f, footerViewH: %f",
          screenSize.height, keyboardRect.size.height,
          self.chatHistory.frame.size.height, self.footerView.frame.size.height);
    NSTimeInterval animationDuration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    NSInteger options = [userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    [UIView animateWithDuration:animationDuration delay:0 options:options animations:^{
        CGRect frame = self.chatHistory.frame;
        frame.size.height = frame.size.height - keyboardRect.size.height;
        self.chatHistory.frame = frame;
        self.footerView.frame = CGRectMake(0, frame.size.height, self.footerView.frame.size.width, self.footerView.frame.size.height);
    } completion:nil];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSLog(@"%@", userInfo);
    
    NSTimeInterval animationDuration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    NSInteger options = [userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    [UIView animateWithDuration:animationDuration delay:0 options:options animations:^{
        CGRect frame = self.chatHistory.frame;
        frame.size.height = [self currentDefaultTableViewHeight];
        self.chatHistory.frame = frame;
        self.footerView.frame = CGRectMake(0, frame.size.height, self.footerView.frame.size.width, self.footerView.frame.size.height);
    } completion:nil];
}

-(void)keyboardWillChangeFrame:(NSNotification *)notification {
}

@end
