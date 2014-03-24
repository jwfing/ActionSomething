//
//  AVVPlayer.m
//  AVVideoSample
//
//  Created by Feng Junwen on 3/17/14.
//  Copyright (c) 2014 Feng Junwen. All rights reserved.
//

#import "AVVPlayer.h"

@implementation AVVPlayer

+ (AVVPlayer *)sharedInstance {
    static dispatch_once_t once;
    static AVVPlayer *_sharedInstance;
    dispatch_once(&once, ^{
        _sharedInstance = [[AVVPlayer alloc] init];
        [_sharedInstance commonInit];
    });
    return _sharedInstance;
}

- (void)commonInit {
    self.controlStyle = MPMovieControlStyleNone;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:nil];
}

- (void)setMovieLocalPath:(NSString *)localPath {
    [self setContentURL:localPath == nil ? nil : [NSURL fileURLWithPath:localPath]];
}

#pragma mark - Action
- (void)togglePlay:(id)sender {
    if (self.playbackState == MPMoviePlaybackStatePlaying) {
        [self pause];
    }else {
        [self play];
    }
}

#pragma mark - Notification
- (void)playerItemDidReachEnd:(NSNotification *)notification {
    // ignore others
    if ([notification object] != self) return;
    [self.view removeFromSuperview];
}

@end
