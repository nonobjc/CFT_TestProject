//
//  ImageEditorPresenter.swift
//  CFT_TestProject
//
//  Created by Alexander on 19/11/2018.
//  Copyright © 2018 Alexander. All rights reserved.
//

import UIKit

protocol ImageEditorViewPresenter {
    init(view: ImageEditorView,
         mainImage: UIImage?)
    func updateImage(image: UIImage?)
    func filterAction(filter: ImageFilter)
    func reloadTableData()
}

final class ImageEditorPresenter: NSObject, ImageEditorViewPresenter {
    
    private unowned let view: ImageEditorView
    private let imageDownloader = ImageDownloader()
    private var filteredImages: [FilteredImage]
    private let persistentSerivce: PersistentService
    private var mainImage: UIImage? {
        didSet {
            view.setMainImage(image: mainImage)
        }
    }
    
    init(view: ImageEditorView,
         mainImage: UIImage?) {
        self.view = view
        self.mainImage = mainImage
        filteredImages = [FilteredImage]()
        persistentSerivce = PersistentService()
        super.init()
        imageDownloader.delegate = self
        filteredImages = persistentSerivce.getData()
    }
    
    func updateImage(image: UIImage?) {
        mainImage = image
        view.setMainImage(image: image)
    }
    
    func filterAction(filter: ImageFilter) {
        if let mainImage = mainImage {
            let filteredImage = FilteredImage(inputImage: mainImage,
                                              filter: filter,
                                              filterDuration: getRandomTime(),
                                              arrayIndex: filteredImages.count)
            filteredImages.append(filteredImage)
            reloadTableData()
            filteredImage.delegate = self
            filteredImage.startFiltering()
        }
    }
    
    func reloadTableData() {
        view.reloadTableData()
    }
    
    private func presentErrorAlert(with message: String,
                                   action: @escaping () -> () = {}) {
        let alert = UIAlertController(title: String.alertErrorTitle,
                                      message: message,
                                      preferredStyle: .alert)
        let okAction = UIAlertAction(title: String.okText,
                                     style: .default) { _ in
            action()
        }
        alert.addAction(okAction)
        if let view = view as? UIViewController {
            view.present(alert,
                         animated: true)
        }
    }
    
    private func getRandomTime() -> Int {
        let random = Int(Double(arc4random()) / Double(UInt32.max) * 25) + 5
        return random
    }
}

// MARK: - ImageOwnerDelegate
extension ImageEditorPresenter: ImageOwnerDelegate {
    func updateCell(row: Int,
                    progress: Float) {
        view.updateCell(row: row,
                        progress: progress)
    }
    
    func showImageInCell(row: Int) {
        let filteredImage = filteredImages[row]
        persistentSerivce.save(filteredImage: filteredImage)
        view.updateCell(row: row,
                        image: filteredImage.outputImage)
    }
}

// MARK: - ImageDownloaderDelegate
extension ImageEditorPresenter: ImageDownloaderDelegate {

    func imageIsDownloadedAction(downloadedImage: UIImage?) {
        guard let image = downloadedImage else {
            presentErrorAlert(with: String.alertDownloadErrorMessage) { [weak self] in
                DispatchQueue.main.async { [weak self] in
                    self?.updateImage(image: nil)
                }
            }
            return
        }
        updateImage(image: image)
    }
    
    func updateDownloadProgressAction(progress: Float) {
        view.updateDownloadProgress(progress: progress)
    }
}

// MARK: - ImageButtonViewDelegate
extension ImageEditorPresenter: ImageButtonViewDelegate {
    
    func imagePressedAction() {
        createImageActionSheet()
    }
    
    private func createImageActionSheet() {
        let alert = UIAlertController(title: String.imageAlertTitle,
                                      message: nil,
                                      preferredStyle: .actionSheet)
        let libraryAction = UIAlertAction(title: String.imageAlertLibraryCase,
                                          style: .default) { [weak self] _ in
            self?.openImagePicker(.photoLibrary)
        }
        let cameraAction = UIAlertAction(title: String.imageAlertCameraCase,
                                         style: .default) { [weak self] _ in
            self?.openImagePicker(.camera)
        }
        let downloadAction = UIAlertAction(title: String.imageAlertDownloadCase,
                                           style: .default) { [weak self] _ in
            self?.createDownloadLinkAlert()
        }
        let cancelAction = UIAlertAction(title: String.cancelText,
                                         style: .cancel)
        alert.addAction(libraryAction)
        alert.addAction(cameraAction)
        alert.addAction(downloadAction)
        alert.addAction(cancelAction)
        if let view = view as? UIViewController {
            view.present(alert,
                         animated: true)
        }
    }
    
    private func createDownloadLinkAlert() {
        let alert = UIAlertController(title: String.downloadAlertTitle,
                                      message: nil,
                                      preferredStyle: .alert)
        alert.addTextField { newTextField in
            newTextField.placeholder = String.downloadAlertTextFieldPlaceholder
        }
        let cancelAction = UIAlertAction(title: String.cancelText,
                                         style: .cancel)
        let downloadAction = UIAlertAction(title: String.downloadText,
                                           style: .default) { [weak self] _ in
            if let urlString = alert.textFields?.first?.text,
                let url = URL(string: urlString) {
                    self?.imageDownloader.downloadImage(with: url)
            } else {
                DispatchQueue.main.async {
                    self?.presentErrorAlert(with: String.linkIsInvalidMessage) {
                    }
                }
            }
        }
        alert.addAction(cancelAction)
        alert.addAction(downloadAction)
        if let view = view as? UIViewController {
            view.present(alert,
                         animated: true)
        }
    }
    
    private func openImagePicker(_ source: UIImagePickerController.SourceType) {
        guard UIImagePickerController.isSourceTypeAvailable(source) else {
            return
        }
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = view as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
        imagePicker.sourceType = source
        if let view = view as? UIViewController {
            view.present(imagePicker,
                         animated: true)
        }
    }
}

// MARK: - UITableViewDelegate
extension ImageEditorPresenter: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        showCellPressedAlert(cellRow: indexPath.row)
    }
    
    private func showCellPressedAlert(cellRow: Int) {
        let alert = UIAlertController(title: nil,
                                      message: nil,
                                      preferredStyle: .actionSheet)
        let makeMainAction = UIAlertAction(title: String.cellPressedAlertMainImageCase,
                                           style: .default) { _ in
            DispatchQueue.main.async { [weak self] in
                self?.makeMainImageAction(index: cellRow)
            }
        }
        let saveAction = UIAlertAction(title: String.cellPressedAlertSaveCase,
                                       style: .default) { _ in
            DispatchQueue.main.async { [weak self] in
                self?.saveImageAction(index: cellRow)
            }
        }
        let deleteAction = UIAlertAction(title: String.cellPressedAlertDeleteCase,
                                         style: .destructive) { _ in
            DispatchQueue.main.async { [weak self] in
                self?.deleteImageAction(index: cellRow)
            }
        }
        let cancelAction = UIAlertAction(title: String.cancelText,
                                         style: .cancel,
                                         handler: nil)
        alert.addAction(makeMainAction)
        alert.addAction(saveAction)
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        if let view = view as? UIViewController {
            view.present(alert,
                         animated: true)
        }
    }
    
    private func makeMainImageAction(index: Int) {
        let filteredImage = filteredImages[index]
        if let newImage = filteredImage.outputImage {
            mainImage = newImage
        } else {
            presentErrorAlert(with: String.filterImageErrorMessage)
        }
    }
    
    private func saveImageAction(index: Int) {
        let filteredImage = filteredImages[index]
        if let newImage = filteredImage.outputImage {
            UIImageWriteToSavedPhotosAlbum(newImage,
                                           self,
                                           #selector(imageSavedToLibrary(_:didFinishSavingWithError:contextInfo:)),
                                           nil)
        } else {
            presentErrorAlert(with: String.filterImageErrorMessage)
        }
    }
    
    @objc private func imageSavedToLibrary(_ image: UIImage,
                                           didFinishSavingWithError error: NSError?,
                                           contextInfo: UnsafeRawPointer) {
        if let error = error {
            presentErrorAlert(with: error.localizedDescription)
        } else {
            let alert = UIAlertController(title: String.imageSavedSuccessfully,
                                          message: nil,
                                          preferredStyle: .alert)
            let okAction = UIAlertAction(title: String.okText,
                                         style: .default)
            alert.addAction(okAction)
            if let view = view as? UIViewController {
                view.present(alert,
                             animated: true)
            }
        }
    }
    
    private func deleteImageAction(index: Int) {
        let filteredImage = filteredImages[index]
        filteredImage.stopFiltering()
        filteredImages.remove(at: index)
        persistentSerivce.delete(filteredImage: filteredImage)
        for (index, item) in filteredImages.enumerated() {
            item.currentArrayIndex.int = index
        }
        reloadTableData()
    }
}

// MARK: - UITableViewDataSource
extension ImageEditorPresenter: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return filteredImages.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImageEditorTableViewCell.reuseId,
                                                 for: indexPath)
        if let imageCell = cell as? ImageEditorTableViewCell {
            imageCell.setContent(filteredImage: filteredImages[indexPath.row])
        }
        return cell
    }
}

// MARK: - String constants
private extension String {
    
    static let imageAlertTitle = "IMAGE_EDITOR__IMAGE_ALERT_TITLE".localized()
    static let imageAlertLibraryCase = "IMAGE_EDITOR__IMAGE_ALERT_LIBRARY_CASE".localized()
    static let imageAlertCameraCase = "IMAGE_EDITOR__IMAGE_ALERT_CAMERA_CASE".localized()
    static let imageAlertDownloadCase = "IMAGE_EDITOR__IMAGE_ALERT_DOWNLOAD_CASE".localized()
    static let cancelText = "IMAGE_EDITOR__CANCEL_TEXT".localized()
    static let alertErrorTitle = "IMAGE_EDITOR__ALERT_ERROR_TITLE".localized()
    static let alertDownloadErrorMessage = "IMAGE_EDITOR__ALERT_DOWNLOAD_ERROR_MESSAGE".localized()
    static let okText = "IMAGE_EDITOR__OK_TEXT".localized()
    static let downloadAlertTitle = "IMAGE_EDITOR__DOWNLOAD_ALERT_TITLE".localized()
    static let downloadText = "IMAGE_EDITOR__DOWNLOAD_TEXT".localized()
    static let downloadAlertTextFieldPlaceholder = "IMAGE_EDITOR__DONWLOAD_ALERT_TEXT_FIELD_PLACEHOLDER".localized()
    static let linkIsInvalidMessage = "IMAGE_EDITOR__INVALID_URL_ERROR_MESSAGE".localized()
    static let cellPressedAlertMainImageCase = "IMAGE_EDITOR__CELL_PRESSED_ALERT_MAIN_IMAGE_CASE".localized()
    static let cellPressedAlertSaveCase = "IMAGE_EDITOR__CELL_PRESSED_ALERT_SAVE_CASE".localized()
    static let cellPressedAlertDeleteCase = "IMAGE_EDITOR__CELL_PRESSED_ALERT_DELETE_CASE".localized()
    static let filterImageErrorMessage = "IMAGE_EDITOR__FILTER_IMAGE_ERROR_MESSAGE".localized()
    static let imageSavedSuccessfully = "IMAGE_EDITOR__IMAGE_SAVED_ALERT_TITLE".localized()
}

