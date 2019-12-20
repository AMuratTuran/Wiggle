//
//  Match.swift
//  Wiggle
//
//  Created by Murat Turan on 15.12.2019.
//  Copyright © 2019 Murat Turan. All rights reserved.
//

import Foundation
import Parse

class Match: PFObject {
    @NSManaged var id: String
    @NSManaged var sender: String
    @NSManaged var receiver: String
    @NSManaged var superLike: Bool
}

extension Match: PFSubclassing {
    static func parseClassName() -> String {
        return "Friends"
    }
}

