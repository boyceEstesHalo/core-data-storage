//
//  InsertMethodType.swift
//  CoreDataDemo1
//
//  Created by Boyce Estes on 4/28/21.
//

import Foundation

/*
 For testing performance purposes I want to easily swap between
 different methods of inserting data into Core Data entity.
 */

enum InsertMethodType {
    
    case saveEachRecord
    case saveOnceForAllRecords
    case batchInsert
}
