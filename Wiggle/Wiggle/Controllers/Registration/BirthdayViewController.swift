//
//  BirthdayViewController.swift
//  Wiggle
//
//  Created by Murat Turan on 20.11.2019.
//  Copyright © 2019 Murat Turan. All rights reserved.
//

import UIKit

class BirthdayViewController: UIViewController {

    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var birthdayPickerButton: UIButton!
    @IBOutlet weak var continueButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        prepareViews()
    }
    
    func prepareViews() {
        topLabel.text = Localize.BirthdayPicker.TopLabel
        continueButton.setTitle("Complete", for: .normal)
        let calendar = Calendar(identifier: .gregorian)
        let currentDate = Date()
        var components = DateComponents()
        components.calendar = calendar
        components.year = -18
        let startDate = calendar.date(byAdding: components, to: currentDate)
        birthdayPickerButton.setTitle(startDate?.dateString(), for: .normal)
    }
    
    @IBAction func chooseBirthdayAction(_ sender: UIButton) {
        let calendar = Calendar(identifier: .gregorian)

        let currentDate = Date()
        var components = DateComponents()
        components.calendar = calendar

        components.year = 0
        components.month = 0
        let maxDate = calendar.date(byAdding: components, to: currentDate)!

        components.year = -100
        let minDate = calendar.date(byAdding: components, to: currentDate)!
        
        components.year = -18
        let startDate = calendar.date(byAdding: components, to: currentDate)
        
        let alert = UIAlertController(style: .actionSheet, title: Localize.DatePicker.PickDate)
        
        alert.addDatePicker(mode: .date, date: startDate, minimumDate: minDate, maximumDate: maxDate) { date in
            self.birthdayPickerButton.setTitle(date.dateString(), for: .normal)
        }
        alert.addAction(title: Localize.Common.OKButton, style: .cancel)
        alert.show()
    }
    
    @IBAction func continueAction(_ sender: UIButton) {
        moveToEnableLocationViewController(navigationController: self.navigationController ?? UINavigationController())
    }
    
    @IBAction func backAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}