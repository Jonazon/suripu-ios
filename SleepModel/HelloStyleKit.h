//
//  HelloStyleKit.h
//  Sleep Sense
//
//  Created by Delisa Mason on 4/3/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//
//  Generated by PaintCode (www.paintcodeapp.com)
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>



@interface HelloStyleKit : NSObject

// Colors
+ (UIColor*)currentConditionsBackgroundColor;
+ (UIColor*)warningSensorColor;
+ (UIColor*)idealSensorColor;
+ (UIColor*)alertSensorColor;
+ (UIColor*)lightSleepColor;
+ (UIColor*)intermediateSleepColor;
+ (UIColor*)deepSleepColor;
+ (UIColor*)awakeSleepColor;
+ (UIColor*)sleepQuestionBgColor;
+ (UIColor*)onboardingGrayColor;
+ (UIColor*)backViewBackgroundColor;
+ (UIColor*)backViewNavTitleColor;
+ (UIColor*)backViewTextColor;
+ (UIColor*)senseBlueColor;
+ (UIColor*)backViewTintColor;
+ (UIColor*)timelineSectionBorderColor;
+ (UIColor*)timelineGradientDarkColor;
+ (UIColor*)backViewDetailTextColor;
+ (UIColor*)tintColor;
+ (UIColor*)barButtonDisabledColor;
+ (UIColor*)actionViewTitleTextColor;
+ (UIColor*)actionViewCancelButtonTextColor;
+ (UIColor*)buttonDividerColor;
+ (UIColor*)questionAnswerSelectedBgColor;
+ (UIColor*)questionAnswerSelectedTextColor;
+ (UIColor*)tabBarUnselectedColor;
+ (UIColor*)deviceAlertMessageColor;
+ (UIColor*)timelineLineColor;
+ (UIColor*)timelineInsightTintColor;
+ (UIColor*)separatorColor;
+ (UIColor*)onboardingDescriptionColor;
+ (UIColor*)onboardingTitleColor;
+ (UIColor*)textfieldPlaceholderFocusedColor;
+ (UIColor*)textfieldPlaceholderColor;
+ (UIColor*)rulerSegmentDarkColor;
+ (UIColor*)rulerSegmentLightColor;
+ (UIColor*)settingsValueTextColor;
+ (UIColor*)textfieldTextColor;
+ (UIColor*)unknownSensorColor;
+ (UIColor*)actionButtonTextColor;
+ (UIColor*)alarmSelectionRowColor;
+ (UIColor*)pageControlTintColor;
+ (UIColor*)actionButtonDisabledColor;
+ (UIColor*)backViewCardShadowColor;
+ (UIColor*)lightTintColor;
+ (UIColor*)trendTextColor;
+ (UIColor*)cardBorderColor;
+ (UIColor*)trendGraphBottomColor;
+ (UIColor*)trendGraphTopColor;
+ (UIColor*)switchOffBackgroundColor;
+ (UIColor*)buttonContainerShadowColor;

// Shadows
+ (NSShadow*)insightShadow;
+ (NSShadow*)actionViewShadow;
+ (NSShadow*)backViewCardShadow;
+ (NSShadow*)buttonContainerShadow;

// Images
+ (UIImage*)humidityIcon;
+ (UIImage*)particleIcon;
+ (UIImage*)temperatureIcon;
+ (UIImage*)sense;
+ (UIImage*)wifiIcon;
+ (UIImage*)lockIcon;
+ (UIImage*)backIcon;
+ (UIImage*)sensePlacement;
+ (UIImage*)shakePill;
+ (UIImage*)smartAlarm;
+ (UIImage*)check;
+ (UIImage*)sensorHumidity;
+ (UIImage*)sensorHumidityBlue;
+ (UIImage*)sensorLight;
+ (UIImage*)sensorLightBlue;
+ (UIImage*)sensorParticulates;
+ (UIImage*)sensorParticulatesBlue;
+ (UIImage*)sensorSound;
+ (UIImage*)sensorSoundBlue;
+ (UIImage*)sensorTemperatureBlue;
+ (UIImage*)sensorTemperature;
+ (UIImage*)moon;
+ (UIImage*)alarmBarIcon;
+ (UIImage*)senseBarIcon;
+ (UIImage*)settingsBarIcon;
+ (UIImage*)trendsBarIcon;
+ (UIImage*)sensorsBarIcon;
+ (UIImage*)alarmSmartIcon;
+ (UIImage*)alarmSoundIcon;
+ (UIImage*)alarmRepeatIcon;
+ (UIImage*)senseIcon;
+ (UIImage*)pillIcon;
+ (UIImage*)presleepInsightParticulates;
+ (UIImage*)presleepInsightSound;
+ (UIImage*)presleepInsightLight;
+ (UIImage*)presleepInsightHumidity;
+ (UIImage*)presleepInsightTemperature;
+ (UIImage*)presleepInsightUnknown;
+ (UIImage*)loading;
+ (UIImage*)miniStopButton;
+ (UIImage*)miniPlayButton;
+ (UIImage*)infoButtonIcon;
+ (UIImage*)lightEventIcon;
+ (UIImage*)outOfBedEventIcon;
+ (UIImage*)sunriseEventIcon;
+ (UIImage*)sleepEventIcon;
+ (UIImage*)noiseEventIcon;
+ (UIImage*)inBedEventIcon;
+ (UIImage*)alarmEventIcon;
+ (UIImage*)partnerEventIcon;
+ (UIImage*)unknownEventIcon;
+ (UIImage*)lightsOutEventIcon;
+ (UIImage*)motionEventIcon;
+ (UIImage*)wakeupEventIcon;
+ (UIImage*)sunsetEventIcon;
+ (UIImage*)pillSetup;

// Drawing Methods
+ (void)drawSleepScoreGraphWithSleepScore: (CGFloat)sleepScore;
+ (void)drawBreakdownWithSleepScore: (CGFloat)sleepScore controlSize: (CGFloat)controlSize;

@end



@interface NSShadow (PaintCodeAdditions)

+ (instancetype)shadowWithColor: (UIColor*)color offset: (CGSize)offset blurRadius: (CGFloat)blurRadius;
- (void)set;

@end
