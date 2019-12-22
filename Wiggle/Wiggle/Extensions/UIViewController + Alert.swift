//
//  UIViewController + Alert.swift
//  Wiggle
//
//  Created by Murat Turan on 21.12.2019.
//  Copyright © 2019 Murat Turan. All rights reserved.
//

import UIKit
import PopupDialog

extension UIViewController {
    func alertMessage(title: String = AppConstants.General.ApplicationName, message: String, buttons: [PopupDialogButton], image: UIImage? = nil,
                      buttonAlignment: NSLayoutConstraint.Axis = .horizontal, isErrorMessage: Bool, isGestureDismissal: Bool = true,
                      alertCompletion: (() -> Void)? = nil, presentCompletion: (() -> Void)? = nil) {

        let transitionStyle: PopupDialogTransitionStyle = isErrorMessage ? .bounceUp : .zoomIn

        let popup = PopupDialog(title: title, message: message, image: image, buttonAlignment: buttonAlignment, transitionStyle: transitionStyle, tapGestureDismissal: isGestureDismissal, panGestureDismissal: isGestureDismissal) {
            alertCompletion?()
        }

        buttons.forEach {
            $0.titleFont = FontHelper.regular(14)
            
        }
        popup.addButtons(buttons)

        let overlayAppearance = PopupDialogOverlayView.appearance()
        overlayAppearance.blurEnabled = false
        let containerAppearance = PopupDialogContainerView.appearance()
        containerAppearance.cornerRadius = 12
        let dialogAppearance = PopupDialogDefaultView.appearance()

        dialogAppearance.messageFont = FontHelper.regular(14)
        dialogAppearance.messageTextAlignment = .center

        self.present(popup, animated: true, completion: {
            presentCompletion?()
        })
    }
}
