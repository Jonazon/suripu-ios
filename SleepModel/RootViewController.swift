//
//  RootViewController.swift
//  Sense
//
//  Created by Jimmy Lu on 11/28/16.
//  Copyright © 2016 Hello. All rights reserved.
//

import UIKit
import SenseKit

@objc class RootViewController: HEMBaseController {
    
    fileprivate static let overlayAlpha = CGFloat(0.7)
    fileprivate static let animationDuration = TimeInterval(0.5)
    
    fileprivate var debugController: HEMDebugController?
    fileprivate var statusBarVisible = true
    fileprivate weak var shortcutHandler: ShortcutHandler?
    
    // MARK: Public Methods
    
    @objc static func currentRootViewController() -> RootViewController? {
        guard let applicationDelegate = UIApplication.shared.delegate else {
            return nil;
        }
        
        guard let applicationWindow = applicationDelegate.window else {
            return nil;
        }
        
        guard applicationWindow != nil else {
            return nil;
        }
        
        return applicationWindow!.rootViewController as? RootViewController
    }
    
    // MARK: - Status Bar

    @objc func hideStatusBar() {
        self.statusBarVisible = false
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    @objc func showStatusBar() {
        self.statusBarVisible = true
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    func isStatusBarHidden() -> Bool {
        return self.prefersStatusBarHidden
    }

    // MARK: - View Controller Overrides
    
    override var prefersStatusBarHidden: Bool {
        return !self.statusBarVisible
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.listenForSystemEvents()
        self.launchInitialController()
    }
    
    override func viewDidBecomeActive() {
        super.viewDidBecomeActive()
        HEMAppUsage.incrementUsage(forIdentifier: HEMAppUsageAppLaunched)
        SENAnalytics.track(kHEMAnalyticsEventAppLaunched)
    }
    
    override func viewDidEnterBackground() {
        super.viewDidEnterBackground()
        SENAnalytics.track(kHEMAnalyticsEventAppClosed)
    }
    
    // MARK: Public Methods
    
    @objc public func mainViewController() -> MainViewController? {
        return self.childViewControllers.first as? MainViewController
    }

    // MARK: - Notification Events
    
    fileprivate func listenForSystemEvents() {
        let center = NotificationCenter.default
        center.addObserver(self,
                           selector: #selector(didSignIn),
                           name: NSNotification.Name.SENAuthorizationServiceDidAuthorize,
                           object: nil)
        center.addObserver(self,
                           selector: #selector(didFinishOnboarding),
                           name: NSNotification.Name(rawValue: HEMOnboardingNotificationComplete),
                           object: nil)
        center.addObserver(self,
                           selector: #selector(didSignOut),
                           name: NSNotification.Name.SENAuthorizationServiceDidDeauthorize,
                           object: nil)
    }
    
    @objc fileprivate func didSignIn() {
        if HEMOnboardingService.shared().hasFinishedOnboarding() {
            showMainApp()
        }
    }
    
    @objc fileprivate func didSignOut() {
        showOnboarding()
    }
    
    @objc fileprivate func didFinishOnboarding() {
        showMainApp()
    }
    
    // MARK: - Onboarding vs Main
    
    fileprivate func launchInitialController() {
        if HEMOnboardingService.shared().hasFinishedOnboarding() {
            showMainApp()
        } else {
            showOnboarding()
        }
    }
    
    fileprivate func showOnboarding() {
        let service = HEMOnboardingService.shared()
        let checkpoint = service.onboardingCheckpoint()
        guard let controller = HEMOnboardingController.controller(for: checkpoint, force: false) else {
            let message = "attempt to launch onboarding with no controller"
            SENAnalytics.trackError(withMessage: message)
            return
        }
        launchController(controller: controller)
    }
    
    fileprivate func showMainApp() {
        launchController(controller: MainViewController())
    }
    
    fileprivate func launchController(controller: UIViewController) {
        let currentController = self.childViewControllers.first
        if object_getClass(currentController) == object_getClass(controller) {
            return
        }
        
        var currentModalController: UIViewController? = nil
        if ((currentController?.presentedViewController) != nil) {
            currentModalController = currentController!.presentedViewController!
        }
        
        let showMain = controller is MainViewController
        let containerFrame = self.view.bounds
        let containerHeight = containerFrame.size.height
        
        self.addChildViewController(controller)
        
        if currentController == nil {
            // fresh launch
            controller.view.frame = self.view.bounds
        } else {
            var controllerFrame = self.view.bounds
            controllerFrame.origin.y = !showMain ? containerHeight : 0
            controller.view.frame = controllerFrame
        }

        self.view.addSubview(controller.view)
        
        if currentController == nil {
            controller.didMove(toParentViewController: self)
        } else {
            // onboarding is show as if it's a modal by sliding up / down with
            // a dim overlay over the view
            let overlay = UIView(frame: self.view.bounds)
            overlay.backgroundColor = UIColor.black
            overlay.alpha = 0
            currentController!.willMove(toParentViewController: nil)
            currentController!.view.addSubview(overlay)
            
            if currentModalController != nil {
                currentController?.dismiss(animated: true, completion: {
                    currentController!.view.removeFromSuperview()
                    currentController!.removeFromParentViewController()
                })
            }
            
            animateSwitchOfController(from: currentController,
                                      withModal: currentModalController,
                                      to: controller,
                                      overlay: overlay)
        }
    }
    
    fileprivate func animateSwitchOfController(from: UIViewController?,
                                               withModal: UIViewController?,
                                               to: UIViewController,
                                               overlay: UIView) {
        
        let containerFrame = self.view.bounds
        let containerHeight = containerFrame.size.height
        let isMain = to is MainViewController
        
        UIView.animate(withDuration: RootViewController.animationDuration, animations: {
            overlay.alpha = RootViewController.overlayAlpha
            
            if (!isMain) {
                // logging out
                var onboardingFrame = to.view.frame
                onboardingFrame.origin.y = 0
                to.view.frame = onboardingFrame
            } else {
                var currentFrame = from!.view.frame
                currentFrame.origin.y = containerHeight
                from!.view.frame = currentFrame
            }
            
            if withModal != nil {
                var modalFrame = withModal!.view.frame
                modalFrame.origin.y = from!.view.frame.origin.y
                withModal!.view.frame = modalFrame
            }
            
        }, completion: { (finished: Bool) in
            if withModal != nil {
                from?.dismiss(animated: false, completion:nil)
            }
            from!.view.removeFromSuperview()
            from!.removeFromParentViewController()
            to.didMove(toParentViewController: self)
        })
    }
    
    // MARK: - Clean Up
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}

/**
 * Debug extension
 */
extension RootViewController {
    
    override var canBecomeFirstResponder: Bool {
        return HEMDebugController.isEnabled()
    }
    
    override func motionEnded(_ motion: UIEventSubtype, with _: UIEvent?) {
        let debugEnabled = HEMDebugController.isEnabled()
        let shakeMotion = motion == UIEventSubtype.motionShake
        if debugEnabled && shakeMotion {
            if self.debugController == nil {
                self.debugController = HEMDebugController(viewController: self)
            }
            self.debugController!.showSupportOptions()
        }
    }
    
}

extension RootViewController: ShortcutHandler {
    
    func canHandleAction(action: HEMShortcutAction) -> Bool {
        guard self.childViewControllers.count > 0 else {
            return false // there's also no other controllers to pass it to
        }
        
        var handled = false
        for controller in self.childViewControllers {
            if let handler = controller as? ShortcutHandler {
                if handler.canHandleAction(action: action) == true {
                    self.shortcutHandler = handler
                    handled = true
                    break
                }
            }
        }
        
        return handled
    }
    
    func takeAction(action: HEMShortcutAction, data: Any?) {
        self.shortcutHandler?.takeAction(action: action, data: data)
        self.shortcutHandler = nil
    }
    
}
