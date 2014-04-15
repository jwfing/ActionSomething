//
//  AVOSCloudCaptureDelegate.h
//  paas
//
//  Created by Feng Junwen on 3/13/14.
//  Copyright (c) 2014 AVOS. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AVOSCloudCaptureDelegate <NSObject>

/**
 *  Video Capture Delegate
 *
 * cancelled - whether user cancelled capture.
 *
 */

- (void)finished:(BOOL)cancelled;

@end
