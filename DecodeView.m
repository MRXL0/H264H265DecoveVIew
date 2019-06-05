//
//  DecodeView.m
//  VTH264examples
//
//  Created by tl on 2018/6/6.
//  Copyright © 2018年 srd. All rights reserved.
//

#import "DecodeView.h"

#import <AVFoundation/AVFoundation.h>

@interface DecodeView ()<H264HwDecoderImplDelegate>
@property (nonatomic,strong) H264HwDecoderImpl2 *h264Decoder2;
@property (nonatomic,strong) AVSampleBufferDisplayLayer *glLayer;

@property (nonatomic,assign) BOOL canPlay;
@end

@implementation DecodeView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupView];
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    _glLayer.frame = self.bounds;
    _glLayer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
}

- (void)saveThePicToPath:(NSString *)path {
    [_h264Decoder2 saveImageToPath:path];
}

- (void)setupView {
//    if (!_h264Decoder2) {
//        _h264Decoder2 = [[H264HwDecoderImpl3 alloc] init];
//    }
//
//    _h264Decoder2.delegate = self;
    
    if (!_glLayer) {
        _glLayer = [AVSampleBufferDisplayLayer new];
    }
    _glLayer.frame = self.bounds;
    _glLayer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    _glLayer.videoGravity = AVLayerVideoGravityResize;
    _glLayer.opaque = YES;
    _canPlay = YES;
//    [self.layer addSublayer:_glLayer];
}

- (void)decodeFile:(uint8_t*)buffer size:(NSInteger)size type:(VideoSteamType)type {
    if (!_h264Decoder2) {
        _h264Decoder2 = [[H264HwDecoderImpl2 alloc] initWithType:type];
        _h264Decoder2.delegate = self;
    }
    
    if (!_canPlay) {
//        free(buffer);
    }else {
        [_h264Decoder2 decodeNalu:buffer withSize:(int)size];
    }
}
-(void)willMoveToWindow:(UIWindow *)newWindow {
    
}
#pragma mark -  H264解码回调  H264HwDecoderImplDelegate delegare

- (void)displayDecodedFrame:(CMSampleBufferRef )imageBuffer {
    if(imageBuffer) {
        if ([_glLayer isReadyForMoreMediaData]) {
//            [NSThread sleepForTimeInterval:0.067 ];
//                        NSLog(@"thread is %@",[NSThread currentThread]);
            __weak typeof(self) weakSelf = self;
            if (!_canPlay) {
                CFRelease(imageBuffer);
                return;
            }
            dispatch_sync(dispatch_get_main_queue(),^{
                if (self.glLayer.superlayer == nil) {
                    [self.layer addSublayer:weakSelf.glLayer];
                }
            });
            [weakSelf.glLayer enqueueSampleBuffer:imageBuffer];
            if (weakSelf.glLayer.status == AVQueuedSampleBufferRenderingStatusFailed) {
                [weakSelf.glLayer flush];
            }
            
        }
        CFRelease(imageBuffer);
    }
}

- (void)dealloc {
    [_h264Decoder2 closed];
}

- (void)closed {
    __weak typeof(self) weakSelf = self;
    [[NSOperationQueue mainQueue]addOperationWithBlock:^{
        weakSelf.canPlay = NO;
        [self.glLayer removeFromSuperlayer];
    }];

}

- (void)started {
    _canPlay = YES;
}

@end
