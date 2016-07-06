//
//  LECuteBubbleView.h
//  LECuteBubbleView
//
//  Created by 陈记权 on 7/6/16.
//  Copyright © 2016 LeEco. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LECuteBubbleView : UIView

@property (nonatomic, strong) UIView *frontView;

@property (nonatomic, strong) UILabel *bubbleLabel;

@property (nonatomic, assign) CGFloat bubbleWidth;

@property (nonatomic, strong) UIColor *fillColorForCute;

/**
 *  粘性, 粘性越大, 可拉伸长度越长
 */
@property (nonatomic, assign) CGFloat viscosity;

@end
