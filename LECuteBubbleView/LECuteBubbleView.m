//
//  LECuteBubbleView.m
//  LECuteBubbleView
//
//  Created by 陈记权 on 7/6/16.
//  Copyright © 2016 LeEco. All rights reserved.
//

#import "LECuteBubbleView.h"

@interface LECuteBubbleView ()
{
    UIView *m_backView;
    
    UIBezierPath *m_cutePath;
    
    CGFloat m_x1;
    CGFloat m_y1;
    CGFloat m_x2;
    CGFloat m_y2;
    
    CGFloat m_r1;
    CGFloat m_r2;
    
    CGFloat m_centerDistance;
    CGFloat m_cosDigree;
    CGFloat m_sinDigree;
    
    CGPoint m_pointA;
    CGPoint m_pointB;
    CGPoint m_pointC;
    CGPoint m_pointD;
    CGPoint m_pointO;
    CGPoint m_pointP;
    
    CGRect m_oldBackViewFrame;
    CGPoint m_oldBackViewCenter;
    
    CAShapeLayer *m_shapeLayer;
    CGPoint m_initialPoint;
}
@end

@implementation LECuteBubbleView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createSubViews];
    }
    return self;
}

- (void)awakeFromNib
{
    [self createSubViews];
}

- (void)createSubViews
{
    self.viscosity = 20.0f;
    self.fillColorForCute = [UIColor colorWithRed:0 green:0.722 blue:1 alpha:1];
    self.backgroundColor = [UIColor clearColor];
    m_shapeLayer = [CAShapeLayer layer];
    
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.frontView = [UIView new];
    self.frontView.backgroundColor = self.fillColorForCute;
    self.frontView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.frontView];
    
    NSArray *constraintsHF =[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[F]|"
                                                                    options:NSLayoutFormatDirectionLeadingToTrailing
                                                                    metrics:nil
                                                                      views:@{@"F" : self.frontView}];
    
    NSArray *constraintsVF =[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[F]|"
                                                                    options:NSLayoutFormatAlignAllTop
                                                                    metrics:nil
                                                                      views:@{@"F" : self.frontView}];
    [self addConstraints:constraintsHF];
    [self addConstraints:constraintsVF];
    
    self.bubbleLabel = [UILabel new];
    self.bubbleLabel.textAlignment = NSTextAlignmentCenter;
    self.bubbleLabel.text = @"99";
    self.bubbleLabel.textColor = [UIColor whiteColor];
    self.bubbleLabel.font = [UIFont systemFontOfSize:12];
    self.bubbleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.frontView addSubview:self.bubbleLabel];
    
    NSArray *constraintsHL =[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[L]|"
                                                                    options:NSLayoutFormatDirectionLeadingToTrailing
                                                                    metrics:nil
                                                                      views:@{@"L" : self.bubbleLabel}];
    
    NSArray *constraintsVL =[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[L]|"
                                                                    options:NSLayoutFormatAlignAllTop
                                                                    metrics:nil
                                                                      views:@{@"L" : self.bubbleLabel}];
    
    [self.frontView addConstraints:constraintsHL];
    [self.frontView addConstraints:constraintsVL];
    
    
    m_backView = [UIView new];
    m_backView.translatesAutoresizingMaskIntoConstraints = NO;
    m_backView.backgroundColor = self.fillColorForCute;
    [self insertSubview:m_backView atIndex:0];
    
    NSLayoutConstraint *constraintsCB = [NSLayoutConstraint
                                         constraintWithItem:m_backView
                                         attribute:NSLayoutAttributeCenterX
                                         relatedBy:NSLayoutRelationEqual
                                         toItem:self
                                         attribute:NSLayoutAttributeCenterX
                                         multiplier:1
                                         constant:0];
    
    NSArray *constraintsVB =[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[B]|"
                                                                    options:NSLayoutFormatAlignAllTop
                                                                    metrics:nil
                                                                      views:@{@"B" : m_backView}];
    
    
    NSLayoutConstraint *constraintsWB = [NSLayoutConstraint
                                         constraintWithItem:m_backView
                                         attribute:NSLayoutAttributeWidth
                                         relatedBy:NSLayoutRelationEqual
                                         toItem:self
                                         attribute:NSLayoutAttributeHeight
                                         multiplier:1
                                         constant:0];
    [self addConstraint:constraintsCB];
    [self addConstraints:constraintsVB];
    [self addConstraint:constraintsWB];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self
                                                                         action:@selector(handleDragGesture:)];
    [self.frontView addGestureRecognizer:pan];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self relayoutedSubviews];
}

- (void)relayoutedSubviews
{
    CGFloat minSize = MIN(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
    
    self.frontView.layer.cornerRadius = minSize / 2.0f;
    self.frontView.layer.masksToBounds = YES;
    
    m_backView.layer.cornerRadius = minSize / 2.0f;
    m_backView.layer.masksToBounds = YES;
    
    m_oldBackViewFrame = m_backView.frame;
    m_oldBackViewCenter = m_backView.center;
    
    m_x1 = m_backView.center.x;
    m_y1 = m_backView.center.y;
    
    m_x2 = self.frontView.center.x;
    m_y2 = self.frontView.center.y;
    
    m_r2 = minSize / 2.0f;
    m_r1 = CGRectGetWidth(m_backView.bounds) / 2.0f;
}

- (void)drawRect
{
    m_x1 = m_backView.center.x;
    m_y1 = m_backView.center.y;
    
    m_x2 = self.frontView.center.x;
    m_y2 = self.frontView.center.y;
    
    m_centerDistance = sqrtf(pow(m_x2 - m_x1, 2) + pow((m_y2 - m_y1), 2));
    
    if (m_centerDistance == 0) {
        m_cosDigree = 1;
        m_sinDigree = 0.0f;
    } else {
        m_cosDigree = (m_y2 - m_y1) / m_centerDistance;
        m_sinDigree = (m_x2 - m_x1) / m_centerDistance;
    }
    
    m_r1 = m_oldBackViewFrame.size.width / 2.0f - (m_centerDistance == 0 ? 0 : m_centerDistance / self.viscosity);
    
    
    m_pointA = CGPointMake(m_x1 - m_r1 * m_cosDigree, m_y1 + m_r1 * m_sinDigree);
    m_pointB = CGPointMake(m_x1 + m_r1 * m_cosDigree, m_y1 - m_r1 * m_sinDigree);
    
    m_pointC = CGPointMake(m_x2 + m_r2 * m_cosDigree, m_y2 - m_r2 * m_sinDigree);
    m_pointD = CGPointMake(m_x2 - m_r2 * m_cosDigree, m_y2 + m_r2 * m_sinDigree);
    
    m_pointO = CGPointMake(m_pointA.x + (m_centerDistance / 2.0f * m_sinDigree), m_pointA.y + (m_centerDistance / 2.0f * m_cosDigree));
    m_pointP = CGPointMake(m_pointB.x + (m_centerDistance / 2.0f * m_sinDigree), m_pointB.y + (m_centerDistance / 2.0f * m_cosDigree));
    
    m_backView.center = m_oldBackViewCenter;
    m_backView.bounds = CGRectMake(0, 0, m_r1 * 2, m_r1 * 2);
    m_backView.layer.cornerRadius = m_r1;
    
    m_cutePath = [UIBezierPath bezierPath];
    [m_cutePath moveToPoint:m_pointA];
    [m_cutePath addQuadCurveToPoint:m_pointD controlPoint:m_pointO];
    [m_cutePath addLineToPoint:m_pointC];
    [m_cutePath addQuadCurveToPoint:m_pointB controlPoint:m_pointP];
    [m_cutePath moveToPoint:m_pointA];
    
    if (m_backView.hidden == NO) {
        m_shapeLayer.path = [m_cutePath CGPath];
        m_shapeLayer.fillColor = [self.fillColorForCute CGColor];
        [self.layer insertSublayer:m_shapeLayer below:self.frontView.layer];
    }
}

- (void)handleDragGesture:(UIPanGestureRecognizer *)gestureRecognizer
{
    CGPoint dragPoint = [gestureRecognizer locationInView:self];
    
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
        {
            m_backView.hidden = NO;
            [self removeAnimationLikeGameCenterBubble];
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            self.frontView.center = dragPoint;
            
            if (m_r1 <= 6) {
                m_backView.hidden = YES;
                [m_shapeLayer removeFromSuperlayer];
            } else {
                [self drawRect];
            }
        }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        {
            m_backView.hidden = YES;
            
            [m_shapeLayer removeFromSuperlayer];
            
            [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.4 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.frontView.center = m_oldBackViewCenter;
                
            } completion:^(BOOL finished) {
                if (finished) {
                    m_backView.frame = m_oldBackViewFrame;
                    m_backView.layer.cornerRadius = CGRectGetWidth(m_oldBackViewFrame) / 2.0f;
                    m_r1 = CGRectGetWidth(m_backView.bounds) / 2.0f;
                    [self addAniamtionLikeGameCenterBubble];
                }
            }];
        }
            break;
        default:
            break;
    }
}

- (void)addAniamtionLikeGameCenterBubble
{
    CAKeyframeAnimation *pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    pathAnimation.calculationMode = kCAAnimationPaced;
    pathAnimation.fillMode = kCAFillModeForwards;
    pathAnimation.removedOnCompletion = YES;
    pathAnimation.repeatCount = INFINITY;
    pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    pathAnimation.duration = 5.0f;
    
    CGMutablePathRef curvedPath = CGPathCreateMutable();
    CGRect circleContainer = CGRectInset(self.frontView.frame,
                                         CGRectGetWidth(self.frontView.frame) / 2 - 3,
                                         CGRectGetWidth(self.frontView.frame) / 2 - 3);
    
    CGPathAddEllipseInRect(curvedPath, NULL, circleContainer);
    pathAnimation.path = curvedPath;
    CGPathRelease(curvedPath);
    
    [self.frontView.layer addAnimation:pathAnimation forKey:@"myCircleAnimation"];
    
    CAKeyframeAnimation *scaleX = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale.x"];
    scaleX.duration = 1.0f;
    scaleX.values = @[@1.0f, @1.1f, @1.0f];
    scaleX.keyTimes = @[@0.0f, @0.5f, @1.0f];
    scaleX.repeatCount = INFINITY;
    scaleX.autoreverses = YES;
    scaleX.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [self.frontView.layer addAnimation:scaleX forKey:@"transform.scale.x"];
    
    CAKeyframeAnimation *scaleY = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale.y"];
    scaleY.duration = 1.5f;
    scaleY.values = @[@1.0f, @1.1f, @1.0f];
    scaleY.keyTimes = @[@0.0f, @0.5f, @1.0f];
    scaleY.repeatCount = INFINITY;
    scaleY.autoreverses = YES;
    scaleY.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [self.frontView.layer addAnimation:scaleY forKey:@"transform.scale.y"];
}

- (void)removeAnimationLikeGameCenterBubble
{
    [self.frontView.layer removeAllAnimations];
}

@end
