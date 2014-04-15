//
//  AVSquareCaptureViewController.h
//  paas
//
//  Created by Feng Junwen on 3/11/14.
//  Copyright (c) 2014 AVOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AVOSCloudCaptureDelegate.h"

@interface AVSquareCaptureViewController : UIViewController

/**
 *  local video file path
 */
@property (copy, nonatomic) NSString *finalOutputFile;

/**
 *
 */
@property (readonly, copy, nonatomic) NSString *capturePreset;

/**
 *  Video Capture Delegate
 */
@property (strong, nonatomic) id<AVOSCloudCaptureDelegate> delegate;

/**
 *  initialize method
 */
- (id)initWithCapturePreset:(NSString*)preset;

@end
