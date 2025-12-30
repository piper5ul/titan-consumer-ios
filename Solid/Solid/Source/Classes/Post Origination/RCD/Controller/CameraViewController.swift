//
//  CameraViewController.swift
//  Solid
//
//  Created by Solid iOS Team on 20/05/20.
//  Copyright © 2021 Solid. All rights reserved.
//

import UIKit
import AVFoundation
import QuartzCore
import Photos

class CameraViewController: BaseVC {

    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var cameraFooterView: UIView!
    @IBOutlet weak var flashButton: UIButton!
    @IBOutlet weak var cameraClickButton: BaseButton!
    @IBOutlet weak var instructionsStackView: UIStackView!

    @IBOutlet weak var instructionLabel1: UILabel!
    @IBOutlet weak var iconImageView1: UIImageView!
    @IBOutlet weak var instructionLabel2: UILabel!
    @IBOutlet weak var iconImageView2: UIImageView!

    var onCapture: ((UIImage) -> Void)?

    var viewModel: RCDViewModel!
    var currentUploadingSide: CheckImageSide!

    var captureSession: AVCaptureSession?
    var currentCameraPosition: CameraPosition?
    var photoOutput: AVCapturePhotoOutput?
    var rearCamera: AVCaptureDevice?
    var rearCameraInput: AVCaptureDeviceInput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var flashMode = AVCaptureDevice.FlashMode.off
    var photoCaptureCompletionBlock: ((UIImage?, Error?) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupInitialUI()
        startPreparingCamera()
    }

    @IBAction func cancelClicked(_ sender: Any) {
        self.dismissController()
    }

    @IBAction func toggleFlash(_ sender: UIButton) {

        guard let device = rearCamera else {return}
        self.flashMode = (self.flashMode == .on) ? .off : .on
        flashButton.isSelected = !flashButton.isSelected

        if device.hasTorch {
            do {
                try device.lockForConfiguration()
                device.torchMode = flashButton.isSelected ? .on : .off
                device.unlockForConfiguration()
            } catch {

            }
        }
    }

    @IBAction func captureClicked(_ sender: Any) {

        self.captureImage {(image, error) in
            guard let image = image else {
                print(error ?? "Image capture error")
                return
            }

            var finalImage = image
            if let rotatedImage = image.rotate(radians: -.pi/2) {
                finalImage = rotatedImage
            }

            self.viewModel.setImageActionHappen(action: .capture)
            self.onCapture?(finalImage)
            self.dismissController()
        }
    }
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        cameraFooterView.backgroundColor = .background
        cameraClickButton.imageView?.tintColor = .brandColor
    }
}

// MARK: - Other Methods
extension CameraViewController {

    func setupInitialUI() {
        addBackNavigationbarButton()
        cameraClickButton.imageView?.tintColor = .brandColor
        cameraClickButton.backgroundColor = .clear
        cameraFooterView.backgroundColor = .background
        if let side = currentUploadingSide {
            self.title = (side == .front) ? Utility.localizedString(forKey: "RCD_frontTitle") : Utility.localizedString(forKey: "RCD_backTitle")
        }

        let newX = instructionsStackView.frame.size.width/1.7
        var trans = CGAffineTransform.identity
        trans = trans.translatedBy(x: newX, y: 00)
        trans = trans.rotated(by: CGFloat.pi / 2)
        instructionsStackView.transform = trans

		let instructionLabelFont = Utility.isDeviceIpad() ? Constants.regularFontSize18 : Constants.regularFontSize12

        instructionLabel1?.text = Utility.localizedString(forKey: "RCD_cameraInstruction1")
        instructionLabel1?.font = instructionLabelFont
        instructionLabel1?.textColor = UIColor.white

        instructionLabel2?.text = Utility.localizedString(forKey: "RCD_cameraInstruction2")
        instructionLabel2?.font = instructionLabelFont
        instructionLabel2?.textColor = UIColor.white
    }

    func startPreparingCamera() {

        self.prepare {(error) in
            if let error = error {
                print(error)
            }

            try? self.displayPreview(on: self.cameraView)
        }
    }

    func gotoConfirmationScreen(with image: UIImage?) {
        let storyboard: UIStoryboard = UIStoryboard(name: "RCD", bundle: nil)
        if let confirmVC = storyboard.instantiateViewController(withIdentifier: "CaptureConfirmationViewController") as? CaptureConfirmationViewController {
            confirmVC.viewModel = viewModel
            confirmVC.currentUploadingSide = currentUploadingSide
            confirmVC.currentCaptureAction = .capture
            confirmVC.selectedImage = image
            self.navigationController?.pushViewController(confirmVC, animated: true)
        }
    }
}

extension CameraViewController {

    func prepare(completionHandler: @escaping (Error?) -> Void) {
        func createCaptureSession() {
            self.captureSession = AVCaptureSession()
        }

        func configureCaptureDevices() throws {

            let session = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .unspecified)

            let cameras = session.devices.compactMap { $0 }
            guard !cameras.isEmpty else { throw CameraControllerError.noCamerasAvailable }

            for camera in cameras where camera.position == .back {
                self.rearCamera = camera
                
                try camera.lockForConfiguration()
                camera.focusMode = .continuousAutoFocus
                camera.unlockForConfiguration()
            }
        }

        func configureDeviceInputs() throws {
            guard let captureSession = self.captureSession else { throw CameraControllerError.captureSessionIsMissing }

            if let rearCamera = self.rearCamera {
                self.rearCameraInput = try AVCaptureDeviceInput(device: rearCamera)

                if captureSession.canAddInput(self.rearCameraInput!) {
                    captureSession.addInput(self.rearCameraInput!)
                }

                self.currentCameraPosition = .rear
            } else { throw CameraControllerError.noCamerasAvailable }
        }

        func configurePhotoOutput() throws {
            guard let captureSession = self.captureSession else { throw CameraControllerError.captureSessionIsMissing }

            self.photoOutput = AVCapturePhotoOutput()
            self.photoOutput!.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])], completionHandler: nil)

            if captureSession.canAddOutput(self.photoOutput!) {
                captureSession.addOutput(self.photoOutput!)
            }
            captureSession.startRunning()
        }

        DispatchQueue(label: "prepare").async {
            do {
                createCaptureSession()
                try configureCaptureDevices()
                try configureDeviceInputs()
                try configurePhotoOutput()
            } catch {
                DispatchQueue.main.async {
                    completionHandler(error)
                }

                return
            }

            DispatchQueue.main.async {
                completionHandler(nil)
            }
        }
    }

    func captureImage(completion: @escaping (UIImage?, Error?) -> Void) {
        guard let captureSession = captureSession, captureSession.isRunning else {
            completion(nil, CameraControllerError.captureSessionIsMissing)
            return
        }

        let settings = AVCapturePhotoSettings()
        settings.flashMode = self.flashMode

        self.photoOutput?.capturePhoto(with: settings, delegate: self)
        self.photoCaptureCompletionBlock = completion
    }

    func displayPreview(on view: UIView) throws {
        guard let captureSession = self.captureSession, captureSession.isRunning else { throw CameraControllerError.captureSessionIsMissing }

        self.previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.previewLayer?.connection?.videoOrientation = .portrait

        view.layer.insertSublayer(self.previewLayer!, at: 1)
        self.previewLayer?.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height)
    }
}

extension CameraViewController: AVCapturePhotoCaptureDelegate {

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {

        if let error = error {
            self.photoCaptureCompletionBlock?(nil, error)
        }

        if let imageData = photo.fileDataRepresentation() {
            if let image = UIImage(data: imageData) {
                self.photoCaptureCompletionBlock?(image, nil)
            } else {
                self.photoCaptureCompletionBlock?(nil, CameraControllerError.unknown)
            }
        }
    }
}

// MARK: - Enums
extension CameraViewController {
    enum CameraControllerError: Swift.Error {
        case captureSessionAlreadyRunning
        case captureSessionIsMissing
        case inputsAreInvalid
        case invalidOperation
        case noCamerasAvailable
        case unknown
    }

    public enum CameraPosition {
        case front
        case rear
    }
}
