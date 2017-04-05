//
//  HEMTrendsScoreLabel.m
//  Sense
//
//  Created by Jimmy Lu on 2/9/16.
//  Copyright © 2016 Hello. All rights reserved.
//
#import "Sense-Swift.h"
#import "HEMTrendsScoreLabel.h"

static CGFloat const HEMTrendsScoreBorderWidth = 1.0f;
static CGFloat const HEMTrendsScoreHighlightWidth = 4.0f;

@implementation HEMTrendsScoreLabel

- (void)reuse {
    [self setScoreBorderColor:nil];
    [self setScoreColor:nil];
    [self setText:nil];
    [self setAttributedText:nil];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    UIColor* fillColor = [self scoreColor];
    if (!fillColor) {
        fillColor = [self backgroundColor];
    }
    
    UIColor* borderColor = [self scoreBorderColor];
    if (!borderColor) {
        borderColor = [SenseStyle colorWithAClass:[self class] property:ThemePropertyBorderColor];
    }
    
    CGFloat borderInset = HEMTrendsScoreBorderWidth / 2.0f;
    CGFloat highlightInset = [self isHighlighted] ? (HEMTrendsScoreHighlightWidth / 2.0f) : 0.0f;
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGContextSetStrokeColorWithColor(context, [borderColor CGColor]);
    CGContextSetFillColorWithColor(context, [fillColor CGColor]);
    CGContextSetLineWidth(context, HEMTrendsScoreBorderWidth);
    CGContextFillEllipseInRect (context, CGRectInset([self bounds], highlightInset, highlightInset));
    CGContextStrokeEllipseInRect(context, CGRectInset([self bounds], borderInset, borderInset));
    CGContextFillPath(context);
    CGContextRestoreGState(context);
    
    [super drawRect:rect];
}

- (void)applyStyle {
    [self applyFillStyle];
    [self setNeedsDisplay];
}

@end
