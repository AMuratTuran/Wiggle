//
//  InputAccessoryView.swift
//  Mizu
//
//  Created by Deniz Adalar on 17/03/16.
//  Copyright © 2016 Mizu. All rights reserved.
//

import UIKit

class InputAccessoryView: UIToolbar {

    // MARK: - Internal Variables
    var field: UIView?
    var nextButton: UIBarButtonItem!
    var previousButton: UIBarButtonItem!
    var containerView: UIView? = nil

    var resignFunc: (() -> Void)?

    @objc func resign() {
        resignFunc?()
    }

    var clearFunc: (() -> Void)?

    @objc func clear() {
        clearFunc?()
    }

    var nextInput: UIView? {
        return field?.nextIterableView(inView: containerView ?? field?.window) as? UIView
    }

    @objc func goToNextInput() {
        nextInput?.becomeFirstResponder()
    }

    var prevInput: UIView? {
        return field?.prevIterableView(inView: containerView ?? field?.window) as? UIView
    }

    // MARK: - Internal Functions
    @objc func goToPrevInput() {
        prevInput?.becomeFirstResponder()
    }

    // MARK: - Initial Functions
    init(field: UIView?, isShowNextBackButtons: Bool = true, isShowClearButton: Bool = false, resignFunc: (() -> Void)?, clearFunc: (() -> Void)? = nil) {
        self.field = field
        super.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44))

        self.resignFunc = resignFunc
        self.clearFunc = clearFunc

        self.barStyle = .default

        if isShowNextBackButtons {
            self.nextButton = UIBarButtonItem(image: UIImage(named: "more-than"), style: .plain, target: self, action: #selector(goToNextInput))

            self.previousButton = UIBarButtonItem(image: UIImage(named: "less-than"), style: .plain, target: self, action: #selector(goToPrevInput))
        } 

        let spacingItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(resign))

        let clearItem = UIBarButtonItem(title: Localize.Common.Clear, style: .done, target: self, action: #selector(clear))

        if isShowNextBackButtons {
            self.items = [previousButton, nextButton, spacingItem, doneItem]
        } else if isShowClearButton {
            self.items = [clearItem, spacingItem, doneItem]
        } else {
            self.items = [spacingItem, doneItem]
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        field = nil
        nextInput?.accessibilityIdentifier = "next-accessory-view"
        prevInput?.accessibilityIdentifier = "prev-accessory-view"
    }

    // MARK: - Override Functions
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        nextButton?.isEnabled = (nextInput != nil)
        previousButton?.isEnabled = (prevInput != nil)
    }

}
