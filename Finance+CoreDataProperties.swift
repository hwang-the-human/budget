//
//  Finance+CoreDataProperties.swift
//  Budget
//
//  Created by Nicholas HwanG on 11/20/19.
//  Copyright © 2019 Hwang. All rights reserved.
//
//

import Foundation
import CoreData


extension Finance {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Finance> {
        return NSFetchRequest<Finance>(entityName: "Finance")
    }

    @NSManaged public var amount: Double
    @NSManaged public var date: Date?
    @NSManaged public var icon: String
    @NSManaged public var note: String?
    @NSManaged public var type: String
    @NSManaged public var color: String
    
    var wrappedAmount: Double {
        amount
    }
    var wrappedDate: Date {
        date!
    }
    var wrappedIcon: String {
        icon
    }
    var wrappedNote: String {
        note!
    }
    var wrappedType: String {
        type
    }
    var wrappedColor: String {
        color
    }

}
