//
//  RCDViewModel.swift
//  Solid
//
//  Created by Solid iOS Team on 20/05/20.
//  Copyright © 2021 Solid. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage

class RCDViewModel: BaseViewModel {

	private var rcdModel: RCModel
	public init(rcdModel: RCModel) {
		self.rcdModel = rcdModel
	}

    public var amount: Double?

	public var screenTitleString: String {
		return Utility.localizedString(forKey: "RCD_captureScreen_navTitle")
	}

	public var amountString: String {

		if let strAmount = self.amount {
			return Utility.getCurrencyForAmount(amount: NSNumber(value: strAmount), isDecimalRequired: true, withoutSpace: true)
		}

		return ""
	}

	public var isFrontImageAvailable: Bool {
		return rcdModel.checkFrontImage != nil
	}

	public var isRearImageAvailable: Bool {
		return rcdModel.checkRearImage != nil
	}

	public var checkFrontImage: UIImage {
		return rcdModel.checkFrontImage!
	}

	public var checkRearImage: UIImage {
		return rcdModel.checkRearImage!
	}

	private var aFrontImageAction: CaptureActions?
	public var frontImageAction: CaptureActions? {
		get { return aFrontImageAction }
		set {
            aFrontImageAction = newValue
		}
	}

	private var aRearImageAction: CaptureActions?
	public var rearImageAction: CaptureActions? {
		get { return aRearImageAction }
		set {
            aRearImageAction = newValue
		}
	}

	func resetCheckData(for checkSide: CheckImageSide) {

		if checkSide == .front {
			rcdModel.checkFrontImage = nil
		} else {
			rcdModel.checkRearImage = nil
		}
		self.frontImageAction = .retake
		self.rearImageAction = .retake
	}

	func setDocumentImage(image: UIImage, for checkSide: CheckImageSide) {
		if checkSide == .front {
			rcdModel.checkFrontImage = image
		} else {
			rcdModel.checkRearImage = image
		}
	}

    func getImageFor(fileUrl: URL) -> UIImage? {
        if fileUrl.pathExtension.lowercased() == "pdf" {
            guard let document = CGPDFDocument(fileUrl as CFURL) else { return nil }
            guard let page = document.page(at: 1) else { return nil }

            let pageRect = page.getBoxRect(.mediaBox)
            let renderer = UIGraphicsImageRenderer(size: pageRect.size)
            let img = renderer.image { ctx in
                UIColor.white.set()
                ctx.fill(pageRect)

                ctx.cgContext.translateBy(x: 0.0, y: pageRect.size.height)
                ctx.cgContext.scaleBy(x: 1.0, y: -1.0)

                ctx.cgContext.drawPDFPage(page)
            }
            return img
        } else {
            do {
                let imageData = try Data(contentsOf: fileUrl)
                let convertedImage = UIImage(data: imageData)
                return convertedImage
            } catch {
                return nil
            }
        }
    }
    
	func setImageActionHappen(action: CaptureActions) {
		self.frontImageAction = action
		self.rearImageAction = action
	}
}

class RCDCheckViewModel: BaseViewModel {
	static let shared = RCDCheckViewModel()
	let apiManager = APIManager.shared()
}

// MARK: - Categories
extension RCDCheckViewModel {
	func postReceiveCheck(checkData: ReceiveCheckRequestBody, _ completion: @escaping(_ response: ReceiveCheckResponseBody?, _ errorMessage: AlertMessage?) -> Void) {
		self.decode(modelType: checkData)
		self.apiManager.call(type: EndpointItem.receiveCheck as EndPointType, params: postParams) { (response, errorMessage) in
			completion(response, errorMessage)
		}
	}

	// func uploadFile(type: EndPointType,filename:String,frontImage:UIImage,backImage: UIImage,					
	func uploadImage(checkData: UploadCheckModel, transferId: String, _ completion: @escaping(_ isSuccess: ReceiveCheckResponseBody?, _ errorMessage: AlertMessage?) -> Void) {
		self.apiManager.uploadFile(type: EndpointItem.receiveCheckFiles(transferId), filename: "front", frontImage: checkData.checkFrontImage!, bfilename: "back", backImage: checkData.checkRearImage!) { (response, errorMessage) in
			completion(response, errorMessage)
		}
	}

    func getAllReceiveCheck(accountId: String, _ completion: @escaping(_ response: ReceiveCheckListResponseBody?, _ errorMessage: AlertMessage?) -> Void) {
        self.apiManager.call(type: EndpointItem.listAllChecks(accountId) as EndPointType, params: nil) { (response, errorMessage) in
            completion(response, errorMessage)
        }
    }
}
