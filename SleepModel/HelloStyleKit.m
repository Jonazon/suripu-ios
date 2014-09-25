//
//  HelloStyleKit.m
//  Sleep Sense
//
//  Created by Delisa Mason on 9/25/14.
//  Copyright (c) 2014 Hello. All rights reserved.
//
//  Generated by PaintCode (www.paintcodeapp.com)
//

#import "HelloStyleKit.h"


@implementation HelloStyleKit

#pragma mark Cache

static UIColor* _darkBlueColor = nil;
static UIColor* _mediumBlueColor = nil;
static UIColor* _currentConditionsBackgroundColor = nil;
static UIColor* _highSleepScoreColor = nil;
static UIColor* _poorSleepScoreColor = nil;
static UIColor* _averageSleepScoreColor = nil;
static UIColor* _lightBlueColor = nil;
static UIColor* _lightestBlueColor = nil;
static UIColor* _alertSensorColor = nil;
static UIColor* _idealSensorColor = nil;
static UIColor* _warningSensorColor = nil;
static UIColor* _lightSleepColor = nil;
static UIColor* _intermediateSleepColor = nil;
static UIColor* _deepSleepColor = nil;
static UIColor* _awakeSleepColor = nil;

static PCGradient* _blueBackgroundGradient = nil;

static UIImage* _alarmEnabledIcon = nil;
static UIImage* _chevronIconLeft = nil;
static UIImage* _alarmNoteIcon = nil;
static UIImage* _questionIcon = nil;
static UIImage* _settingsIcon = nil;
static UIImage* _onboardingBackgroundImage1 = nil;
static UIImage* _onboardingBackgroundImage2 = nil;
static UIImage* _bluetoothLogoImage = nil;
static UIImage* _wifiLogoImage = nil;
static UIImage* _humidityIcon = nil;
static UIImage* _particleIcon = nil;
static UIImage* _temperatureIcon = nil;
static UIImage* _lightEventIcon = nil;
static UIImage* _noiseEventIcon = nil;
static UIImage* _sleepEventIcon = nil;
static UIImage* _wakeupEventIcon = nil;
static UIImage* _chevronIconRight = nil;
static UIImage* _motionEventIcon = nil;
static UIImage* _alarmsIcon = nil;
static UIImage* _sleepInsightsIcon = nil;
static UIImage* _senseIcon = nil;
static UIImage* _pillIcon = nil;

#pragma mark Initialization

+ (void)initialize
{
    // Colors Initialization
    _darkBlueColor = [UIColor colorWithRed: 0.314 green: 0.325 blue: 0.529 alpha: 1];
    _mediumBlueColor = [UIColor colorWithRed: 0.184 green: 0.514 blue: 0.639 alpha: 1];
    _currentConditionsBackgroundColor = [UIColor colorWithRed: 0.902 green: 0.91 blue: 0.906 alpha: 1];
    _highSleepScoreColor = [UIColor colorWithRed: 0.368 green: 0.8 blue: 0.32 alpha: 1];
    _poorSleepScoreColor = [UIColor colorWithRed: 0.8 green: 0.339 blue: 0.32 alpha: 1];
    _averageSleepScoreColor = [UIColor colorWithRed: 0.947 green: 0.901 blue: 0.5 alpha: 1];
    _lightBlueColor = [UIColor colorWithRed: 0.733 green: 0.851 blue: 0.929 alpha: 1];
    _lightestBlueColor = [UIColor colorWithRed: 0.918 green: 0.945 blue: 0.949 alpha: 1];
    _alertSensorColor = [UIColor colorWithRed: 0.957 green: 0.486 blue: 0.125 alpha: 1];
    _idealSensorColor = [UIColor colorWithRed: 0.267 green: 0.847 blue: 0.455 alpha: 1];
    _warningSensorColor = [UIColor colorWithRed: 0.957 green: 0.22 blue: 0.133 alpha: 1];
    _lightSleepColor = [UIColor colorWithRed: 0.416 green: 0.675 blue: 0.988 alpha: 1];
    _intermediateSleepColor = [UIColor colorWithRed: 0.302 green: 0.588 blue: 0.941 alpha: 1];
    _deepSleepColor = [UIColor colorWithRed: 0.153 green: 0.435 blue: 0.851 alpha: 1];
    _awakeSleepColor = [UIColor colorWithRed: 0.32 green: 0.356 blue: 0.8 alpha: 0];

    // Gradients Initialization
    CGFloat blueBackgroundGradientLocations[] = {0, 1};
    _blueBackgroundGradient = [PCGradient gradientWithColors: @[HelloStyleKit.darkBlueColor, HelloStyleKit.mediumBlueColor] locations: blueBackgroundGradientLocations];

}

#pragma mark Colors

+ (UIColor*)darkBlueColor { return _darkBlueColor; }
+ (UIColor*)mediumBlueColor { return _mediumBlueColor; }
+ (UIColor*)currentConditionsBackgroundColor { return _currentConditionsBackgroundColor; }
+ (UIColor*)highSleepScoreColor { return _highSleepScoreColor; }
+ (UIColor*)poorSleepScoreColor { return _poorSleepScoreColor; }
+ (UIColor*)averageSleepScoreColor { return _averageSleepScoreColor; }
+ (UIColor*)lightBlueColor { return _lightBlueColor; }
+ (UIColor*)lightestBlueColor { return _lightestBlueColor; }
+ (UIColor*)alertSensorColor { return _alertSensorColor; }
+ (UIColor*)idealSensorColor { return _idealSensorColor; }
+ (UIColor*)warningSensorColor { return _warningSensorColor; }
+ (UIColor*)lightSleepColor { return _lightSleepColor; }
+ (UIColor*)intermediateSleepColor { return _intermediateSleepColor; }
+ (UIColor*)deepSleepColor { return _deepSleepColor; }
+ (UIColor*)awakeSleepColor { return _awakeSleepColor; }

#pragma mark Gradients

+ (PCGradient*)blueBackgroundGradient { return _blueBackgroundGradient; }

#pragma mark Images

+ (UIImage*)alarmEnabledIcon { return _alarmEnabledIcon ?: (_alarmEnabledIcon = [UIImage imageNamed: @"alarmEnabledIcon"]); }
+ (UIImage*)chevronIconLeft { return _chevronIconLeft ?: (_chevronIconLeft = [UIImage imageNamed: @"chevronIconLeft"]); }
+ (UIImage*)alarmNoteIcon { return _alarmNoteIcon ?: (_alarmNoteIcon = [UIImage imageNamed: @"alarmNoteIcon"]); }
+ (UIImage*)questionIcon { return _questionIcon ?: (_questionIcon = [UIImage imageNamed: @"questionIcon"]); }
+ (UIImage*)settingsIcon { return _settingsIcon ?: (_settingsIcon = [UIImage imageNamed: @"settingsIcon"]); }
+ (UIImage*)onboardingBackgroundImage1 { return _onboardingBackgroundImage1 ?: (_onboardingBackgroundImage1 = [UIImage imageNamed: @"onboardingBackgroundImage1"]); }
+ (UIImage*)onboardingBackgroundImage2 { return _onboardingBackgroundImage2 ?: (_onboardingBackgroundImage2 = [UIImage imageNamed: @"onboardingBackgroundImage2"]); }
+ (UIImage*)bluetoothLogoImage { return _bluetoothLogoImage ?: (_bluetoothLogoImage = [UIImage imageNamed: @"bluetoothLogoImage"]); }
+ (UIImage*)wifiLogoImage { return _wifiLogoImage ?: (_wifiLogoImage = [UIImage imageNamed: @"wifiLogoImage"]); }
+ (UIImage*)humidityIcon { return _humidityIcon ?: (_humidityIcon = [UIImage imageNamed: @"humidityIcon"]); }
+ (UIImage*)particleIcon { return _particleIcon ?: (_particleIcon = [UIImage imageNamed: @"particleIcon"]); }
+ (UIImage*)temperatureIcon { return _temperatureIcon ?: (_temperatureIcon = [UIImage imageNamed: @"temperatureIcon"]); }
+ (UIImage*)lightEventIcon { return _lightEventIcon ?: (_lightEventIcon = [UIImage imageNamed: @"lightEventIcon"]); }
+ (UIImage*)noiseEventIcon { return _noiseEventIcon ?: (_noiseEventIcon = [UIImage imageNamed: @"noiseEventIcon"]); }
+ (UIImage*)sleepEventIcon { return _sleepEventIcon ?: (_sleepEventIcon = [UIImage imageNamed: @"sleepEventIcon"]); }
+ (UIImage*)wakeupEventIcon { return _wakeupEventIcon ?: (_wakeupEventIcon = [UIImage imageNamed: @"wakeupEventIcon"]); }
+ (UIImage*)chevronIconRight { return _chevronIconRight ?: (_chevronIconRight = [UIImage imageNamed: @"chevronIconRight"]); }
+ (UIImage*)motionEventIcon { return _motionEventIcon ?: (_motionEventIcon = [UIImage imageNamed: @"motionEventIcon"]); }
+ (UIImage*)alarmsIcon { return _alarmsIcon ?: (_alarmsIcon = [UIImage imageNamed: @"alarmsIcon"]); }
+ (UIImage*)sleepInsightsIcon { return _sleepInsightsIcon ?: (_sleepInsightsIcon = [UIImage imageNamed: @"sleepInsightsIcon"]); }
+ (UIImage*)senseIcon { return _senseIcon ?: (_senseIcon = [UIImage imageNamed: @"senseIcon"]); }
+ (UIImage*)pillIcon { return _pillIcon ?: (_pillIcon = [UIImage imageNamed: @"pillIcon"]); }

#pragma mark Drawing Methods

+ (void)drawSleepScoreGraphWithSleepScoreLabelText: (NSString*)sleepScoreLabelText sleepScore: (CGFloat)sleepScore;
{
    //// General Declarations
    CGContextRef context = UIGraphicsGetCurrentContext();

    //// Color Declarations
    UIColor* color = [UIColor colorWithRed: 0.866 green: 0.866 blue: 0.866 alpha: 1];
    UIColor* color3 = [UIColor colorWithRed: 0.97 green: 0.97 blue: 0.97 alpha: 1];

    //// Variable Declarations
    UIColor* sleepScoreColor = sleepScore < 45 ? HelloStyleKit.warningSensorColor : (sleepScore < 80 ? HelloStyleKit.alertSensorColor : HelloStyleKit.idealSensorColor);
    CGFloat graphPercentageAngle = sleepScore > 0 ? (sleepScore < 100 ? 360 - sleepScore * 0.01 * 360 : 1) : 0;
    NSString* sleepScoreText = sleepScore > 0 ? (sleepScore <= 100 ? [NSString stringWithFormat: @"%ld", (NSInteger)round(sleepScore)] : @"100") : @"";

    //// gray oval Drawing
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 87.5, 87.5);
    CGContextRotateCTM(context, -90 * M_PI / 180);

    UIBezierPath* grayOvalPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(-87.5, -87.5, 175, 175)];
    [color setFill];
    [grayOvalPath fill];

    CGContextRestoreGState(context);


    //// pie oval Drawing
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 87.5, 87.5);
    CGContextRotateCTM(context, -90 * M_PI / 180);

    CGRect pieOvalRect = CGRectMake(-87.5, -87.5, 175, 175);
    UIBezierPath* pieOvalPath = UIBezierPath.bezierPath;
    [pieOvalPath addArcWithCenter: CGPointMake(CGRectGetMidX(pieOvalRect), CGRectGetMidY(pieOvalRect)) radius: CGRectGetWidth(pieOvalRect) / 2 startAngle: 0 * M_PI/180 endAngle: -graphPercentageAngle * M_PI/180 clockwise: YES];
    [pieOvalPath addLineToPoint: CGPointMake(CGRectGetMidX(pieOvalRect), CGRectGetMidY(pieOvalRect))];
    [pieOvalPath closePath];

    [sleepScoreColor setFill];
    [pieOvalPath fill];

    CGContextRestoreGState(context);


    //// white center oval Drawing
    UIBezierPath* whiteCenterOvalPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(2, 2, 171, 171)];
    [color3 setFill];
    [whiteCenterOvalPath fill];


    //// sleep score label Drawing
    CGRect sleepScoreLabelRect = CGRectMake(0, 2, 175, 159);
    NSMutableParagraphStyle* sleepScoreLabelStyle = NSMutableParagraphStyle.defaultParagraphStyle.mutableCopy;
    sleepScoreLabelStyle.alignment = NSTextAlignmentCenter;

    NSDictionary* sleepScoreLabelFontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"Helvetica" size: 96], NSForegroundColorAttributeName: UIColor.blackColor, NSParagraphStyleAttributeName: sleepScoreLabelStyle};

    [sleepScoreText drawInRect: CGRectOffset(sleepScoreLabelRect, 0, (CGRectGetHeight(sleepScoreLabelRect) - [sleepScoreText boundingRectWithSize: sleepScoreLabelRect.size options: NSStringDrawingUsesLineFragmentOrigin attributes: sleepScoreLabelFontAttributes context: nil].size.height) / 2) withAttributes: sleepScoreLabelFontAttributes];


    //// sleep score text label Drawing
    CGRect sleepScoreTextLabelRect = CGRectMake(56, 133, 64, 14);
    NSMutableParagraphStyle* sleepScoreTextLabelStyle = NSMutableParagraphStyle.defaultParagraphStyle.mutableCopy;
    sleepScoreTextLabelStyle.alignment = NSTextAlignmentCenter;

    NSDictionary* sleepScoreTextLabelFontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"Helvetica" size: 11], NSForegroundColorAttributeName: UIColor.grayColor, NSParagraphStyleAttributeName: sleepScoreTextLabelStyle};

    [sleepScoreLabelText drawInRect: CGRectOffset(sleepScoreTextLabelRect, 0, (CGRectGetHeight(sleepScoreTextLabelRect) - [sleepScoreLabelText boundingRectWithSize: sleepScoreTextLabelRect.size options: NSStringDrawingUsesLineFragmentOrigin attributes: sleepScoreTextLabelFontAttributes context: nil].size.height) / 2) withAttributes: sleepScoreTextLabelFontAttributes];
}

+ (void)drawMiniSleepScoreGraphWithSleepScore: (CGFloat)sleepScore;
{
    //// General Declarations
    CGContextRef context = UIGraphicsGetCurrentContext();

    //// Color Declarations
    UIColor* color = [UIColor colorWithRed: 0.866 green: 0.866 blue: 0.866 alpha: 1];

    //// Variable Declarations
    UIColor* sleepScoreColor = sleepScore < 45 ? HelloStyleKit.warningSensorColor : (sleepScore < 80 ? HelloStyleKit.alertSensorColor : HelloStyleKit.idealSensorColor);
    CGFloat graphPercentageAngle = sleepScore > 0 ? (sleepScore < 100 ? 360 - sleepScore * 0.01 * 360 : 1) : 0;
    NSString* sleepScoreText = sleepScore > 0 ? (sleepScore <= 100 ? [NSString stringWithFormat: @"%ld", (NSInteger)round(sleepScore)] : @"100") : @"";

    //// gray oval Drawing
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 15, 15);
    CGContextRotateCTM(context, -90 * M_PI / 180);

    UIBezierPath* grayOvalPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(-15, -15, 30, 30)];
    [color setFill];
    [grayOvalPath fill];

    CGContextRestoreGState(context);


    //// pie oval Drawing
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 15, 15);
    CGContextRotateCTM(context, -90 * M_PI / 180);

    CGRect pieOvalRect = CGRectMake(-15, -15, 30, 30);
    UIBezierPath* pieOvalPath = UIBezierPath.bezierPath;
    [pieOvalPath addArcWithCenter: CGPointMake(CGRectGetMidX(pieOvalRect), CGRectGetMidY(pieOvalRect)) radius: CGRectGetWidth(pieOvalRect) / 2 startAngle: 0 * M_PI/180 endAngle: -graphPercentageAngle * M_PI/180 clockwise: YES];
    [pieOvalPath addLineToPoint: CGPointMake(CGRectGetMidX(pieOvalRect), CGRectGetMidY(pieOvalRect))];
    [pieOvalPath closePath];

    [sleepScoreColor setFill];
    [pieOvalPath fill];

    CGContextRestoreGState(context);


    //// white center oval Drawing
    UIBezierPath* whiteCenterOvalPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(2, 2, 26, 26)];
    [UIColor.whiteColor setFill];
    [whiteCenterOvalPath fill];


    //// Text Drawing
    CGRect textRect = CGRectMake(7, 7, 17, 15);
    NSMutableParagraphStyle* textStyle = NSMutableParagraphStyle.defaultParagraphStyle.mutableCopy;
    textStyle.alignment = NSTextAlignmentCenter;

    NSDictionary* textFontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"HelveticaNeue-Light" size: UIFont.smallSystemFontSize], NSForegroundColorAttributeName: UIColor.blackColor, NSParagraphStyleAttributeName: textStyle};

    [sleepScoreText drawInRect: textRect withAttributes: textFontAttributes];
}

@end



@interface PCGradient ()
{
    CGGradientRef _CGGradient;
}
@end

@implementation PCGradient

- (instancetype)initWithColors: (NSArray*)colors locations: (const CGFloat*)locations
{
    self = super.init;
    if (self)
    {
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        NSMutableArray* cgColors = NSMutableArray.array;
        for (UIColor* color in colors)
            [cgColors addObject: (id)color.CGColor];

        _CGGradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)cgColors, locations);
        CGColorSpaceRelease(colorSpace);
    }
    return self;
}

+ (instancetype)gradientWithColors: (NSArray*)colors locations: (const CGFloat*)locations
{
    return [self.alloc initWithColors: colors locations: locations];
}

+ (instancetype)gradientWithStartingColor: (UIColor*)startingColor endingColor: (UIColor*)endingColor
{
    CGFloat locations[] = {0, 1};
    return [self.alloc initWithColors: @[startingColor, endingColor] locations: locations];
}

- (void)dealloc
{
    CGGradientRelease(_CGGradient);
}

@end
