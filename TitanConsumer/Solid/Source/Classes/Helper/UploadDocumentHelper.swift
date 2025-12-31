//
//  UploadDocumentHelper.swift
//  Solid
//
//  Created by Solid iOS Team on 20/05/20.
//  Copyright © 2021 Solid. All rights reserved.
//

import UIKit
import AVKit
import CoreServices
import Photos
import AssetsLibrary
import SDWebImage
// import SDWebImagePDFCoder

protocol DelegateUploadDocumentHelper: AnyObject {
    func delegateUploadDocumentHelperImagePickerDidFinishSuccess(tempImage aTempImage: UIImage, fileName: String)
    func delegateUploadDocumentHelperImagePickerDidFinishFail(errorString anErrorString: String)
    func delegateUploadDocumentHelperDocumentPickerDidFinishSuccess(fileUrl aFielURL: URL)
}

class UploadDocumentHelper: NSObject, UIDocumentPickerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var parent: UIViewController?
    static let sharedInstance = UploadDocumentHelper()

    weak var delegate: DelegateUploadDocumentHelper?
    var isImageEditRequired = true

    func getImageFor(fileUrl: URL) -> UIImage? {
        do {
            let imageData = try Data(contentsOf: fileUrl)
            let convertedImage = UIImage(data: imageData)
            return convertedImage
        } catch {
            return nil
        }
    }

    func displayUploadOptions(sourceView aSourceView: UIView) {
        let document = UIAlertAction(title: Utility.localizedString(forKey: "RCD_upload_document"), style: .default) { (_) in
            self.selectDocument()
        }

        let gallery = UIAlertAction(title: Utility.localizedString(forKey: "RCD_upload_image"), style: .default) { (_) in
            self.chooseFromGallery()
        }
        let camera = UIAlertAction(title: Utility.localizedString(forKey: "RCD_take_photo"), style: .default) { (_) in
            self.capture()
        }

        let cancel = UIAlertAction(title: Utility.localizedString(forKey: "cancel"), style: .cancel, handler: nil)

        let alertController = MoreOptionsController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(document)
        alertController.addAction(gallery)
        alertController.addAction(camera)
        alertController.addAction(cancel)

        if Utility.isDeviceIpad(), let popoverController = alertController.popoverPresentationController {
                popoverController.sourceView = aSourceView
                popoverController.permittedArrowDirections = []
		}
        alertController.present(from: parent!, animated: true, sourceView: aSourceView)

    }

    func displayPhotoUploadOptions(sourceView aSourceView: UIView) {
        let document = UIAlertAction(title: Utility.localizedString(forKey: "RCD_photoUploadOption1"), style: .default) { (_) in
            self.selectDocument(onlyPhotos: true)
        }

        let gallery = UIAlertAction(title: Utility.localizedString(forKey: "RCD_photoUploadOption2"), style: .default) { (_) in
            self.chooseFromGallery()
        }

        let cancel = UIAlertAction(title: Utility.localizedString(forKey: "cancel"), style: .cancel, handler: nil)

        let alertController = MoreOptionsController(title: Utility.localizedString(forKey: "RCD_photoUploadOptiosTitle"), message: nil, preferredStyle: .actionSheet)
        alertController.addAction(document)
        alertController.addAction(gallery)
        alertController.addAction(cancel)

        if Utility.isDeviceIpad(), let popoverController = alertController.popoverPresentationController {
                popoverController.sourceView = aSourceView
                popoverController.permittedArrowDirections = []
            }
        alertController.present(from: parent!, animated: true, sourceView: aSourceView)
    }

    func selectDocument(onlyPhotos: Bool? = false) {

        var documentTypesArray = [kUTTypePDF as String, kUTTypeImage as String, kUTTypePNG as String, kUTTypeJPEG as String]
		if let photos = onlyPhotos, !photos {
			documentTypesArray = [kUTTypeImage as String, kUTTypePNG as String, kUTTypeJPEG as String]
		}

        let documentPicker = UIDocumentPickerViewController(documentTypes: documentTypesArray, in: .import)
        documentPicker.delegate = self
        if UIDevice.current.userInterfaceIdiom == .pad {
            documentPicker.modalPresentationStyle = .fullScreen
        }
        DispatchQueue.main.async {
            self.parent!.present(documentPicker, animated: true, completion: nil)
        }
    }

    func chooseFromGallery() {
        self.showImageGallery()
    }

    func showImageGallery() {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = isImageEditRequired
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.modalPresentationStyle = UIModalPresentationStyle.currentContext
        imagePicker.delegate = self
        parent!.present(imagePicker, animated: true)
    }

    func capture(isMaskingOn: Bool? = false) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
            AVCaptureDevice.requestAccess(for: AVMediaType.video) { response in
                if response {
                    DispatchQueue.main.async {
                        self.showImageCaptureScreen(isMaskingOn: isMaskingOn)
                    }
                } else {
                    self.showAlertWhenAccessIsDenied()
                }
            }
        }
    }

    func showAlertWhenAccessIsDenied() {
        let title   = Utility.localizedString(forKey: "RCD_camera_permission_title")
        var msg     =  Utility.localizedString(forKey: "RCD_camera_permission_message")
        let appName = AppMetaDataHelper.shared.getAppName
        msg  = String(format: msg, appName)
        let ac      = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let later   = UIAlertAction(title: Utility.localizedString(forKey: "RCD_later"), style: .default, handler: nil)
        let settings = UIAlertAction(title: Utility.localizedString(forKey: "RCD_settings"), style: .default, handler: { (_) in
            let settingsUrl = NSURL(string: UIApplication.openSettingsURLString)
            if let url = settingsUrl {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url as URL)
                }
            }
        })
        ac.addAction(later)
		ac.addAction(settings)
        DispatchQueue.main.async {
            self.parent!.present(ac, animated: true)
        }
    }

    func showImageCaptureScreen(isMaskingOn: Bool? = false) {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = isImageEditRequired
        imagePicker.sourceType = UIImagePickerController.SourceType.camera
        imagePicker.modalPresentationStyle = UIModalPresentationStyle.currentContext
        imagePicker.delegate = self
		if  isMaskingOn ?? false {
            let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
            let statusBarHeight = window?.windowScene?.statusBarManager!.statusBarFrame.height ?? 0

            let pickerFrame = CGRect(x: 0, y: statusBarHeight, width: imagePicker.view.bounds.width, height: imagePicker.view.bounds.height - imagePicker.navigationBar.bounds.size.height - imagePicker.toolbar.bounds.size.height - statusBarHeight)
				let squareFrame = CGRect(x: pickerFrame.origin.x + 20, y: pickerFrame.origin.y + 20, width: pickerFrame.size.width - 40, height: pickerFrame.size.height - 40)

				let overlayView: UIView = UIView(frame: squareFrame)
				overlayView.backgroundColor = UIColor.yellow.withAlphaComponent(0.5)
				imagePicker.cameraOverlayView = overlayView
		}

        parent!.present(imagePicker, animated: true)
    }

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard !urls.isEmpty else {
            return
        }
        let fileurl = urls[0]
        do {
            delegate?.delegateUploadDocumentHelperDocumentPickerDidFinishSuccess(fileUrl: fileurl)
        }
    }

    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        var tempImage: UIImage!
        if let img = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            tempImage = img
        } else if let oImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            tempImage = oImage
        }

        guard let _ = tempImage.jpegData(compressionQuality: 1) else {
            delegate?.delegateUploadDocumentHelperImagePickerDidFinishFail(errorString: "Unable to load image")
            return
        }

        var fileName = "Document"
        if let asset = info[UIImagePickerController.InfoKey.phAsset] as? PHAsset {
            let assetResources = PHAssetResource.assetResources(for: asset)
            if let resourceObj = assetResources.first {
                fileName = resourceObj.originalFilename
            }
        }

        delegate?.delegateUploadDocumentHelperImagePickerDidFinishSuccess(tempImage: tempImage, fileName: fileName)
        parent!.dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {

        parent!.dismiss(animated: true, completion: nil)
    }
}
