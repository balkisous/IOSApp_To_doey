//
//  Item.swift
//  Todoey
//
//  Created by Wangie on 13/02/2024.
//  Copyright © 2024 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift
import SwipeCellKit


class Item: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    @objc dynamic var dateCreated: Date?
    @objc dynamic var color: String = ""
    let parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
