
#import "HEMPresleepHeaderCollectionReusableView.h"
#import "HEMTimelineDrawingUtils.h"
#import "HelloStyleKit.h"

CGFloat const HEMPresleepSummaryLineOffset = 20.f;

@interface HEMPresleepHeaderCollectionReusableView ()

@property (weak, nonatomic) IBOutlet UILabel* titleLabel;
@property (nonatomic, strong) CAGradientLayer* gradientLayer;
@end

@implementation HEMPresleepHeaderCollectionReusableView

static CGFloat const HEMPresleepSummaryShadowHeight = 1.f;

- (void)awakeFromNib
{
    self.backgroundColor = [UIColor clearColor];
    self.titleLabel.text = [NSLocalizedString(@"sleep-history.presleep-state.title", nil) uppercaseString];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (!self.gradientLayer) {
        UIColor* topColor = [HelloStyleKit timelineGradientDarkColor];
        UIColor* bottomColor = [UIColor whiteColor];
        self.gradientLayer = [CAGradientLayer layer];
        CGRect gradientRect = self.bounds;
        CGFloat offset = HEMPresleepSummaryShadowHeight + HEMPresleepSummaryLineOffset;
        gradientRect.origin.y += offset;
        gradientRect.size.height -= offset;
        self.gradientLayer.frame = gradientRect;
        self.gradientLayer.colors = @[(id)topColor.CGColor, (id)bottomColor.CGColor];
        [self.layer insertSublayer:self.gradientLayer atIndex:0];
    }
}

- (void)drawRect:(CGRect)rect
{
    [self drawShadowGradientInRect:rect];
}

- (void)drawShadowGradientInRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGRect shadowRect = CGRectMake(CGRectGetMinX(rect), CGRectGetMinY(rect) + HEMPresleepSummaryLineOffset, CGRectGetWidth(rect), HEMPresleepSummaryShadowHeight);
    CGContextSetFillColorWithColor(ctx, [HelloStyleKit timelineSectionBorderColor].CGColor);
    CGContextFillRect(ctx, shadowRect);
}

@end
