//
//  NavigationBarConfiguration.swift
//  Netflix-Clone
//
//  Production-level fix for UINavigationBar ItemWrapperView constraint conflicts.
//

import UIKit

/// Utilities to avoid UINavigationBar ItemWrapperView.width==0 constraint conflicts.
enum NavigationBarConfiguration {

    /// Defer bar item configuration to the next run loop.
    /// UIKit's NavigationButtonBar uses staged layout; during the first pass,
    /// ItemWrapperView gets temporary width=0. Configuring bar items in viewDidLoad
    /// races with this. Deferring lets the bar complete its initial layout first.
    static func configureBarItemsDeferred(_ block: @escaping () -> Void) {
        DispatchQueue.main.async {
            block()
        }
    }
}
