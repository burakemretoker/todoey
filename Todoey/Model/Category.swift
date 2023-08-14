//
//  Category.swift
//  Todoey
//
//  Created by Burak Emre Toker on 14.08.2023.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    // forward relationship with Item
    let items = List<Item>()
}
