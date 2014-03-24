//
//  AVVMediaViewCell.m
//  AVVideoSample
//
//  Created by Feng Junwen on 3/17/14.
//  Copyright (c) 2014 Feng Junwen. All rights reserved.
//

#import "AVVMediaViewCell.h"
#import "AVVPlayer.h"

@implementation AVVMediaViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
    // Initialization code
    NSLog(@"awakeFromNib");
    [self.contentView setBackgroundColor:[UIColor whiteColor]];
    
    // video
    _videoContainerView = [[UIView alloc] initWithFrame:CGRectMake(10, 10, 300, 300)];
    
    _thumbnailImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 300, 300)];
    _thumbnailImageView.userInteractionEnabled = YES;
    [_thumbnailImageView setImage:[UIImage imageNamed:@"default_video"]];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playPauseTap:)];
    [_thumbnailImageView addGestureRecognizer:tap];
    
    [_videoContainerView addSubview:self.thumbnailImageView];
    
    [self.contentView addSubview:_videoContainerView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)playPauseTap:(id)sender {
    NSLog(@"playPauseTap");
    NSString *fileName = [self.mediaFile name];
    NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@", fileName]];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    if (fileExists) {
        NSLog(@"%@ existed.", filePath);
        [AVVPlayer sharedInstance].shouldAutoplay = NO;
        [AVVPlayer sharedInstance].view.frame = _videoContainerView.bounds;
        [_videoContainerView insertSubview:[AVVPlayer sharedInstance].view atIndex:1];
        NSURL *url = [[NSURL alloc] initFileURLWithPath:filePath];
        [[AVVPlayer sharedInstance] setContentURL:url];
        [[AVVPlayer sharedInstance] prepareToPlay];
        [[AVVPlayer sharedInstance] play];
    } else {
        NSLog(@"%@ not existed, try to download...", filePath);
        [self.mediaFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (error) {
                return;
            }
            [data writeToFile:filePath atomically:YES];
            [AVVPlayer sharedInstance].shouldAutoplay = NO;
            [AVVPlayer sharedInstance].view.frame = _videoContainerView.bounds;
            [_videoContainerView insertSubview:[AVVPlayer sharedInstance].view atIndex:1];
            NSURL *url = [[NSURL alloc] initFileURLWithPath:filePath];
            [[AVVPlayer sharedInstance] setContentURL:url];
            [[AVVPlayer sharedInstance] prepareToPlay];
            [[AVVPlayer sharedInstance] play];
        }];
    }
}

@end
