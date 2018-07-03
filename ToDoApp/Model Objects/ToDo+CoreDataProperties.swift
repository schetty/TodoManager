//
//  ToDo+CoreDataProperties.swift
//  ToDoApp
//
//  Created by Naomi Schettini on 7/3/18.
//  Copyright © 2018 Naomi Schettini. All rights reserved.
//
//

import Foundation
import CoreData


extension ToDo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ToDo> {
        return NSFetchRequest<ToDo>(entityName: "ToDo")
    }

    @NSManaged public var dateToAccomplishTodoBy: String?
    @NSManaged public var detail: String?
    @NSManaged public var priority: Int32
    @NSManaged public var title: String?

}
