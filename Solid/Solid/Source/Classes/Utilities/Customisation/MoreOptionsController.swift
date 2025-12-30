//
//  MoreOptionsController.swift
//  Solid
//
//  Created by Solid iOS Team on 24/05/21.
//  Copyright © 2021 Solid. All rights reserved.
//

import UIKit

class MoreOptionsController: UIAlertController {

    private var observation: NSKeyValueObservation?
    private var options = [UIAlertAction: String]()
    private var hideTint = true

    var alpha: CGFloat = 0.5
    var tintView: UIView?

    override func viewDidLoad() {
        super.viewDidLoad()

        setTintView(hideTint)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if UIDevice.current.userInterfaceIdiom == .pad {
            NotificationCenter.default.addObserver(self, selector: #selector(MoreOptionsController.deviceOrientationDidChange),
                                                   name: UIDevice.orientationDidChangeNotification, object: nil)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if UIDevice.current.userInterfaceIdiom == .pad {
            NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
        }
    }

    private func setTintView(_ hidden: Bool) {
        guard let tintView = self.tintView else {
            return
        }

        let currentAlpha = self.alpha
        let duration = hidden ? 0.2 : 0.5
        if !hidden {
            tintView.isHidden = false
            tintView.alpha = 0
        }
        UIView.animate(withDuration: duration, animations: {
            tintView.alpha = hidden ? 0 : currentAlpha
        }, completion: { (_) in
            tintView.isHidden = hidden
        })
    }

    func present(_ presentingViewController: UIViewController, animated flag: Bool, source: UIBarButtonItem?, completion: (() -> Void)? = nil) {
        let userInterfaceIdiom = UIDevice.current.userInterfaceIdiom
        if userInterfaceIdiom == .pad {
            guard let controller = self.popoverPresentationController, let source = source else {
                return
            }

            controller.barButtonItem = source
            hideTint = false
        }

        presentingViewController.present(self, animated: flag, completion: completion)
    }

    func present(from presentingViewController: UIViewController, animated flag: Bool, sourceView: UIView?, completion: (() -> Void)? = nil) {
        let userInterfaceIdiom = UIDevice.current.userInterfaceIdiom
        if userInterfaceIdiom == .pad {
            guard let controller = self.popoverPresentationController, let sourceView = sourceView, let parentView = presentingViewController.view else {
                return
            }

            let rect = sourceView.convert(sourceView.bounds, to: parentView)
            controller.sourceView = parentView
            controller.sourceRect = rect
            hideTint = false
        }

        presentingViewController.present(self, animated: flag, completion: completion)
    }

    @objc private func deviceOrientationDidChange(_ notification: NSNotification) {
        if UIDevice.current.userInterfaceIdiom == .pad {
            self.dismiss(animated: true, completion: nil)
        }
    }
}
