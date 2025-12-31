//
//  BaseAnimationView.swift
//  Solid
//
//  Created by Solid iOS Team on 28/04/21.
//

import Foundation
import UIKit
import Lottie

public class BaseAnimationView: UIView {
    
    var animationFile = "welcome" {
        didSet {
            playAnimation()
        }
    }
    
    func playAnimation() {
        let animation = Animation.named(animationFile, subdirectory: "")
        let animationView = AnimationView(animation: animation)
        animationView.backgroundBehavior = .pauseAndRestore
		animationView.loopMode = .loop
        animationView.tag = 3000
        if let existingView = self.viewWithTag(3000) {
            existingView.removeFromSuperview()
        }
        self.addSubview(animationView)
        animationView.frame = self.bounds
        self.backgroundColor = .clear
        animationView.play()
    }
}
