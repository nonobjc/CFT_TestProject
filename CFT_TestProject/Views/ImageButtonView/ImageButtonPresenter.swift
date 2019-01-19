//
//  ImageButtonPresenter.swift
//  CFT_TestProject
//
//  Created by Alexander on 19/11/2018.
//  Copyright © 2018 Alexander. All rights reserved.
//

import UIKit

protocol ImageButtonViewDelegate: class {
    func imagePressedAction()
}

protocol ImageButtonViewPresenter {
    init(view: ImageButtonViewProtocol,
         image: UIImage?)
    func updateWithImage(image: UIImage)
    func updateWithoutImage()
    func updateWithDownloadingImage(progress: Float)
    func setButtonTitle(title: String)
}

final class ImageButtonPresenter: ImageButtonViewPresenter {
    
    var image: UIImage?
    unowned let view: ImageButtonViewProtocol
    weak var delegate: ImageButtonViewDelegate?
    
    init(view: ImageButtonViewProtocol,
         image: UIImage?) {
        self.view = view
        self.image = image
    }
    
    func updateWithImage(image: UIImage) {
        view.updateWithImage(image: image)
    }
    
    func updateWithoutImage() {
        view.updateWithoutImage()
    }
    
    func updateWithDownloadingImage(progress: Float) {
        view.updateWithDownloadingImage(progress: progress)
    }
    
    func setButtonTitle(title: String) {
        view.setTitle(title: title)
    }
}
