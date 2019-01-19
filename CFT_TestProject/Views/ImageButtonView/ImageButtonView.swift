//
//  ImageButtonView.swift
//  CFT_TestProject
//
//  Created by Alexander on 16/11/2018.
//  Copyright © 2018 Alexander. All rights reserved.
//

import UIKit

protocol ImageButtonViewProtocol: class {
    func setTitle(title: String)
    func updateWithImage(image: UIImage)
    func updateWithoutImage()
    func updateWithDownloadingImage(progress: Float)
}

@IBDesignable final class ImageButtonView: UIView {

    let nibName = "ImageButtonView"
    var presenter: ImageButtonViewPresenter!
    // Main view
    @IBInspectable private var view: UIView!

    // MARK: - IBOutlets
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var chooseImageButton: UIButton!
    @IBOutlet private weak var progressView: UIProgressView!
    @IBOutlet private weak var progressLabel: UILabel!
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        // Setup view from .xib file
        try? xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        // Setup view from .xib file
        try? xibSetup()
    }
    
    private func xibSetup() throws {
        view = try loadViewFromNib()
        // use bounds not frame or it'll be offset
        view.frame = bounds
        // Make the view stretch with containing view
        view.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth,
                                 UIView.AutoresizingMask.flexibleHeight]
        // Adding custom subview on top of our view
        addSubview(view)
        
        let gestureRecogniser = UITapGestureRecognizer(target: self,
                                                       action: #selector(imageWasPressed(gesture:)))
        gestureRecogniser.delegate = self
        self.addGestureRecognizer(gestureRecogniser)
    }
    
    private func loadViewFromNib() throws -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName,
                        bundle: bundle)
        guard let view = nib.instantiate(withOwner: self,
                                         options: nil)[0] as? UIView else {
            throw GlobalError.nibInstantiateError
        }
        updateWithoutImage()
        return view
    }
    
    @IBAction private func chooseImageButtonPressed(_ sender: UIButton) {
        if let presenter = presenter as? ImageButtonPresenter {
            presenter.delegate?.imagePressedAction()
        }
    }
    
}

// MARK: - ImageButtonViewProtocol
extension ImageButtonView: ImageButtonViewProtocol {
    
    func setTitle(title: String) {
        chooseImageButton.setTitle(title,
                                   for: .normal)
    }
    
    func updateWithImage(image: UIImage) {
        imageView.isHidden = false
        progressView.isHidden = true
        progressLabel.isHidden = true
        chooseImageButton.isHidden = true
        imageView.image = image
    }
    
    func updateWithoutImage() {
        imageView.isHidden = true
        progressView.isHidden = true
        progressLabel.isHidden = true
        chooseImageButton.isHidden = false
        imageView.image = nil
    }
    
    func updateWithDownloadingImage(progress: Float) {
        imageView.isHidden = true
        progressView.isHidden = false
        progressLabel.isHidden = false
        chooseImageButton.isHidden = true
        imageView.image = nil
        
        progressView.progress = progress
        progressLabel.text = String(Int(progress * 100)) + " %"
    }
}

extension ImageButtonView: UIGestureRecognizerDelegate {
 
    @objc private func imageWasPressed(gesture: UITapGestureRecognizer) {
        let touchPoint = gesture.location(in: self)
        if let presenter = presenter as? ImageButtonPresenter {
            if imageView.point(inside: touchPoint,
                               with: nil) {
                presenter.delegate?.imagePressedAction()
            }
        }
    }
}
