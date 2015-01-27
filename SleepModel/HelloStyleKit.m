//
//  HelloStyleKit.m
//  Sleep Sense
//
//  Created by Delisa Mason on 1/26/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//
//  Generated by PaintCode (www.paintcodeapp.com)
//

#import "HelloStyleKit.h"


@implementation HelloStyleKit

#pragma mark Cache

static UIColor* _currentConditionsBackgroundColor = nil;
static UIColor* _warningSensorColor = nil;
static UIColor* _idealSensorColor = nil;
static UIColor* _alertSensorColor = nil;
static UIColor* _lightSleepColor = nil;
static UIColor* _intermediateSleepColor = nil;
static UIColor* _deepSleepColor = nil;
static UIColor* _awakeSleepColor = nil;
static UIColor* _sleepQuestionBgColor = nil;
static UIColor* _onboardingGrayColor = nil;
static UIColor* _backViewBackgroundColor = nil;
static UIColor* _backViewNavTitleColor = nil;
static UIColor* _backViewTextColor = nil;
static UIColor* _senseBlueColor = nil;
static UIColor* _backViewTintColor = nil;
static UIColor* _timelineSectionBorderColor = nil;
static UIColor* _timelineGradientDarkColor = nil;
static UIColor* _backViewDetailTextColor = nil;
static UIColor* _tintColor = nil;
static UIColor* _barButtonDisabledColor = nil;
static UIColor* _actionViewTitleTextColor = nil;
static UIColor* _actionViewCancelButtonTextColor = nil;
static UIColor* _buttonDividerColor = nil;
static UIColor* _questionAnswerSelectedBgColor = nil;
static UIColor* _questionAnswerSelectedTextColor = nil;
static UIColor* _tabBarUnselectedColor = nil;
static UIColor* _deviceAlertMessageColor = nil;
static UIColor* _timelineLineColor = nil;
static UIColor* _timelineInsightTintColor = nil;
static UIColor* _separatorColor = nil;
static UIColor* _onboardingDescriptionColor = nil;
static UIColor* _onboardingTitleColor = nil;
static UIColor* _textfieldPlaceholderFocusedColor = nil;
static UIColor* _textfieldPlaceholderColor = nil;
static UIColor* _rulerSegmentDarkColor = nil;
static UIColor* _rulerSegmentLightColor = nil;
static UIColor* _settingsValueTextColor = nil;

static NSShadow* _onboardingButtonContainerShadow = nil;
static NSShadow* _actionViewShadow = nil;

static UIImage* _humidityIcon = nil;
static UIImage* _particleIcon = nil;
static UIImage* _temperatureIcon = nil;
static UIImage* _sense = nil;
static UIImage* _wifiIcon = nil;
static UIImage* _lockIcon = nil;
static UIImage* _backIcon = nil;
static UIImage* _sensePlacement = nil;
static UIImage* _shakePill = nil;
static UIImage* _smartAlarm = nil;
static UIImage* _check = nil;
static UIImage* _sensorHumidity = nil;
static UIImage* _sensorHumidityBlue = nil;
static UIImage* _sensorLight = nil;
static UIImage* _sensorLightBlue = nil;
static UIImage* _sensorParticulates = nil;
static UIImage* _sensorParticulatesBlue = nil;
static UIImage* _sensorSound = nil;
static UIImage* _sensorSoundBlue = nil;
static UIImage* _sensorTemperatureBlue = nil;
static UIImage* _sensorTemperature = nil;
static UIImage* _moon = nil;
static UIImage* _alarmBarIcon = nil;
static UIImage* _senseBarIcon = nil;
static UIImage* _settingsBarIcon = nil;
static UIImage* _trendsBarIcon = nil;
static UIImage* _sensorsBarIcon = nil;
static UIImage* _alarmSmartIcon = nil;
static UIImage* _alarmSoundIcon = nil;
static UIImage* _alarmRepeatIcon = nil;
static UIImage* _noiseEventIcon = nil;
static UIImage* _lightEventIcon = nil;
static UIImage* _partnerEventIcon = nil;
static UIImage* _sunriseEventIcon = nil;
static UIImage* _sunsetEventIcon = nil;
static UIImage* _motionEventIcon = nil;
static UIImage* _wakeupEventIcon = nil;
static UIImage* _alarmEventIcon = nil;
static UIImage* _sleepEventIcon = nil;
static UIImage* _unknownEventIcon = nil;
static UIImage* _senseIcon = nil;
static UIImage* _pillIcon = nil;
static UIImage* _lightsOutEventIcon = nil;
static UIImage* _outOfBedEventIcon = nil;
static UIImage* _inBedEventIcon = nil;
static UIImage* _presleepInsightParticulates = nil;
static UIImage* _presleepInsightSound = nil;
static UIImage* _presleepInsightLight = nil;
static UIImage* _presleepInsightHumidity = nil;
static UIImage* _presleepInsightTemperature = nil;
static UIImage* _presleepInsightUnknown = nil;

#pragma mark Initialization

+ (void)initialize
{
    // Colors Initialization
    _currentConditionsBackgroundColor = [UIColor colorWithRed: 0.902 green: 0.91 blue: 0.906 alpha: 1];
    _warningSensorColor = [UIColor colorWithRed: 0.996 green: 0.796 blue: 0.184 alpha: 1];
    _idealSensorColor = [UIColor colorWithRed: 0.188 green: 0.839 blue: 0.671 alpha: 1];
    _alertSensorColor = [UIColor colorWithRed: 0.992 green: 0.592 blue: 0.329 alpha: 1];
    _lightSleepColor = [UIColor colorWithRed: 0.8 green: 0.925 blue: 1 alpha: 1];
    _intermediateSleepColor = [UIColor colorWithRed: 0.65 green: 0.866 blue: 1 alpha: 1];
    _deepSleepColor = [UIColor colorWithRed: 0.5 green: 0.809 blue: 1 alpha: 1];
    _awakeSleepColor = [UIColor colorWithRed: 0.32 green: 0.356 blue: 0.8 alpha: 0];
    _sleepQuestionBgColor = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 0.9];
    _onboardingGrayColor = [UIColor colorWithRed: 0.286 green: 0.286 blue: 0.286 alpha: 1];
    _backViewBackgroundColor = [UIColor colorWithRed: 0.96 green: 0.96 blue: 0.96 alpha: 1];
    _backViewNavTitleColor = [UIColor colorWithRed: 0.286 green: 0.286 blue: 0.286 alpha: 1];
    _backViewTextColor = [UIColor colorWithRed: 0.478 green: 0.478 blue: 0.478 alpha: 1];
    _senseBlueColor = [UIColor colorWithRed: 0 green: 0.604 blue: 1 alpha: 1];
    _backViewTintColor = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 1];
    _timelineSectionBorderColor = [UIColor colorWithRed: 0.9 green: 0.91 blue: 0.91 alpha: 1];
    _timelineGradientDarkColor = [UIColor colorWithRed: 0.976 green: 0.976 blue: 0.976 alpha: 1];
    _backViewDetailTextColor = [UIColor colorWithRed: 0.631 green: 0.631 blue: 0.631 alpha: 1];
    _tintColor = [UIColor colorWithRed: 0 green: 0.612 blue: 1 alpha: 1];
    _barButtonDisabledColor = [UIColor colorWithRed: 0.6 green: 0.6 blue: 0.6 alpha: 1];
    _actionViewTitleTextColor = [UIColor colorWithRed: 0.6 green: 0.6 blue: 0.6 alpha: 1];
    _actionViewCancelButtonTextColor = [UIColor colorWithRed: 0.6 green: 0.6 blue: 0.6 alpha: 1];
    _buttonDividerColor = [UIColor colorWithRed: 0.6 green: 0.6 blue: 0.6 alpha: 0.2];
    _questionAnswerSelectedBgColor = [UIColor colorWithRed: 0.961 green: 0.984 blue: 1 alpha: 1];
    _questionAnswerSelectedTextColor = [UIColor colorWithRed: 0.804 green: 0.91 blue: 1 alpha: 1];
    _tabBarUnselectedColor = [UIColor colorWithRed: 0.75 green: 0.75 blue: 0.75 alpha: 1];
    _deviceAlertMessageColor = [UIColor colorWithRed: 0.302 green: 0.302 blue: 0.302 alpha: 1];
    _timelineLineColor = [UIColor colorWithRed: 0 green: 0.617 blue: 1 alpha: 0.25];
    _timelineInsightTintColor = [UIColor colorWithRed: 0.75 green: 0.75 blue: 0.75 alpha: 1];
    _separatorColor = [UIColor colorWithRed: 0 green: 0 blue: 0 alpha: 0.039];
    _onboardingDescriptionColor = [UIColor colorWithRed: 0 green: 0 blue: 0 alpha: 0.4];
    _onboardingTitleColor = [UIColor colorWithRed: 0 green: 0 blue: 0 alpha: 1];
    _textfieldPlaceholderFocusedColor = [UIColor colorWithRed: 0 green: 0 blue: 0 alpha: 0.25];
    _textfieldPlaceholderColor = [UIColor colorWithRed: 0 green: 0 blue: 0 alpha: 0.4];
    _rulerSegmentDarkColor = [UIColor colorWithRed: 0 green: 0 blue: 0 alpha: 0.2];
    _rulerSegmentLightColor = [UIColor colorWithRed: 0 green: 0 blue: 0 alpha: 0.1];
    _settingsValueTextColor = [UIColor colorWithRed: 0 green: 0 blue: 0 alpha: 0.2];

    // Shadows Initialization
    _onboardingButtonContainerShadow = [NSShadow shadowWithColor: [UIColor.blackColor colorWithAlphaComponent: 0.1] offset: CGSizeMake(0.1, -2.1) blurRadius: 5];
    _actionViewShadow = [NSShadow shadowWithColor: [UIColor.blackColor colorWithAlphaComponent: 0.1] offset: CGSizeMake(0.1, -2.1) blurRadius: 5];

}

#pragma mark Colors

+ (UIColor*)currentConditionsBackgroundColor { return _currentConditionsBackgroundColor; }
+ (UIColor*)warningSensorColor { return _warningSensorColor; }
+ (UIColor*)idealSensorColor { return _idealSensorColor; }
+ (UIColor*)alertSensorColor { return _alertSensorColor; }
+ (UIColor*)lightSleepColor { return _lightSleepColor; }
+ (UIColor*)intermediateSleepColor { return _intermediateSleepColor; }
+ (UIColor*)deepSleepColor { return _deepSleepColor; }
+ (UIColor*)awakeSleepColor { return _awakeSleepColor; }
+ (UIColor*)sleepQuestionBgColor { return _sleepQuestionBgColor; }
+ (UIColor*)onboardingGrayColor { return _onboardingGrayColor; }
+ (UIColor*)backViewBackgroundColor { return _backViewBackgroundColor; }
+ (UIColor*)backViewNavTitleColor { return _backViewNavTitleColor; }
+ (UIColor*)backViewTextColor { return _backViewTextColor; }
+ (UIColor*)senseBlueColor { return _senseBlueColor; }
+ (UIColor*)backViewTintColor { return _backViewTintColor; }
+ (UIColor*)timelineSectionBorderColor { return _timelineSectionBorderColor; }
+ (UIColor*)timelineGradientDarkColor { return _timelineGradientDarkColor; }
+ (UIColor*)backViewDetailTextColor { return _backViewDetailTextColor; }
+ (UIColor*)tintColor { return _tintColor; }
+ (UIColor*)barButtonDisabledColor { return _barButtonDisabledColor; }
+ (UIColor*)actionViewTitleTextColor { return _actionViewTitleTextColor; }
+ (UIColor*)actionViewCancelButtonTextColor { return _actionViewCancelButtonTextColor; }
+ (UIColor*)buttonDividerColor { return _buttonDividerColor; }
+ (UIColor*)questionAnswerSelectedBgColor { return _questionAnswerSelectedBgColor; }
+ (UIColor*)questionAnswerSelectedTextColor { return _questionAnswerSelectedTextColor; }
+ (UIColor*)tabBarUnselectedColor { return _tabBarUnselectedColor; }
+ (UIColor*)deviceAlertMessageColor { return _deviceAlertMessageColor; }
+ (UIColor*)timelineLineColor { return _timelineLineColor; }
+ (UIColor*)timelineInsightTintColor { return _timelineInsightTintColor; }
+ (UIColor*)separatorColor { return _separatorColor; }
+ (UIColor*)onboardingDescriptionColor { return _onboardingDescriptionColor; }
+ (UIColor*)onboardingTitleColor { return _onboardingTitleColor; }
+ (UIColor*)textfieldPlaceholderFocusedColor { return _textfieldPlaceholderFocusedColor; }
+ (UIColor*)textfieldPlaceholderColor { return _textfieldPlaceholderColor; }
+ (UIColor*)rulerSegmentDarkColor { return _rulerSegmentDarkColor; }
+ (UIColor*)rulerSegmentLightColor { return _rulerSegmentLightColor; }
+ (UIColor*)settingsValueTextColor { return _settingsValueTextColor; }

#pragma mark Shadows

+ (NSShadow*)onboardingButtonContainerShadow { return _onboardingButtonContainerShadow; }
+ (NSShadow*)actionViewShadow { return _actionViewShadow; }

#pragma mark Images

+ (UIImage*)humidityIcon { return _humidityIcon ?: (_humidityIcon = [UIImage imageNamed: @"humidityIcon"]); }
+ (UIImage*)particleIcon { return _particleIcon ?: (_particleIcon = [UIImage imageNamed: @"particleIcon"]); }
+ (UIImage*)temperatureIcon { return _temperatureIcon ?: (_temperatureIcon = [UIImage imageNamed: @"temperatureIcon"]); }
+ (UIImage*)sense { return _sense ?: (_sense = [UIImage imageNamed: @"sense"]); }
+ (UIImage*)wifiIcon { return _wifiIcon ?: (_wifiIcon = [UIImage imageNamed: @"wifiIcon"]); }
+ (UIImage*)lockIcon { return _lockIcon ?: (_lockIcon = [UIImage imageNamed: @"lockIcon"]); }
+ (UIImage*)backIcon { return _backIcon ?: (_backIcon = [UIImage imageNamed: @"backIcon"]); }
+ (UIImage*)sensePlacement { return _sensePlacement ?: (_sensePlacement = [UIImage imageNamed: @"sensePlacement"]); }
+ (UIImage*)shakePill { return _shakePill ?: (_shakePill = [UIImage imageNamed: @"shakePill"]); }
+ (UIImage*)smartAlarm { return _smartAlarm ?: (_smartAlarm = [UIImage imageNamed: @"smartAlarm"]); }
+ (UIImage*)check { return _check ?: (_check = [UIImage imageNamed: @"check"]); }
+ (UIImage*)sensorHumidity { return _sensorHumidity ?: (_sensorHumidity = [UIImage imageNamed: @"sensorHumidity"]); }
+ (UIImage*)sensorHumidityBlue { return _sensorHumidityBlue ?: (_sensorHumidityBlue = [UIImage imageNamed: @"sensorHumidityBlue"]); }
+ (UIImage*)sensorLight { return _sensorLight ?: (_sensorLight = [UIImage imageNamed: @"sensorLight"]); }
+ (UIImage*)sensorLightBlue { return _sensorLightBlue ?: (_sensorLightBlue = [UIImage imageNamed: @"sensorLightBlue"]); }
+ (UIImage*)sensorParticulates { return _sensorParticulates ?: (_sensorParticulates = [UIImage imageNamed: @"sensorParticulates"]); }
+ (UIImage*)sensorParticulatesBlue { return _sensorParticulatesBlue ?: (_sensorParticulatesBlue = [UIImage imageNamed: @"sensorParticulatesBlue"]); }
+ (UIImage*)sensorSound { return _sensorSound ?: (_sensorSound = [UIImage imageNamed: @"sensorSound"]); }
+ (UIImage*)sensorSoundBlue { return _sensorSoundBlue ?: (_sensorSoundBlue = [UIImage imageNamed: @"sensorSoundBlue"]); }
+ (UIImage*)sensorTemperatureBlue { return _sensorTemperatureBlue ?: (_sensorTemperatureBlue = [UIImage imageNamed: @"sensorTemperatureBlue"]); }
+ (UIImage*)sensorTemperature { return _sensorTemperature ?: (_sensorTemperature = [UIImage imageNamed: @"sensorTemperature"]); }
+ (UIImage*)moon { return _moon ?: (_moon = [UIImage imageNamed: @"moon"]); }
+ (UIImage*)alarmBarIcon { return _alarmBarIcon ?: (_alarmBarIcon = [UIImage imageNamed: @"alarmBarIcon"]); }
+ (UIImage*)senseBarIcon { return _senseBarIcon ?: (_senseBarIcon = [UIImage imageNamed: @"senseBarIcon"]); }
+ (UIImage*)settingsBarIcon { return _settingsBarIcon ?: (_settingsBarIcon = [UIImage imageNamed: @"settingsBarIcon"]); }
+ (UIImage*)trendsBarIcon { return _trendsBarIcon ?: (_trendsBarIcon = [UIImage imageNamed: @"trendsBarIcon"]); }
+ (UIImage*)sensorsBarIcon { return _sensorsBarIcon ?: (_sensorsBarIcon = [UIImage imageNamed: @"sensorsBarIcon"]); }
+ (UIImage*)alarmSmartIcon { return _alarmSmartIcon ?: (_alarmSmartIcon = [UIImage imageNamed: @"alarmSmartIcon"]); }
+ (UIImage*)alarmSoundIcon { return _alarmSoundIcon ?: (_alarmSoundIcon = [UIImage imageNamed: @"alarmSoundIcon"]); }
+ (UIImage*)alarmRepeatIcon { return _alarmRepeatIcon ?: (_alarmRepeatIcon = [UIImage imageNamed: @"alarmRepeatIcon"]); }
+ (UIImage*)noiseEventIcon { return _noiseEventIcon ?: (_noiseEventIcon = [UIImage imageNamed: @"noiseEventIcon"]); }
+ (UIImage*)lightEventIcon { return _lightEventIcon ?: (_lightEventIcon = [UIImage imageNamed: @"lightEventIcon"]); }
+ (UIImage*)partnerEventIcon { return _partnerEventIcon ?: (_partnerEventIcon = [UIImage imageNamed: @"partnerEventIcon"]); }
+ (UIImage*)sunriseEventIcon { return _sunriseEventIcon ?: (_sunriseEventIcon = [UIImage imageNamed: @"sunriseEventIcon"]); }
+ (UIImage*)sunsetEventIcon { return _sunsetEventIcon ?: (_sunsetEventIcon = [UIImage imageNamed: @"sunsetEventIcon"]); }
+ (UIImage*)motionEventIcon { return _motionEventIcon ?: (_motionEventIcon = [UIImage imageNamed: @"motionEventIcon"]); }
+ (UIImage*)wakeupEventIcon { return _wakeupEventIcon ?: (_wakeupEventIcon = [UIImage imageNamed: @"wakeupEventIcon"]); }
+ (UIImage*)alarmEventIcon { return _alarmEventIcon ?: (_alarmEventIcon = [UIImage imageNamed: @"alarmEventIcon"]); }
+ (UIImage*)sleepEventIcon { return _sleepEventIcon ?: (_sleepEventIcon = [UIImage imageNamed: @"sleepEventIcon"]); }
+ (UIImage*)unknownEventIcon { return _unknownEventIcon ?: (_unknownEventIcon = [UIImage imageNamed: @"unknownEventIcon"]); }
+ (UIImage*)senseIcon { return _senseIcon ?: (_senseIcon = [UIImage imageNamed: @"senseIcon"]); }
+ (UIImage*)pillIcon { return _pillIcon ?: (_pillIcon = [UIImage imageNamed: @"pillIcon"]); }
+ (UIImage*)lightsOutEventIcon { return _lightsOutEventIcon ?: (_lightsOutEventIcon = [UIImage imageNamed: @"lightsOutEventIcon"]); }
+ (UIImage*)outOfBedEventIcon { return _outOfBedEventIcon ?: (_outOfBedEventIcon = [UIImage imageNamed: @"outOfBedEventIcon"]); }
+ (UIImage*)inBedEventIcon { return _inBedEventIcon ?: (_inBedEventIcon = [UIImage imageNamed: @"inBedEventIcon"]); }
+ (UIImage*)presleepInsightParticulates { return _presleepInsightParticulates ?: (_presleepInsightParticulates = [UIImage imageNamed: @"presleepInsightParticulates"]); }
+ (UIImage*)presleepInsightSound { return _presleepInsightSound ?: (_presleepInsightSound = [UIImage imageNamed: @"presleepInsightSound"]); }
+ (UIImage*)presleepInsightLight { return _presleepInsightLight ?: (_presleepInsightLight = [UIImage imageNamed: @"presleepInsightLight"]); }
+ (UIImage*)presleepInsightHumidity { return _presleepInsightHumidity ?: (_presleepInsightHumidity = [UIImage imageNamed: @"presleepInsightHumidity"]); }
+ (UIImage*)presleepInsightTemperature { return _presleepInsightTemperature ?: (_presleepInsightTemperature = [UIImage imageNamed: @"presleepInsightTemperature"]); }
+ (UIImage*)presleepInsightUnknown { return _presleepInsightUnknown ?: (_presleepInsightUnknown = [UIImage imageNamed: @"presleepInsightUnknown"]); }

#pragma mark Drawing Methods

+ (void)drawSleepScoreGraphWithSleepScore: (CGFloat)sleepScore
{
    //// General Declarations
    CGContextRef context = UIGraphicsGetCurrentContext();

    //// Color Declarations
    UIColor* highSleepScoreColor = [UIColor colorWithRed: 0.252 green: 0.84 blue: 0.664 alpha: 1];
    UIColor* sleepScoreNoValueColor = [UIColor colorWithRed: 0 green: 0 blue: 0 alpha: 0.059];
    UIColor* sleepScoreOvalColor = [UIColor colorWithRed: 0.898 green: 0.898 blue: 0.898 alpha: 1];

    //// Variable Declarations
    UIColor* sleepScoreColor = sleepScore > 0 ? (sleepScore < 45 ? HelloStyleKit.alertSensorColor : (sleepScore < 80 ? HelloStyleKit.warningSensorColor : highSleepScoreColor)) : sleepScoreNoValueColor;
    CGFloat graphPercentageAngle = sleepScore > 0 ? (sleepScore < 100 ? 360 - sleepScore * 0.01 * 360 : 0.01) : 0.01;
    NSString* sleepScoreText = sleepScore > 0 ? (sleepScore <= 100 ? [NSString stringWithFormat: @"%ld", (NSInteger)round(sleepScore)] : @"100") : @"";

    //// background oval Drawing
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 1, 1);
    CGContextRotateCTM(context, -90 * M_PI / 180);

    UIBezierPath* backgroundOvalPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(-144, 0, 144, 144)];
    [sleepScoreOvalColor setStroke];
    backgroundOvalPath.lineWidth = 1;
    [backgroundOvalPath stroke];

    CGContextRestoreGState(context);


    //// pie oval Drawing
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 1, 1);
    CGContextRotateCTM(context, -90 * M_PI / 180);

    CGRect pieOvalRect = CGRectMake(-144, 0, 144, 144);
    UIBezierPath* pieOvalPath = UIBezierPath.bezierPath;
    [pieOvalPath addArcWithCenter: CGPointMake(CGRectGetMidX(pieOvalRect), CGRectGetMidY(pieOvalRect)) radius: CGRectGetWidth(pieOvalRect) / 2 startAngle: 0 * M_PI/180 endAngle: -graphPercentageAngle * M_PI/180 clockwise: YES];

    [sleepScoreColor setStroke];
    pieOvalPath.lineWidth = 1;
    [pieOvalPath stroke];

    CGContextRestoreGState(context);


    //// sleep score label Drawing
    CGRect sleepScoreLabelRect = CGRectMake(0, 38, 146, 98);
    NSMutableParagraphStyle* sleepScoreLabelStyle = NSMutableParagraphStyle.defaultParagraphStyle.mutableCopy;
    sleepScoreLabelStyle.alignment = NSTextAlignmentCenter;

    NSDictionary* sleepScoreLabelFontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"AvenirNext-UltraLight" size: 68], NSForegroundColorAttributeName: sleepScoreColor, NSParagraphStyleAttributeName: sleepScoreLabelStyle};

    CGFloat sleepScoreLabelTextHeight = [sleepScoreText boundingRectWithSize: CGSizeMake(sleepScoreLabelRect.size.width, INFINITY)  options: NSStringDrawingUsesLineFragmentOrigin attributes: sleepScoreLabelFontAttributes context: nil].size.height;
    CGContextSaveGState(context);
    CGContextClipToRect(context, sleepScoreLabelRect);
    [sleepScoreText drawInRect: CGRectMake(CGRectGetMinX(sleepScoreLabelRect), CGRectGetMinY(sleepScoreLabelRect) + (CGRectGetHeight(sleepScoreLabelRect) - sleepScoreLabelTextHeight) / 2, CGRectGetWidth(sleepScoreLabelRect), sleepScoreLabelTextHeight) withAttributes: sleepScoreLabelFontAttributes];
    CGContextRestoreGState(context);
}

@end



@implementation NSShadow (PaintCodeAdditions)

- (instancetype)initWithColor: (UIColor*)color offset: (CGSize)offset blurRadius: (CGFloat)blurRadius
{
    self = super.init;
    if (self)
    {
        self.shadowColor = color;
        self.shadowOffset = offset;
        self.shadowBlurRadius = blurRadius;
    }
    return self;
}

+ (instancetype)shadowWithColor: (UIColor*)color offset: (CGSize)offset blurRadius: (CGFloat)blurRadius
{
    return [self.alloc initWithColor: color offset: offset blurRadius: blurRadius];
}

- (void)set
{
    CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), self.shadowOffset, self.shadowBlurRadius, [self.shadowColor CGColor]);
}

@end
