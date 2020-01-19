//
//  TextFieldView.swift
//  Coor
//
//  Created by Cüneyt Faikoğlu on 24.12.2019.
//  Copyright © 2019 CicekSepeti. All rights reserved.
//

import UIKit
import SwiftValidator

@objc
protocol TextFieldViewDelegate: class {
    func textFieldShouldReturn(_ textFieldView: TextFieldView)
    @objc optional func textFieldDidEndEditing(_ textFieldView: TextFieldView)
    @objc optional func textFieldDidWillChangeTo(_ textFieldView: TextFieldView, text: String, replacementString: String, isAddedChar: Bool)
    @objc optional func shouldChangeCharactersInRange(_ textFieldView: TextFieldView, range: NSRange, replacementString: String) -> Bool
    @objc optional func textFieldDidChange(_ textFieldView: TextFieldView)
    @objc optional func textFieldShouldBeginEditing(_ textFieldView: TextFieldView)
    @objc optional func textFieldDidBeginEditing(_ textFieldView: TextFieldView)
}

class TextFieldView: UIView {
    // MARK: Outlets
    @IBOutlet fileprivate weak var textField: UITextField!
    @IBOutlet fileprivate weak var titleLabel: UILabel!
    @IBOutlet fileprivate weak var lineView: UIView!
    @IBOutlet weak var errorLabel: UILabel?
    
    class func load(delegate: TextFieldViewDelegate? = nil, title: String, placeholder: String?, maxChars: Int = 800, isDigit: Bool = false, keyboardType: UIKeyboardType? = nil, isSecureText: Bool = false) -> TextFieldView {
        guard let view = UINib(nibName: "TextFieldView", bundle: nil).instantiate(withOwner: nil, options: nil).first as? TextFieldView else {
            return TextFieldView()
        }
        
        view.prepareTextFieldView(delegate: delegate, title: title, placeholder: placeholder, maxChars: maxChars, isDigit: isDigit, keyboardType: keyboardType, isSecureText: isSecureText)
        
        return view
    }

    // MARK: Internal Variables
    weak var delegate: TextFieldViewDelegate?
    var validator = Validator()
    var maxCharacters: Int = 800
    var containerView: UIView? = nil
    var isDigit: Bool = false
    var isActiveTextView: Bool = true {
        didSet {
            if let textField = self.textField {
                textField.isUserInteractionEnabled = isActiveTextView
                textField.alpha = isActiveTextView ? 1 : 0.5
                prepareError(!isError)
            }
        }
    }

    override var isHidden: Bool {
        didSet {
            isActiveTextView = !isHidden
        }
    }

    var isError: Bool = false {
        didSet {
            prepareError(!isError)
        }
    }

    var text: String? {
        set {
            self.isError = false
            textField.text = newValue ?? ""
        }
        get {
            return textField.text
        }
    }
    
    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }

    var placeholder: String? {
        didSet {
            textField.placeholder = placeholder
        }
    }
    
    var returnKeyType: UIReturnKeyType = .next {
        didSet {
            self.textField.returnKeyType = returnKeyType
        }
    }

    var textFieldSuperView: UIView? {
        didSet {
            inView = textFieldSuperView
        }
    }
    
    var isBecomeFirstResponder: Bool = false {
        didSet {
            if isBecomeFirstResponder {
                textField.becomeFirstResponder()
            }
        }
    }
    
    var font: UIFont?

    fileprivate var inView: UIView? {
        get {
            if textFieldSuperView == nil {
                return superview
            }
            return textFieldSuperView
        }

        set { }
    }

    // MARK: Override Function
    override func awakeFromNib() {
        super.awakeFromNib()
        errorLabel?.text = ""
        errorLabel?.errorStyle()
        
        
        textField.delegate = self
        textField.addInputAccessoryView()
        textField.addTarget(self, action: #selector(TextFieldView.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        textField.font = FontHelper.medium(15)
        
        titleLabel.font = FontHelper.medium(13)
    }

    // MARK: Internal Function
    func prepareTextFieldView(delegate: TextFieldViewDelegate? = nil, title: String, placeholder: String?, maxChars: Int = 800, isDigit: Bool = false, keyboardType: UIKeyboardType? = nil, isSecureText: Bool = false) {
        self.delegate = delegate
        self.maxCharacters = maxChars
        self.isDigit = isDigit
        self.placeholder = placeholder
        self.title = title
        self.textField.keyboardType = keyboardType ?? .default
        self.textField.isSecureTextEntry = isSecureText
    }
    
    func prepareValidation(validator: Validator, validationRules: [Rule]) {
        addValidation(validator: validator, validationRules: validationRules)
    }
    
    func addValidation(validator: Validator, validationRules: [Rule]) {
        self.validator = validator
        textField.addValidationRules(validationRules, errorLabel: errorLabel, validator: validator)
    }

    func removeValidation(_ validator: Validator) {
        self.validator = validator
        textField.removeValidationRules(validator: validator)
    }

    func becomeResponder() {
        textField.becomeFirstResponder()
    }

    fileprivate func prepareError(_ isHidden: Bool) {
        if isHidden { errorLabel?.text = "" }
        if #available(iOS 13.0, *) {
            lineView.backgroundColor = isHidden ? UIColor.separator : UIColor.red
        } else {
            lineView.backgroundColor = isHidden ? UIColor.lightGray : UIColor.red
        }
    }

    func getTextField() -> UITextField {
        return textField
    }

    @objc func textFieldDidChange(_ textFieldView: TextFieldView) {
        delegate?.textFieldDidChange?(self)
    }
}

// MARK: - UITextFieldDelegate
extension TextFieldView: UITextFieldDelegate {

    func textFieldDidBeginEditing(_ textField: UITextField) {
        isError = false
        delegate?.textFieldDidBeginEditing?(self)
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        validator.validateField(textField) { error in
            self.isError = error != nil ? true : false
        }

        if !isError {
            self.delegate?.textFieldDidEndEditing?(self)
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if isError {
            isError = false
        }

        if isDigit && string == UIPasteboard.general.string {

            var digitString: String {
                return string.components(separatedBy: CharacterSet.decimalDigits.inverted).joined(separator: "")
            }

            self.text = digitString
            _ = self.textField(self.textField, shouldChangeCharactersIn: NSRange(location: 0, length: digitString.count), replacementString: digitString)

            return false
        }

        let isDelegeteChangeCharacter = delegate?.shouldChangeCharactersInRange?(self, range: range, replacementString: string) ?? true

        guard let text = textField.text else { return true && isDelegeteChangeCharacter }
        let newLength = text.count + string.count - range.length
        var isChange = (newLength <= self.maxCharacters) && isDelegeteChangeCharacter
        if string.isEmpty {
            isChange = true
        }
        if isChange {
            self.delegate?.textFieldDidWillChangeTo?(self, text: text + string, replacementString: string, isAddedChar: range.length == 0)
        }

        return isChange
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        validator.validateField(textField) { error in
            self.isError = error != nil ? true : false
        }
        if !isError {
            self.delegate?.textFieldShouldBeginEditing?(self)
        }
        return true
    }
}
