//
//  PhotoPreviewViewController.swift
//  Solid
//
//  Created by Solid iOS Team on 20/05/20.
//  Copyright © 2021 Solid. All rights reserved.
//

import UIKit
import PDFKit

enum DocumentType: String {
    case image = "image"
    case pdf = "pdf"
}

class PhotoPreviewViewController: BaseVC {

//    var resultImage : UIImage!

    @IBOutlet weak var imageViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!

    var currentUploadingSide: CheckImageSide!

    var image: UIImage!
    var index: Int = 0

    var docType: DocumentType = .image
    var pdfPath: URL?

    var doubleTapGestureRecognizer: UITapGestureRecognizer!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didDoubleTapWith(gestureRecognizer:)))
        self.doubleTapGestureRecognizer.numberOfTapsRequired = 2
    }

    init() {
        super.init(nibName: nil, bundle: nil)
//        self.doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didDoubleTapWith(gestureRecognizer:)))
//        self.doubleTapGestureRecognizer.numberOfTapsRequired = 2

    }

    override func viewDidLoad() {
        super.viewDidLoad()

        addBackNavigationbarButton()

        if let side = currentUploadingSide {
            self.title = (side == .front) ? Utility.localizedString(forKey: "RCD_frontTitle") : Utility.localizedString(forKey: "RCD_backTitle")
        }

        if docType == .image {

            self.doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didDoubleTapWith(gestureRecognizer:)))
            self.doubleTapGestureRecognizer.numberOfTapsRequired = 2

            self.scrollView.isHidden = false

            self.scrollView.delegate = self
            if #available(iOS 11, *) {
                self.scrollView.contentInsetAdjustmentBehavior = .never
            }
            self.imageView.frame = CGRect(x: self.imageView.frame.origin.x,
                                          y: self.imageView.frame.origin.y,
                                          width: self.image.size.width,
                                          height: self.image.size.height)
            self.imageView.image = self.image

            self.view.addGestureRecognizer(self.doubleTapGestureRecognizer)
        } else {

            self.scrollView.isHidden = true
//            self.pdfView.isHidden = true

            let pdfView = PDFView()
            pdfView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(pdfView)

            pdfView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
            pdfView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
            pdfView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
            pdfView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true

            view.sendSubviewToBack(pdfView)
            guard let path = pdfPath else { return }

            if let document = PDFDocument(url: path) {
                pdfView.document = document
            }
        }

    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if docType == .image {
            updateZoomScaleForSize(view.bounds.size)
            updateConstraintsForSize(view.bounds.size)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if docType == .image {
            updateZoomScaleForSize(view.bounds.size)
            updateConstraintsForSize(view.bounds.size)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func closeScreenClicked(_ sender: Any) {
        dismissController()
    }

}

extension PhotoPreviewViewController {

    @objc func didDoubleTapWith(gestureRecognizer: UITapGestureRecognizer) {

        if docType == .image {
            let pointInView = gestureRecognizer.location(in: self.imageView)
            var newZoomScale = self.scrollView.maximumZoomScale

            if self.scrollView.zoomScale >= newZoomScale || abs(self.scrollView.zoomScale - newZoomScale) <= 0.01 {
                newZoomScale = self.scrollView.minimumZoomScale
            }

            let width = self.scrollView.bounds.width / newZoomScale
            let height = self.scrollView.bounds.height / newZoomScale
            let originX = pointInView.x - (width / 2.0)
            let originY = pointInView.y - (height / 2.0)

            let rectToZoomTo = CGRect(x: originX, y: originY, width: width, height: height)
            self.scrollView.zoom(to: rectToZoomTo, animated: true)
        }
    }

    fileprivate func updateZoomScaleForSize(_ size: CGSize) {
       if docType == .image {
        let widthScale = size.width / imageView.bounds.width
        let heightScale = size.height / imageView.bounds.height
        let minScale = min(widthScale, heightScale)
        scrollView.minimumZoomScale = minScale

        scrollView.zoomScale = minScale
        scrollView.maximumZoomScale = minScale * 4
        }
    }

    fileprivate func updateConstraintsForSize(_ size: CGSize) {
        if docType == .image {
            let yOffset = max(0, (size.height - imageView.frame.height) / 2)
            imageViewTopConstraint.constant = yOffset
            imageViewBottomConstraint.constant = yOffset

            let xOffset = max(0, (size.width - imageView.frame.width) / 2)
            imageViewLeadingConstraint.constant = xOffset
            imageViewTrailingConstraint.constant = xOffset

            let contentHeight = yOffset * 2 + self.imageView.frame.height
            view.layoutIfNeeded()
            self.scrollView.contentSize = CGSize(width: self.scrollView.contentSize.width, height: contentHeight)
        }
    }
}

extension PhotoPreviewViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        updateConstraintsForSize(self.view.bounds.size)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        self.delegate?.photoZoomViewController(self, scrollViewDidScroll: scrollView)
    }
}
