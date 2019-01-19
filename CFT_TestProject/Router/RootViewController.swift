//
//  RootViewController.swift
//  CFT_TestProject
//
//  Created by Alexander on 20/11/2018.
//  Copyright © 2018 Alexander. All rights reserved.
//

import UIKit

// This controller is responsible for all transitions in the app.
final class RootViewController: UIViewController {
    
    var currentController: UIViewController?
    
    init(initialStoryboardName: String) {
        let storyboard = UIStoryboard(name: initialStoryboardName,
                                      bundle: nil)
        currentController = storyboard.instantiateInitialViewController()
        if let currentController = currentController as? ImageEditorViewController {
            currentController.presenter = ImageEditorPresenter(view: currentController,
                                                               mainImage: nil)
        }
        super.init(nibName: nil,
                   bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder) 
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let currentController = currentController {
            addChild(currentController)
            currentController.view.frame = view.bounds
            view.addSubview(currentController.view)
            currentController.didMove(toParent: self)
        }
    }
}
