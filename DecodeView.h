//
//  DecodeView.h
//  VTH264examples
//
//  Created by tl on 2018/6/6.
//  Copyright © 2018年 srd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "H264HwDecoderImpl2.h"

@interface DecodeView : UIView

- (void)decodeFile:(uint8_t*)buffer size:(NSInteger)size type:(VideoSteamType)type;
- (void)closed;
- (void)started;
- (void)setupView;
- (void)saveThePicToPath:(NSString *)path;
@end
