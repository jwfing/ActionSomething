//
//  AVVMediaViewCell.h
//  AVVideoSample
//
//  Created by Feng Junwen on 3/17/14.
//  Copyright (c) 2014 Feng Junwen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVOSCloud/AVOSCloud.h>

@interface AVVMediaViewCell : UITableViewCell <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIImageView *thumbnailImageView;
@property (nonatomic, weak) UIViewController *parentController;
@property (nonatomic, strong, readonly) UIView *videoContainerView;

@property (nonatomic, strong) AVFile *mediaFile;

@end
