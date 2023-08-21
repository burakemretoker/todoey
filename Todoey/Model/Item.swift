//
//  Item.swift
//  Todoey
//
//  Created by Burak Emre Toker on 14.08.2023.
//

import Foundation
import RealmSwift

class Item: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    @objc dynamic var dateCreated: Date?
    
    
    // inverse relationship with Category as parentCategory
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
