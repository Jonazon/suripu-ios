#import "Sense-Swift.h"
#import "HEMMiniSleepScoreGraphView.h"
#import "HEMStyle.h"
#import "NSString+HEMUtils.h"

@interface HEMMiniSleepScoreGraphView()

@property (nonatomic, assign) NSUInteger sleepScore;
@property (nonatomic, strong) UIColor* conditionColor;

@end

@implementation HEMMiniSleepScoreGraphView

CGFloat const miniScoreBaseHeight = 72.f;

- (void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundColor = [UIColor clearColor];
    self.conditionColor = [UIColor colorForCondition:SENConditionUnknown];
}

- (void)drawRect:(CGRect)rect
{
    [self drawMiniSleepScoreGraphWithSleepScore:self.sleepScore sleepScoreHeight:miniScoreBaseHeight];
}

- (void)setSleepScore:(NSInteger)score color:(UIColor*)color {
    [self setSleepScore:score];
    [self setConditionColor:color];
    [self setNeedsDisplay];
}

- (void)drawMiniSleepScoreGraphWithSleepScore:(CGFloat)sleepScore sleepScoreHeight:(CGFloat)sleepScoreHeight
{
    //// General Declarations
    CGContextRef context = UIGraphicsGetCurrentContext();

    //// Color Declarations
    UIColor* sleepScoreOvalColor = [SenseStyle colorWithAClass:[self class] property:ThemePropertyBorderColor];

    //// Variable Declarations
    CGFloat graphPercentageAngle = MAX(MIN(sleepScore > 0 ? (sleepScore < 100 ? 400 - sleepScore * 0.01 * 300 : 0.01) : 0.01, 359), 102);
    NSString* sleepScoreText = sleepScore > 0 ? (sleepScore <= 100 ? [NSString stringWithFormat: @"%ld", (long)round(sleepScore)] : @"100") : @"";
    CGFloat sleepScoreTextSize = sleepScoreHeight / 2.3f;

    //// background oval Drawing
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 11.5, 5.5);
    CGContextRotateCTM(context, 141 * M_PI / 180);

    CGRect backgroundOvalRect = CGRectMake(-36.74, -77, sleepScoreHeight, sleepScoreHeight);
    UIBezierPath* backgroundOvalPath = UIBezierPath.bezierPath;
    [backgroundOvalPath addArcWithCenter: CGPointMake(CGRectGetMidX(backgroundOvalRect), CGRectGetMidY(backgroundOvalRect)) radius: CGRectGetWidth(backgroundOvalRect) / 2 startAngle: 0 * M_PI/180 endAngle: -102 * M_PI/180 clockwise: YES];

    [sleepScoreOvalColor setStroke];
    backgroundOvalPath.lineWidth = 1;
    [backgroundOvalPath stroke];

    CGContextRestoreGState(context);


    //// pie oval Drawing
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 11.5, 5.5);
    CGContextRotateCTM(context, 141 * M_PI / 180);

    CGRect pieOvalRect = CGRectMake(-36.74, -77.01, sleepScoreHeight, sleepScoreHeight);
    UIBezierPath* pieOvalPath = UIBezierPath.bezierPath;
    [pieOvalPath addArcWithCenter: CGPointMake(CGRectGetMidX(pieOvalRect), CGRectGetMidY(pieOvalRect)) radius: CGRectGetWidth(pieOvalRect) / 2 startAngle: 0 * M_PI/180 endAngle: -graphPercentageAngle * M_PI/180 clockwise: YES];

    [[self conditionColor] setStroke];
    pieOvalPath.lineWidth = 1;
    [pieOvalPath stroke];

    CGContextRestoreGState(context);


    //// sleep score label Drawing
    CGRect sleepScoreLabelRect = CGRectMake(1, 5.67, 77, 67.53);
    NSMutableParagraphStyle* sleepScoreLabelStyle = NSMutableParagraphStyle.defaultParagraphStyle.mutableCopy;
    sleepScoreLabelStyle.alignment = NSTextAlignmentCenter;

    NSDictionary* sleepScoreLabelFontAttributes = @{
        NSFontAttributeName: [UIFont timelineHistoryScoreFontOfSize:sleepScoreTextSize],
        NSForegroundColorAttributeName: [self conditionColor],
        NSParagraphStyleAttributeName: sleepScoreLabelStyle};

    NSStringDrawingOptions options = NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin;
    CGFloat sleepScoreWidth = CGRectGetWidth(sleepScoreLabelRect);
    CGFloat sleepScoreLabelTextHeight = [sleepScoreText heightBoundedByWidth:sleepScoreWidth
                                                                  attributes:sleepScoreLabelFontAttributes
                                                          withDrawingOptions:options];

    CGContextSaveGState(context);
    CGContextClipToRect(context, sleepScoreLabelRect);
    [sleepScoreText drawInRect: CGRectMake(CGRectGetMinX(sleepScoreLabelRect), CGRectGetMinY(sleepScoreLabelRect) + (CGRectGetHeight(sleepScoreLabelRect) - sleepScoreLabelTextHeight) / 2, CGRectGetWidth(sleepScoreLabelRect), sleepScoreLabelTextHeight) withAttributes: sleepScoreLabelFontAttributes];
    CGContextRestoreGState(context);
}

@end
