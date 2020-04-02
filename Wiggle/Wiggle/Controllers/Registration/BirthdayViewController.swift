//
//  BirthdayViewController.swift
//  Wiggle
//
//  Created by Murat Turan on 20.11.2019.
//  Copyright © 2019 Murat Turan. All rights reserved.
//

import UIKit
import Parse

class BirthdayViewController: UIViewController {

    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var birthdayPickerButton: UIButton!
    @IBOutlet weak var continueButton: UIButton!
    
    var birthday: Date?
    var registerRequest: RegisterRequest?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareViews()
    }

    func prepareViews() {
        self.view.setGradientBackground()
        
        continueButton.layer.applyShadow(color: UIColor.shadowColor, alpha: 0.48, x: 0, y: 5, blur: 20)
        continueButton.setTitle(Localize.Common.ContinueButton, for: .normal)
        
        topLabel.text = Localize.BirthdayPicker.TopLabel
        
        let calendar = Calendar(identifier: .gregorian)
        let currentDate = Date()
        var components = DateComponents()
        components.calendar = calendar
        components.year = -18
        let startDate = calendar.date(byAdding: components, to: currentDate)
        birthdayPickerButton.setTitle(startDate?.dateString(), for: .normal)
        birthday = startDate        
    }
    
    @IBAction func chooseBirthdayAction(_ sender: UIButton) {
        let calendar = Calendar(identifier: .gregorian)

        let currentDate = Date()
        var components = DateComponents()
        components.calendar = calendar

        components.year = -18
        components.month = 0
        let maxDate = calendar.date(byAdding: components, to: currentDate)!

        components.year = -100
        let minDate = calendar.date(byAdding: components, to: currentDate)!
        
        components.year = -18
        let startDate = calendar.date(byAdding: components, to: currentDate)
        
        let alert = UIAlertController(style: .actionSheet, title: Localize.DatePicker.PickDate)
        
        alert.addDatePicker(mode: .date, date: startDate, minimumDate: minDate, maximumDate: maxDate) { date in
            self.birthday = date.adding(.hour, value: 3)
            self.birthdayPickerButton.setTitle(date.dateString(), for: .normal)
        }
        alert.addAction(title: Localize.Common.OKButton, style: .cancel)
        alert.show()
    }
    
    @IBAction func continueAction(_ sender: UIButton) {
        guard let request = registerRequest else { return }
        if let birthday = birthday {
            request.birthday = birthday
            moveToEnableLocationViewController(request: request)
        }
    }
    
    @IBAction func backAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}
