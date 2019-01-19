//
//  ImageEditorTableViewCell.swift
//  CFT_TestProject
//
//  Created by Alexander on 26/11/2018.
//  Copyright © 2018 Alexander. All rights reserved.
//

import UIKit

final class ImageEditorTableViewCell: UITableViewCell {
    
    static let reuseId = "ImageEditorTableViewCell"
    
    @IBOutlet private weak var filterTextLabel: UILabel!
    @IBOutlet private weak var filteredImageView: UIImageView!
    @IBOutlet private weak var filterValueLabel: UILabel!
    @IBOutlet private weak var progressView: UIProgressView!
    @IBOutlet private weak var progressLabel: UILabel!
    
    func setContent(filteredImage: FilteredImage) {
        filterTextLabel.text = String.filterLabel
        filteredImageView.image = filteredImage.outputImage
        filterValueLabel.text = filteredImage.filter.getText()
        if filteredImage.filterFinished {
            showImage(image: filteredImage.outputImage)
        } else {
            let progress: Float = 0
            updateProgress(progress: progress)
        }
    }
    
    func updateProgress(progress: Float) {
        filteredImageView.isHidden = true
        progressView.isHidden = false
        progressLabel.isHidden = false
        progressView.progress = progress
        progressLabel.text = String(Int(progress * 100)) + " %"
    }
    
    func showImage(image: UIImage?) {
        filteredImageView.image = image
        filteredImageView.isHidden = false
        progressView.isHidden = true
        progressLabel.isHidden = true
    }
}

private extension String {
    static let filterLabel = "IMAGE_EDITOR_TABLE_VIEW_CELL__FILTER_LABEL".localized()
}
