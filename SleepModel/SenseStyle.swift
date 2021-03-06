//
//  Style.swift
//  Sense
//
//  Created by Jimmy Lu on 1/26/17.
//  Copyright © 2017 Hello. All rights reserved.
//

import Foundation
import SenseKit
import UIKit

@available(iOS 8.2, *)
@objc class SenseStyle: NSObject {
    
    static let themeKey = "is.hello.app.theme"
    static let theme = Theme()
    static var currentTheme: SupportedTheme?
    
    @objc enum SupportedTheme: Int {
        case day = 0
        case night
        
        var name: String? {
            switch self {
                case .day:
                    return nil // default
                case .night:
                    return "nightTheme"
            }
        }
    }
    
    @objc enum Group: Int {
        case tableView = 1
        case tableViewFill
        case listItem
        case listItemSelection
        case navigationController
        case warningView
        case activityView
        case volumeControl
        case condition
        case collectionViewFill
        case headerFooter
        case attributedString
        case action
        case sensorCard
        case chartGradient
        case subNav
        case info
        case expansionRangePicker
        case insight
        case question
        case sleepDepth
        case sleepDepthAlpha
        case trendsTitles
        case transparentOverlay
        case timelineError
        case sleepScoreIcon
        case sleepSoundsState
        case sensePairing
        case pillPairing
        case settingsFooter
        case voiceTutorial
        case factoryReset
        case pillDfu
        case warningIcon
        case margins
        case errors
        
        var key: String {
            switch self {
                case .errors:
                    return "sense.errors"
                case .margins:
                    return "sense.margins"
                case .warningIcon:
                    return "sense.warning.icon"
                case .pillDfu:
                    return "sense.pill.dfu"
                case .factoryReset:
                    return "sense.factory.reset"
                case .voiceTutorial:
                    return "sense.voice.tutorial"
                case .settingsFooter:
                    return "sense.settings.footer"
                case .pillPairing:
                    return "sense.pill.pairing"
                case .sensePairing:
                    return "sense.pairing"
                case .sleepSoundsState:
                    return "sense.sleep.sounds.state"
                case .sleepScoreIcon:
                    return "sense.sleep.score.icon"
                case .timelineError:
                    return "sense.timeline.error"
                case .transparentOverlay:
                    return "sense.transparent.overlay"
                case .trendsTitles:
                    return "sense.trends.titles"
                case .chartGradient:
                    return "sense.chart.gradient"
                case .tableView:
                    return "sense.tableview"
                case .tableViewFill:
                    return "sense.tableview.fill"
                case .listItem:
                    return "sense.list.item"
                case .listItemSelection:
                    return "sense.list.item.selection"
                case .navigationController:
                    return "sense.navigation.controller"
                case .warningView:
                    return "sense.warning.view"
                case .activityView:
                    return "sense.activity.cover.view"
                case .volumeControl:
                    return "sense.volume.control"
                case .condition:
                    return "sense.condition"
                case .collectionViewFill:
                    return "sense.collectionview.fill"
                case .headerFooter:
                    return "sense.header.or.footer"
                case .attributedString:
                    return "sense.attributed.string"
                case .action:
                    return "sense.action"
                case .sensorCard:
                    return "sense.sensor.card"
                case .subNav:
                    return "sense.sub.navigation"
                case .info:
                    return "sense.info"
                case .expansionRangePicker:
                    return "sense.expansion.range.picker"
                case .insight:
                    return "sense.insight"
                case .question:
                    return "sense.question"
                case .sleepDepth:
                    return "sense.sleep.depth"
                case .sleepDepthAlpha:
                    return "sense.sleep.depth.alpha"
            }
            
        }
    }
    
    fileprivate static func loadDayThemeIfNotLoaded(auto: Bool) {
        if currentTheme != .day {
            currentTheme = .day
            theme.apply(auto: auto)
        }
    }
    
    @objc static func loadSavedTheme(auto: Bool) {
        guard HEMOnboardingService.shared().hasFinishedOnboarding() == true else {
            return self.loadDayThemeIfNotLoaded(auto: auto)
        }
        
        let preferences = SENLocalPreferences.shared()
        guard let themeValue = preferences!.userPreference(forKey: themeKey) as? NSNumber else {
            return self.loadDayThemeIfNotLoaded(auto: auto)
        }

        guard let supportedTheme = SupportedTheme(rawValue: themeValue.intValue) else {
            return self.loadDayThemeIfNotLoaded(auto: auto)
        }
        
        guard currentTheme != supportedTheme else {
            return // theme already loaded
        }
        
        if supportedTheme == .night {
            SYSTEM_COLOR = UIColor.white
        }
        
        currentTheme = supportedTheme
        theme.load(name: supportedTheme.name, auto: auto)
    }
    
    @objc static func saveTheme(theme: SupportedTheme, auto: Bool) {
        let preferences = SENLocalPreferences.shared()!
        preferences.setUserPreference(theme.hashValue, forKey: themeKey)
        self.loadSavedTheme(auto: auto)
    }
    
    @objc static func reset() {
        theme.unload(auto: true)
        currentTheme = nil
    }
    
    //MARK: - Value
    
    @objc static func value(group: Group, property: Theme.ThemeProperty) -> Any? {
        return self.theme.value(group: group.key, property: property)
    }
    
    @objc static func value(group: Group, propertyName: String) -> Any? {
        return self.theme.value(group: group.key, key: propertyName)
    }
    
    @objc static func value(aClass: AnyClass, property: Theme.ThemeProperty) -> Any? {
        return self.theme.value(aClass: aClass, property: property)
    }
    
    @objc static func value(aClass: AnyClass, propertyName: String) -> Any? {
        return self.theme.value(aClass: aClass, key: propertyName)
    }

}

extension SenseStyle {
    
    @objc static func float(aClass: AnyClass, property: Theme.ThemeProperty) -> CGFloat {
        return self.float(aClass: aClass, propertyName: property.key)
    }
    
    @objc static func float(aClass: AnyClass, propertyName: String) -> CGFloat {
        let number = self.theme.value(aClass: aClass, key: propertyName) as? NSNumber
        return CGFloat(number ?? 0.0)
    }
    
    @objc static func float(group: Group, property: Theme.ThemeProperty) -> CGFloat {
        return self.float(group: group, propertyName: property.key)
    }
    
    @objc static func float(group: Group, propertyName: String) -> CGFloat {
        let number = self.theme.value(group: group.key, key: propertyName) as? NSNumber
        return CGFloat(number ?? 0.0)
    }
    
}

extension SenseStyle {
    
    @nonobjc static var SYSTEM_COLOR = UIColor.black
    
    @objc enum ConditionStyle: Int {
        case alert = 0
        case warning
        case ideal
        case unknown
        
        var key: String {
            switch self {
            case .alert:
                return "sense.alert"
            case .warning:
                return "sense.warning"
            case .ideal:
                return "sense.ideal"
            case .unknown:
                return "sense.default"
            }
        }
    }
    
    enum SleepDepthStyle: String {
        case light = "sense.light"
        case medium = "sense.medium"
        case deep = "sense.deep"
    }
    
    @objc static func color(aClass: AnyClass, property: Theme.ThemeProperty) -> UIColor {
        return self.theme.value(aClass: aClass, key: property.key) as? UIColor ?? SYSTEM_COLOR
    }
    
    @objc static func color(aClass: AnyClass, propertyName: String) -> UIColor {
        return self.theme.value(aClass: aClass, key: propertyName) as? UIColor ?? SYSTEM_COLOR
    }
    
    @objc static func color(group: Group, property: Theme.ThemeProperty) -> UIColor {
        return self.value(group: group, property: property) as? UIColor ?? SYSTEM_COLOR
    }
    
    @objc static func color(group: Group, propertyName: String) -> UIColor {
        return self.theme.value(group: group.key, key: propertyName) as? UIColor ?? SYSTEM_COLOR
    }
    
    //MARK: - Color based on condition
    
    @objc static func color(condition: SENCondition, defaultColor: UIColor?) -> UIColor {
        switch condition {
        case .alert:
            return self.color(group: .condition, propertyName: ConditionStyle.alert.key)
        case .warning:
            return self.color(group: .condition, propertyName: ConditionStyle.warning.key)
        case .ideal:
            return self.color(group: .condition, propertyName: ConditionStyle.ideal.key)
        default:
            return defaultColor ?? self.color(group: .condition, propertyName: ConditionStyle.unknown.key)
        }
    }
    
    //MARK: - Color based on sleep depth
    
    @objc static func color(sleepState: SENTimelineSegmentSleepState) -> UIColor {
        return self.color(sleepState: sleepState, useAlpha: false)
    }
    
    @objc static func color(sleepState: SENTimelineSegmentSleepState, useAlpha: Bool) -> UIColor {
        let group = useAlpha == true ? Group.sleepDepthAlpha : Group.sleepDepth
        switch sleepState {
        case .light:
            return self.color(group: group, propertyName: SleepDepthStyle.light.rawValue)
        case .medium:
            return self.color(group: group, propertyName: SleepDepthStyle.medium.rawValue)
        case .sound:
            return self.color(group: group, propertyName: SleepDepthStyle.deep.rawValue)
        case .awake:
            fallthrough
        case .unknown:
            return UIColor.clear
            
        }
    }
    
}

extension SenseStyle {
    
    static let SYSTEM_FONT = UIFont.systemFont(ofSize: UIFont.systemFontSize)
    
    @objc static func font(aClass: AnyClass, property: Theme.ThemeProperty) -> UIFont {
        return self.theme.value(aClass: aClass, key: property.key) as? UIFont ?? SYSTEM_FONT
    }
    
    @objc static func font(aClass: AnyClass, propertyName: String) -> UIFont {
        return self.theme.value(aClass: aClass, key: propertyName) as? UIFont ?? SYSTEM_FONT
    }
    
    @objc static func font(group: Group, property: Theme.ThemeProperty) -> UIFont {
        return self.value(group: group, property: property) as? UIFont ?? SYSTEM_FONT
    }
    
    @objc static func font(group: Group, propertyName: String) -> UIFont {
        return self.theme.value(group: group.key, key: propertyName) as? UIFont ?? SYSTEM_FONT
    }
    
}

extension SenseStyle {

    @objc static func navigationBackImage() -> UIImage? {
        let backImageKey = "sense.back.image"
        return self.image(aClass: UINavigationBar.self, propertyName: backImageKey)?.withRenderingMode(.alwaysTemplate)
    }
    
    @objc static func image(aClass: AnyClass, property: Theme.ThemeProperty) -> UIImage? {
        return self.theme.value(aClass: aClass, key: property.key) as? UIImage
    }
    
    @objc static func image(aClass: AnyClass, propertyName: String) -> UIImage? {
        return self.theme.value(aClass: aClass, key: propertyName) as? UIImage
    }
    
    @objc static func image(group: Group, property: Theme.ThemeProperty) -> UIImage? {
        return self.value(group: group, property: property) as? UIImage
    }
    
    @objc static func image(group: Group, propertyName: String) -> UIImage? {
        return self.theme.value(group: group.key, key: propertyName) as? UIImage
    }
}
