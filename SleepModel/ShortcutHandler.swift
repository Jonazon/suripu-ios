//
//  ShortcutHandler.swift
//  Sense
//
//  Created by Jimmy Lu on 12/9/16.
//  Copyright © 2016 Hello. All rights reserved.
//

import Foundation

@objc protocol ShortcutHandler: class {
    
    /**
     * Usually a handler is a UIViewController and it should the action specified
     * and return true if it was able to handle it.  If it cannot handle the
     * action, the controller should relay the call to other controllers conforming
     * to the protocol that it contains.
     *
     * - Parameter action: action triggered on launch of the app through force touch
     * - Return true if handled, no otherwise
     */
    @objc func canHandleAction(action: HEMShortcutAction) -> Bool
    
    /**
     * If a UIViewController can handle the action, the calling controller should
     * additionally call the controller to take the action and discontinue the
     * relay
     *
     * - Parameter action: action to take
     * - Parameter data: optional associated data for the action
     */
    @objc func takeAction(action: HEMShortcutAction, data: Any?)
    
}
