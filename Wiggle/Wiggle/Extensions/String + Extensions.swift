//
//  String + Extensions.swift
//  Wiggle
//
//  Created by Murat Turan on 19.12.2019.
//  Copyright © 2019 Murat Turan. All rights reserved.
//

import Foundation

extension String {
    func dateFromStringWithFormat(_ dateFormat: String) -> Date? {
        let formatter: DateFormatter = DateFormatter()
        formatter.dateFormat = dateFormat
        return formatter.date(from: self)
    }
}
