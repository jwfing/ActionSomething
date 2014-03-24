//
//  AVVLoginViewController.m
//  ActionSomething
//
//  Created by Feng Junwen on 3/18/14.
//  Copyright (c) 2014 Feng Junwen. All rights reserved.
//

#import "AVVLoginViewController.h"
#import <AVOSCloudSNS/AVOSCloudSNS.h>
#import <AVOSCloud/AVOSCloud.h>
#import <AVOSCloudSNS/AVUser+SNS.h>

@interface AVVLoginViewController ()

@end

@implementation AVVLoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loginWithWeibo:(id)sender {
    [AVOSCloudSNS loginWithCallback:^(id object, NSError *error) {
        if (object) {
            [AVUser loginWithAuthData:object block:^(AVUser *user, NSError *error) {
                if (user) {
                    [self.navigationController popToRootViewControllerAnimated:YES];
                } else {
                    NSLog(@"failed to create new user.");
                }
            }];
        } else {
            NSLog(@"failed to login!");
        }
    } toPlatform:AVOSCloudSNSSinaWeibo];
}

@end