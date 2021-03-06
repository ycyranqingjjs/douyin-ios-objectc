//
//  AVPlayerManager.h
//  Douyin
//
//  Created by Qiao Shi on 2018/7/30.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface AVPlayerManager:NSObject
+ (AVPlayerManager *)shareManager;
- (void)play:(AVPlayer *)player;
- (void)pause:(AVPlayer *)player;
- (void)pauseAll;
- (void)replay:(AVPlayer *)player;
@end
