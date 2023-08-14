//
//  data.swift
//  Todoey
//
//  Created by Burak Emre Toker on 14.08.2023.
//

import Foundation
import RealmSwift

class Data: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var age: Int = 0
}
