#import "Sense-Swift.h"
#import "HEMSleepSegmentCollectionViewCell.h"
#import "NSAttributedString+HEMUtils.h"

CGFloat const HEMLinedCollectionViewCellLineOffset = 65.f;
CGFloat const HEMLinedCollectionViewCellLineWidth = 2.f;
CGFloat const HEMSleepLineWidth = 1.f;
CGFloat const HEMSegmentPrefillTimeInset = 12.f;

@interface HEMSleepSegmentCollectionViewCell ()

@property (nonatomic, readwrite) CGFloat fillRatio;
@property (nonatomic, readwrite) CGFloat previousFillRatio;
@property (nonatomic, strong) NSMutableArray *timeViews;
@property (nonatomic, strong) UIColor *fillColor;
@property (nonatomic, strong) UIColor *preFillColor;
@property (nonatomic, strong) HEMGradient* barLineGradient;
@property (nonatomic, getter=isWaitingForAnimation, readwrite) BOOL waitingForAnimation;
@end

@implementation HEMSleepSegmentCollectionViewCell

CGFloat const HEMSegmentTimeLabelHeight = 16.f;
CGFloat const HEMSegmentBorderWidth = 1.f;
CGFloat const HEMSegmentMinimumWidth = 32.f;
CGFloat const HEMSegmentMaximumWidthRatio = 0.825f;

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.opaque = YES;
    self.timeViews = [NSMutableArray new];
    self.backgroundColor = [SenseStyle colorWithAClass:[HEMSleepSegmentCollectionViewCell class]
                                              property:ThemePropertyBackgroundColor];
    self.barLineGradient = [HEMGradient gradientForTimelineSleepSegment];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.clipsToBounds = YES;
    self.waitingForAnimation = NO;
}

- (void)setNeedsLayout {
    [super setNeedsLayout];
    [self setNeedsDisplay];
}

- (void)prepareForEntryAnimation {
    self.waitingForAnimation = YES;
}

- (void)cancelEntryAnimation {
    self.waitingForAnimation = NO;
}

- (void)performEntryAnimationWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay {
    self.waitingForAnimation = NO;
}

- (void)removeAllTimeLabels {
    [self.timeViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.timeViews removeAllObjects];
}

- (NSUInteger)numberOfTimeLabels {
    return self.timeViews.count;
}

- (void)addTimeLabelWithText:(NSAttributedString *)text atHeightRatio:(CGFloat)heightRatio {
    static CGFloat const HEMTimeLabelLineOffset = 6.f;
    static CGFloat const HEMTimeLabelLineTrailing = 8.f;
    self.clipsToBounds = NO;
    CGFloat lineYOffset = MAX(ceilf(HEMSegmentTimeLabelHeight / 2),
                              MIN(CGRectGetHeight(self.bounds) * heightRatio,
                                  MAX(0, CGRectGetHeight(self.frame) - HEMSegmentTimeLabelHeight)));
    CGFloat labelYOffset = lineYOffset - floorf(HEMSegmentTimeLabelHeight / 2);
    CGSize size = [text sizeWithHeight:HEMSegmentTimeLabelHeight];
    CGRect labelRect = CGRectMake(CGRectGetWidth(self.bounds) - size.width - HEMTimeLabelLineTrailing, labelYOffset,
                                  size.width, HEMSegmentTimeLabelHeight);
    
    UIColor* timeColor = [SenseStyle colorWithAClass:[HEMSleepSegmentCollectionViewCell class]
                                            property:ThemePropertyHintColor];
    
    UILabel *timeLabel = [[UILabel alloc] initWithFrame:labelRect];
    timeLabel.attributedText = text;
    timeLabel.textColor = timeColor;
    [[self contentView] addSubview:timeLabel];
    CGRect lineRect
        = CGRectMake(0, lineYOffset, CGRectGetMinX(labelRect) - HEMTimeLabelLineOffset, HEMSegmentBorderWidth);
    UIImageView *lineView = [[UIImageView alloc] initWithFrame:lineRect];
    lineView.image = [self lineBorderImageWithColor:[timeColor colorWithAlphaComponent:0.25f]];
    [[self contentView] insertSubview:lineView atIndex:0];
    [self.timeViews addObject:lineView];
    [self.timeViews addObject:timeLabel];
}

- (UIImage *)lineBorderImageWithColor:(UIColor *)color {
    CGSize size = CGSizeMake(CGRectGetWidth(self.bounds) / 2, HEMSegmentBorderWidth);
    UIGraphicsBeginImageContext(size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(ctx, color.CGColor);
    CGContextSetLineWidth(ctx, HEMSegmentBorderWidth);
    CGFloat y = size.height - (HEMSegmentBorderWidth / 2);
    CGContextMoveToPoint(ctx, 0, y);
    CGContextAddLineToPoint(ctx, size.width, y);
    CGContextStrokePath(ctx);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void)setSegmentRatio:(CGFloat)ratio
          withFillColor:(UIColor *)color
          previousRatio:(CGFloat)previousRatio
          previousColor:(UIColor *)previousColor {
    self.fillRatio = MIN(ratio, 1.0);
    self.fillColor = color;
    self.preFillColor = previousColor ?: [UIColor clearColor];
    self.previousFillRatio = previousRatio;
    [self setNeedsDisplay];
}

- (CGRect)preFillArea {
    CGFloat maximumFillWidth = CGRectGetWidth(self.bounds) * HEMSegmentMaximumWidthRatio;
    CGFloat preWidth = MAX(HEMSegmentMinimumWidth, maximumFillWidth * self.previousFillRatio);
    return CGRectMake(0, 0, preWidth, HEMSegmentPrefillTimeInset);
}

- (CGRect)fillArea {
    CGFloat maximumFillWidth = CGRectGetWidth(self.bounds) * HEMSegmentMaximumWidthRatio;
    CGFloat width = MAX(HEMSegmentMinimumWidth, maximumFillWidth * self.fillRatio);
    return CGRectMake(0, HEMSegmentPrefillTimeInset, width, CGRectGetHeight(self.bounds) - HEMSegmentPrefillTimeInset);
}

- (void)drawRect:(CGRect)rect {
    CGRect preRect = [self preFillArea];
    CGRect fillRect = [self fillArea];
    [self.fillColor setFill];
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextFillRect(ctx, fillRect);
    [self.preFillColor setFill];
    CGContextFillRect(ctx, preRect);
}

@end
