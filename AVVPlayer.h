//
//  AVVPlayer.h
//  AVVideoSample
//
//  Created by Feng Junwen on 3/17/14.
//  Copyright (c) 2014 Feng Junwen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface AVVPlayer : MPMoviePlayerController

+ (AVVPlayer *)sharedInstance;
- (void)setMovieLocalPath:(NSString *)localPath;

@end
