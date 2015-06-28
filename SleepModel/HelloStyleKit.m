//
//  HelloStyleKit.m
//  Sense
//
//  Created by Delisa Mason on 6/28/15.
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
static UIColor* _textfieldTextColor = nil;
static UIColor* _unknownSensorColor = nil;
static UIColor* _actionButtonTextColor = nil;
static UIColor* _alarmSelectionRowColor = nil;
static UIColor* _pageControlTintColor = nil;
static UIColor* _actionButtonDisabledColor = nil;
static UIColor* _backViewCardShadowColor = nil;
static UIColor* _lightTintColor = nil;
static UIColor* _trendTextColor = nil;
static UIColor* _cardBorderColor = nil;
static UIColor* _trendGraphBottomColor = nil;
static UIColor* _trendGraphTopColor = nil;
static UIColor* _switchOffBackgroundColor = nil;
static UIColor* _buttonContainerShadowColor = nil;
static UIColor* _timelineGradientColor = nil;
static UIColor* _timelineGradientColor2 = nil;
static UIColor* _tutorialBackgroundColor = nil;
static UIColor* _handholdingGestureHintColor = nil;
static UIColor* _handholdingGestureHintBorderColor = nil;
static UIColor* _handholdingMessageBackgroundColor = nil;
static UIColor* _actionSheetSeparatorColor = nil;
static UIColor* _actionSheetSelectedColor = nil;
static UIColor* _timelineBarGradientColor = nil;
static UIColor* _timelineBarGradientColor2 = nil;
static UIColor* _timelineEventShadowColor = nil;

static PCGradient* _timelineGradient = nil;
static PCGradient* _timelineBarGradient = nil;

static NSShadow* _insightShadow = nil;
static NSShadow* _actionViewShadow = nil;
static NSShadow* _backViewCardShadow = nil;
static NSShadow* _buttonContainerShadow = nil;

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
static UIImage* _moon = nil;
static UIImage* _alarmBarIcon = nil;
static UIImage* _senseBarIcon = nil;
static UIImage* _settingsBarIcon = nil;
static UIImage* _trendsBarIcon = nil;
static UIImage* _sensorsBarIcon = nil;
static UIImage* _alarmSmartIcon = nil;
static UIImage* _alarmSoundIcon = nil;
static UIImage* _alarmRepeatIcon = nil;
static UIImage* _senseIcon = nil;
static UIImage* _pillIcon = nil;
static UIImage* _presleepInsightParticulates = nil;
static UIImage* _presleepInsightSound = nil;
static UIImage* _presleepInsightLight = nil;
static UIImage* _presleepInsightHumidity = nil;
static UIImage* _presleepInsightTemperature = nil;
static UIImage* _presleepInsightUnknown = nil;
static UIImage* _loading = nil;
static UIImage* _miniStopButton = nil;
static UIImage* _miniPlayButton = nil;
static UIImage* _infoButtonIcon = nil;
static UIImage* _lightEventIcon = nil;
static UIImage* _outOfBedEventIcon = nil;
static UIImage* _sunriseEventIcon = nil;
static UIImage* _sleepEventIcon = nil;
static UIImage* _noiseEventIcon = nil;
static UIImage* _inBedEventIcon = nil;
static UIImage* _alarmEventIcon = nil;
static UIImage* _partnerEventIcon = nil;
static UIImage* _unknownEventIcon = nil;
static UIImage* _lightsOutEventIcon = nil;
static UIImage* _motionEventIcon = nil;
static UIImage* _wakeupEventIcon = nil;
static UIImage* _sunsetEventIcon = nil;
static UIImage* _pillSetup = nil;

#pragma mark Initialization

+ (void)initialize
{
    // Colors Initialization
    _currentConditionsBackgroundColor = [UIColor colorWithRed: 0.902 green: 0.91 blue: 0.906 alpha: 1];
    _warningSensorColor = [UIColor colorWithRed: 0.996 green: 0.796 blue: 0.184 alpha: 1];
    _idealSensorColor = [UIColor colorWithRed: 0.188 green: 0.839 blue: 0.671 alpha: 1];
    _alertSensorColor = [UIColor colorWithRed: 0.992 green: 0.592 blue: 0.329 alpha: 1];
    _lightSleepColor = [UIColor colorWithRed: 0.647 green: 0.867 blue: 1 alpha: 1];
    _intermediateSleepColor = [UIColor colorWithRed: 0.447 green: 0.788 blue: 1 alpha: 1];
    _deepSleepColor = [UIColor colorWithRed: 0 green: 0.612 blue: 1 alpha: 1];
    _awakeSleepColor = [UIColor colorWithRed: 0.32 green: 0.356 blue: 0.8 alpha: 0];
    _sleepQuestionBgColor = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 0.9];
    _onboardingGrayColor = [UIColor colorWithRed: 0.286 green: 0.286 blue: 0.286 alpha: 1];
    _backViewBackgroundColor = [UIColor colorWithRed: 0.949 green: 0.949 blue: 0.949 alpha: 1];
    _backViewNavTitleColor = [UIColor colorWithRed: 0.286 green: 0.286 blue: 0.286 alpha: 1];
    _backViewTextColor = [UIColor colorWithRed: 0.3 green: 0.3 blue: 0.3 alpha: 1];
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
    _settingsValueTextColor = [UIColor colorWithRed: 0 green: 0 blue: 0 alpha: 0.4];
    _textfieldTextColor = [UIColor colorWithRed: 0 green: 0 blue: 0 alpha: 0.7];
    _unknownSensorColor = [UIColor colorWithRed: 0.787 green: 0.787 blue: 0.787 alpha: 1];
    _actionButtonTextColor = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 1];
    _alarmSelectionRowColor = [UIColor colorWithRed: 0.75 green: 0.75 blue: 0.75 alpha: 1];
    _pageControlTintColor = [UIColor colorWithRed: 0.922 green: 0.922 blue: 0.922 alpha: 1];
    _actionButtonDisabledColor = [UIColor colorWithRed: 0.788 green: 0.788 blue: 0.788 alpha: 1];
    _backViewCardShadowColor = [UIColor colorWithRed: 0 green: 0 blue: 0 alpha: 1];
    _lightTintColor = [UIColor colorWithRed: 0.298 green: 0.757 blue: 0.988 alpha: 1];
    _trendTextColor = [UIColor colorWithRed: 0.6 green: 0.6 blue: 0.6 alpha: 1];
    _cardBorderColor = [UIColor colorWithRed: 0.9 green: 0.9 blue: 0.9 alpha: 1];
    _trendGraphBottomColor = [UIColor colorWithRed: 0.95 green: 0.97 blue: 0.982 alpha: 1];
    _trendGraphTopColor = [UIColor colorWithRed: 0.913 green: 0.966 blue: 1 alpha: 1];
    _switchOffBackgroundColor = [UIColor colorWithRed: 0.95 green: 0.95 blue: 0.95 alpha: 1];
    _buttonContainerShadowColor = [UIColor colorWithRed: 0 green: 0 blue: 0 alpha: 0.1];
    _timelineGradientColor = [UIColor colorWithRed: 0.82 green: 0.929 blue: 1 alpha: 1];
    _timelineGradientColor2 = [UIColor colorWithRed: 0.886 green: 0.953 blue: 0.996 alpha: 1];
    _tutorialBackgroundColor = [UIColor colorWithRed: 0.239 green: 0.322 blue: 0.4 alpha: 0.6];
    _handholdingGestureHintColor = [UIColor colorWithRed: 0.004 green: 0.612 blue: 1 alpha: 0.3];
    _handholdingGestureHintBorderColor = [UIColor colorWithRed: 0.004 green: 0.612 blue: 1 alpha: 0.8];
    _handholdingMessageBackgroundColor = [UIColor colorWithRed: 0.004 green: 0.612 blue: 1 alpha: 1];
    _actionSheetSeparatorColor = [UIColor colorWithRed: 0.949 green: 0.949 blue: 0.949 alpha: 1];
    _actionSheetSelectedColor = [UIColor colorWithRed: 0.969 green: 0.969 blue: 0.969 alpha: 1];
    _timelineBarGradientColor = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 0.12];
    _timelineBarGradientColor2 = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 0];
    _timelineEventShadowColor = [UIColor colorWithRed: 0 green: 0.612 blue: 1 alpha: 1];

    // Gradients Initialization
    CGFloat timelineGradientLocations[] = {0, 1};
    _timelineGradient = [PCGradient gradientWithColors: @[HelloStyleKit.timelineGradientColor, HelloStyleKit.timelineGradientColor2] locations: timelineGradientLocations];
    CGFloat timelineBarGradientLocations[] = {0, 1};
    _timelineBarGradient = [PCGradient gradientWithColors: @[HelloStyleKit.timelineBarGradientColor, HelloStyleKit.timelineBarGradientColor2] locations: timelineBarGradientLocations];

    // Shadows Initialization
    _insightShadow = [NSShadow shadowWithColor: [UIColor.blackColor colorWithAlphaComponent: 0.1] offset: CGSizeMake(0.1, -2.1) blurRadius: 3];
    _actionViewShadow = [NSShadow shadowWithColor: [UIColor.blackColor colorWithAlphaComponent: 0.1] offset: CGSizeMake(0.1, -2.1) blurRadius: 5];
    _backViewCardShadow = [NSShadow shadowWithColor: [HelloStyleKit.backViewCardShadowColor colorWithAlphaComponent: 0.02] offset: CGSizeMake(0.1, 1.6) blurRadius: 0];
    _buttonContainerShadow = [NSShadow shadowWithColor: HelloStyleKit.buttonContainerShadowColor offset: CGSizeMake(0.1, 1.1) blurRadius: 3];

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
+ (UIColor*)textfieldTextColor { return _textfieldTextColor; }
+ (UIColor*)unknownSensorColor { return _unknownSensorColor; }
+ (UIColor*)actionButtonTextColor { return _actionButtonTextColor; }
+ (UIColor*)alarmSelectionRowColor { return _alarmSelectionRowColor; }
+ (UIColor*)pageControlTintColor { return _pageControlTintColor; }
+ (UIColor*)actionButtonDisabledColor { return _actionButtonDisabledColor; }
+ (UIColor*)backViewCardShadowColor { return _backViewCardShadowColor; }
+ (UIColor*)lightTintColor { return _lightTintColor; }
+ (UIColor*)trendTextColor { return _trendTextColor; }
+ (UIColor*)cardBorderColor { return _cardBorderColor; }
+ (UIColor*)trendGraphBottomColor { return _trendGraphBottomColor; }
+ (UIColor*)trendGraphTopColor { return _trendGraphTopColor; }
+ (UIColor*)switchOffBackgroundColor { return _switchOffBackgroundColor; }
+ (UIColor*)buttonContainerShadowColor { return _buttonContainerShadowColor; }
+ (UIColor*)timelineGradientColor { return _timelineGradientColor; }
+ (UIColor*)timelineGradientColor2 { return _timelineGradientColor2; }
+ (UIColor*)tutorialBackgroundColor { return _tutorialBackgroundColor; }
+ (UIColor*)handholdingGestureHintColor { return _handholdingGestureHintColor; }
+ (UIColor*)handholdingGestureHintBorderColor { return _handholdingGestureHintBorderColor; }
+ (UIColor*)handholdingMessageBackgroundColor { return _handholdingMessageBackgroundColor; }
+ (UIColor*)actionSheetSeparatorColor { return _actionSheetSeparatorColor; }
+ (UIColor*)actionSheetSelectedColor { return _actionSheetSelectedColor; }
+ (UIColor*)timelineBarGradientColor { return _timelineBarGradientColor; }
+ (UIColor*)timelineBarGradientColor2 { return _timelineBarGradientColor2; }
+ (UIColor*)timelineEventShadowColor { return _timelineEventShadowColor; }

#pragma mark Gradients

+ (PCGradient*)timelineGradient { return _timelineGradient; }
+ (PCGradient*)timelineBarGradient { return _timelineBarGradient; }

#pragma mark Shadows

+ (NSShadow*)insightShadow { return _insightShadow; }
+ (NSShadow*)actionViewShadow { return _actionViewShadow; }
+ (NSShadow*)backViewCardShadow { return _backViewCardShadow; }
+ (NSShadow*)buttonContainerShadow { return _buttonContainerShadow; }

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
+ (UIImage*)moon { return _moon ?: (_moon = [UIImage imageNamed: @"moon"]); }
+ (UIImage*)alarmBarIcon { return _alarmBarIcon ?: (_alarmBarIcon = [UIImage imageNamed: @"alarmBarIcon"]); }
+ (UIImage*)senseBarIcon { return _senseBarIcon ?: (_senseBarIcon = [UIImage imageNamed: @"senseBarIcon"]); }
+ (UIImage*)settingsBarIcon { return _settingsBarIcon ?: (_settingsBarIcon = [UIImage imageNamed: @"settingsBarIcon"]); }
+ (UIImage*)trendsBarIcon { return _trendsBarIcon ?: (_trendsBarIcon = [UIImage imageNamed: @"trendsBarIcon"]); }
+ (UIImage*)sensorsBarIcon { return _sensorsBarIcon ?: (_sensorsBarIcon = [UIImage imageNamed: @"sensorsBarIcon"]); }
+ (UIImage*)alarmSmartIcon { return _alarmSmartIcon ?: (_alarmSmartIcon = [UIImage imageNamed: @"alarmSmartIcon"]); }
+ (UIImage*)alarmSoundIcon { return _alarmSoundIcon ?: (_alarmSoundIcon = [UIImage imageNamed: @"alarmSoundIcon"]); }
+ (UIImage*)alarmRepeatIcon { return _alarmRepeatIcon ?: (_alarmRepeatIcon = [UIImage imageNamed: @"alarmRepeatIcon"]); }
+ (UIImage*)senseIcon { return _senseIcon ?: (_senseIcon = [UIImage imageNamed: @"senseIcon"]); }
+ (UIImage*)pillIcon { return _pillIcon ?: (_pillIcon = [UIImage imageNamed: @"pillIcon"]); }
+ (UIImage*)presleepInsightParticulates { return _presleepInsightParticulates ?: (_presleepInsightParticulates = [UIImage imageNamed: @"presleepInsightParticulates"]); }
+ (UIImage*)presleepInsightSound { return _presleepInsightSound ?: (_presleepInsightSound = [UIImage imageNamed: @"presleepInsightSound"]); }
+ (UIImage*)presleepInsightLight { return _presleepInsightLight ?: (_presleepInsightLight = [UIImage imageNamed: @"presleepInsightLight"]); }
+ (UIImage*)presleepInsightHumidity { return _presleepInsightHumidity ?: (_presleepInsightHumidity = [UIImage imageNamed: @"presleepInsightHumidity"]); }
+ (UIImage*)presleepInsightTemperature { return _presleepInsightTemperature ?: (_presleepInsightTemperature = [UIImage imageNamed: @"presleepInsightTemperature"]); }
+ (UIImage*)presleepInsightUnknown { return _presleepInsightUnknown ?: (_presleepInsightUnknown = [UIImage imageNamed: @"presleepInsightUnknown"]); }
+ (UIImage*)loading { return _loading ?: (_loading = [UIImage imageNamed: @"loading"]); }
+ (UIImage*)miniStopButton { return _miniStopButton ?: (_miniStopButton = [UIImage imageNamed: @"miniStopButton"]); }
+ (UIImage*)miniPlayButton { return _miniPlayButton ?: (_miniPlayButton = [UIImage imageNamed: @"miniPlayButton"]); }
+ (UIImage*)infoButtonIcon { return _infoButtonIcon ?: (_infoButtonIcon = [UIImage imageNamed: @"infoButtonIcon"]); }
+ (UIImage*)lightEventIcon { return _lightEventIcon ?: (_lightEventIcon = [UIImage imageNamed: @"lightEventIcon"]); }
+ (UIImage*)outOfBedEventIcon { return _outOfBedEventIcon ?: (_outOfBedEventIcon = [UIImage imageNamed: @"outOfBedEventIcon"]); }
+ (UIImage*)sunriseEventIcon { return _sunriseEventIcon ?: (_sunriseEventIcon = [UIImage imageNamed: @"sunriseEventIcon"]); }
+ (UIImage*)sleepEventIcon { return _sleepEventIcon ?: (_sleepEventIcon = [UIImage imageNamed: @"sleepEventIcon"]); }
+ (UIImage*)noiseEventIcon { return _noiseEventIcon ?: (_noiseEventIcon = [UIImage imageNamed: @"noiseEventIcon"]); }
+ (UIImage*)inBedEventIcon { return _inBedEventIcon ?: (_inBedEventIcon = [UIImage imageNamed: @"inBedEventIcon"]); }
+ (UIImage*)alarmEventIcon { return _alarmEventIcon ?: (_alarmEventIcon = [UIImage imageNamed: @"alarmEventIcon"]); }
+ (UIImage*)partnerEventIcon { return _partnerEventIcon ?: (_partnerEventIcon = [UIImage imageNamed: @"partnerEventIcon"]); }
+ (UIImage*)unknownEventIcon { return _unknownEventIcon ?: (_unknownEventIcon = [UIImage imageNamed: @"unknownEventIcon"]); }
+ (UIImage*)lightsOutEventIcon { return _lightsOutEventIcon ?: (_lightsOutEventIcon = [UIImage imageNamed: @"lightsOutEventIcon"]); }
+ (UIImage*)motionEventIcon { return _motionEventIcon ?: (_motionEventIcon = [UIImage imageNamed: @"motionEventIcon"]); }
+ (UIImage*)wakeupEventIcon { return _wakeupEventIcon ?: (_wakeupEventIcon = [UIImage imageNamed: @"wakeupEventIcon"]); }
+ (UIImage*)sunsetEventIcon { return _sunsetEventIcon ?: (_sunsetEventIcon = [UIImage imageNamed: @"sunsetEventIcon"]); }
+ (UIImage*)pillSetup { return _pillSetup ?: (_pillSetup = [UIImage imageNamed: @"pillSetup"]); }

#pragma mark Drawing Methods

+ (void)drawSleepScoreGraphWithSleepScore: (CGFloat)sleepScore
{
    //// General Declarations
    CGContextRef context = UIGraphicsGetCurrentContext();

    //// Color Declarations
    UIColor* sleepScoreNoValueColor = [UIColor colorWithRed: 0 green: 0 blue: 0 alpha: 0.059];
    UIColor* sleepScoreOvalColor = [UIColor colorWithRed: 0.898 green: 0.898 blue: 0.898 alpha: 1];

    //// Variable Declarations
    UIColor* sleepScoreColor = sleepScore > 0 ? (sleepScore < 45 ? HelloStyleKit.alertSensorColor : (sleepScore < 80 ? HelloStyleKit.warningSensorColor : HelloStyleKit.idealSensorColor)) : sleepScoreNoValueColor;
    CGFloat graphPercentageAngle = MAX(MIN(sleepScore > 0 ? (sleepScore < 100 ? 400 - sleepScore * 0.01 * 300 : 0.01) : 0.01, 359), 102);
    NSString* sleepScoreText = sleepScore > 0 ? (sleepScore <= 100 ? [NSString stringWithFormat: @"%ld", (long)round(sleepScore)] : @"100") : @"";

    //// background oval Drawing
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 1, 3);
    CGContextRotateCTM(context, -90 * M_PI / 180);

    CGRect backgroundOvalRect = CGRectMake(-155, 0, 155, 155);
    UIBezierPath* backgroundOvalPath = UIBezierPath.bezierPath;
    [backgroundOvalPath addArcWithCenter: CGPointMake(CGRectGetMidX(backgroundOvalRect), CGRectGetMidY(backgroundOvalRect)) radius: CGRectGetWidth(backgroundOvalRect) / 2 startAngle: -129 * M_PI/180 endAngle: 129 * M_PI/180 clockwise: YES];

    [sleepScoreOvalColor setStroke];
    backgroundOvalPath.lineWidth = 1;
    [backgroundOvalPath stroke];

    CGContextRestoreGState(context);


    //// pie oval Drawing
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 67, 190);
    CGContextRotateCTM(context, 141 * M_PI / 180);

    CGRect pieOvalRect = CGRectMake(-155, 0, 155, 155);
    UIBezierPath* pieOvalPath = UIBezierPath.bezierPath;
    [pieOvalPath addArcWithCenter: CGPointMake(CGRectGetMidX(pieOvalRect), CGRectGetMidY(pieOvalRect)) radius: CGRectGetWidth(pieOvalRect) / 2 startAngle: 0 * M_PI/180 endAngle: -graphPercentageAngle * M_PI/180 clockwise: YES];

    [sleepScoreColor setStroke];
    pieOvalPath.lineWidth = 1;
    [pieOvalPath stroke];

    CGContextRestoreGState(context);


    //// sleep score label Drawing
    CGRect sleepScoreLabelRect = CGRectMake(0, 47.67, 157, 67.53);
    NSMutableParagraphStyle* sleepScoreLabelStyle = NSMutableParagraphStyle.defaultParagraphStyle.mutableCopy;
    sleepScoreLabelStyle.alignment = NSTextAlignmentCenter;

    NSDictionary* sleepScoreLabelFontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"AvenirNext-UltraLight" size: 64], NSForegroundColorAttributeName: sleepScoreColor, NSParagraphStyleAttributeName: sleepScoreLabelStyle};

    CGFloat sleepScoreLabelTextHeight = [sleepScoreText boundingRectWithSize: CGSizeMake(sleepScoreLabelRect.size.width, INFINITY)  options: NSStringDrawingUsesLineFragmentOrigin attributes: sleepScoreLabelFontAttributes context: nil].size.height;
    CGContextSaveGState(context);
    CGContextClipToRect(context, sleepScoreLabelRect);
    [sleepScoreText drawInRect: CGRectMake(CGRectGetMinX(sleepScoreLabelRect), CGRectGetMinY(sleepScoreLabelRect) + (CGRectGetHeight(sleepScoreLabelRect) - sleepScoreLabelTextHeight) / 2, CGRectGetWidth(sleepScoreLabelRect), sleepScoreLabelTextHeight) withAttributes: sleepScoreLabelFontAttributes];
    CGContextRestoreGState(context);
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
