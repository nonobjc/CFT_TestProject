//
//  ImageEditorViewController.swift
//  CFT_TestProject
//
//  Created by Alexander on 13/11/2018.
//  Copyright © 2018 Alexander. All rights reserved.
//

import UIKit

protocol ImageEditorView: class {
    func setMainImage(image: UIImage?)
    func updateDownloadProgress(progress: Float)
    func reloadTableData()
    func updateCell(row: Int,
                    progress: Float)
    func updateCell(row: Int,
                    image: UIImage?)
}

final class ImageEditorViewController: UIViewController {

    static let storyboardName = "ImageEditor"
    var presenter: ImageEditorViewPresenter!
    
    // MARK: - IBOutlets
    @IBOutlet private weak var imageButtonView: ImageButtonView!
    @IBOutlet private weak var rotateButton: UIButton!
    @IBOutlet private weak var greyscaleButton: UIButton!
    @IBOutlet private weak var mirrorImageButton: UIButton!
    @IBOutlet private weak var imagesTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageButtonView.presenter = ImageButtonPresenter(view: imageButtonView,
                                                         image: nil)
        if let imageButtonViewPresenter = imageButtonView.presenter as? ImageButtonPresenter,
            let selfPresenter = presenter as? ImageButtonViewDelegate {
            imageButtonViewPresenter.delegate = selfPresenter
        }
        imagesTableView.delegate = presenter as? UITableViewDelegate
        imagesTableView.dataSource = presenter as? UITableViewDataSource
        let cellNib = UINib(nibName: ImageEditorTableViewCell.reuseId,
                            bundle: nil)
        imagesTableView.register(cellNib,
                                 forCellReuseIdentifier: ImageEditorTableViewCell.reuseId)
        configureContent()
    }
    
    @IBAction private func rotateButtonPressed(_ sender: UIButton) {
        presenter.filterAction(filter: .rotate)
    }
    
    @IBAction private func greyscaleButtonPressed(_ sender: UIButton) {
        presenter.filterAction(filter: .greyscale)
    }
    
    @IBAction private func mirrorImageButtonPressed(_ sender: UIButton) {
        presenter.filterAction(filter: .mirrorImage)
    }
}

// MARK: - UI
extension ImageEditorViewController {
    
    private func configureContent() {
        rotateButton.setTitle(String.rotateButtonTitle,
                              for: .normal)
        greyscaleButton.setTitle(String.greyscaleButtonTitle,
                                 for: .normal)
        mirrorImageButton.setTitle(String.mirrorImageButtonTitle,
                                   for: .normal)
        imageButtonView.presenter.setButtonTitle(title: String.imageButtonViewTitle)
    }
}

// MARK: - ImageEditorView
extension ImageEditorViewController: ImageEditorView {
    
    func setMainImage(image: UIImage?) {
        guard let image = image else {
            imageButtonView.presenter.updateWithoutImage()
            return
        }
        imageButtonView.presenter.updateWithImage(image: image)
    }
    
    func updateDownloadProgress(progress: Float) {
        imageButtonView.presenter.updateWithDownloadingImage(progress: progress)
    }
    
    func reloadTableData() {
        imagesTableView.reloadData()
    }
    
    func updateCell(row: Int,
                    progress: Float) {
        let indexPath = IndexPath(row: row,
                                  section: 0)
        if let cell = imagesTableView.cellForRow(at: indexPath) as? ImageEditorTableViewCell {
            cell.updateProgress(progress: progress)
        }
    }
    
    func updateCell(row: Int,
                    image: UIImage?) {
        let indexPath = IndexPath(row: row,
                                  section: 0)
        if let cell = imagesTableView.cellForRow(at: indexPath) as? ImageEditorTableViewCell {
            cell.showImage(image: image)
        }
    }
}

// MARK: - UIImagePickerControllerDelegate
extension ImageEditorViewController: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let chosenImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        presenter.updateImage(image: chosenImage)
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - UIImagePickerControllerDelegate
extension ImageEditorViewController: UINavigationControllerDelegate {
}

// MARK: - String constants
private extension String {
   
    static let rotateButtonTitle = "IMAGE_FILTER__ROTATE".localized()
    static let greyscaleButtonTitle = "IMAGE_FILTER__GREYSCALE".localized()
    static let mirrorImageButtonTitle = "IMAGE_FILTER__MIRROR_IMAGE".localized()
    static let imageButtonViewTitle = "IMAGE_EDITOR__IMAGE_BUTTON_VIEW_TITLE".localized()
}
