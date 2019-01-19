//
//  AppRouter.swift
//  CFT_TestProject
//
//  Created by Alexander on 20/11/2018.
//  Copyright © 2018 Alexander. All rights reserved.
//

import UIKit

final class AppRouter {
    
    private static let initialStoryboardName = ImageEditorViewController.storyboardName
    static var rootViewController: RootViewController?
    
    static func getInitialWindow() -> UIWindow {
        let initialViewController = RootViewController(initialStoryboardName: initialStoryboardName)
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = initialViewController
        rootViewController = initialViewController
        
        return window
    }
    
    // Without animation
    static func showNewController(newController: UIViewController) {
        if let rootVC = rootViewController {
            rootVC.addChild(newController)
            newController.view.frame = rootVC.view.bounds
            rootVC.view.addSubview(newController.view)
            newController.didMove(toParent: rootVC)
            rootVC.currentController?.willMove(toParent: nil)
            rootVC.currentController?.view.removeFromSuperview()
            rootVC.currentController?.removeFromParent()
            rootVC.currentController = newController
        }
    }
    
    // Example of transition with animation(fade)
    static func animateFadeTransition(to newViewController: UIViewController,
                                      completion: (() -> Void)? = nil) {
        if let rootVC = rootViewController {
            rootVC.currentController?.willMove(toParent: nil)
            rootVC.addChild(newViewController)
            
            if let currentController = rootVC.currentController {
                rootVC.transition(from: currentController,
                                  to: newViewController,
                                  duration: 0.3,
                                  options: [.transitionCrossDissolve, .curveEaseOut],
                                  animations: {
                                      rootVC.currentController?.removeFromParent()
                                      newViewController.didMove(toParent: rootVC)
                                      rootVC.currentController = newViewController
                }) { isAnimationFinished in
                    completion?()
                }
            }
        }
    }
}
