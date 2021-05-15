//
//  ManagedObjectType.swift
//  CoreDataDemo1
//
//  Created by Boyce Estes on 5/7/21.
//

import Foundation
import CoreData

/*
 * This is a neat snippet to ensure that we always have a name for the NSManagedObject
 * subclass.
 *
 * It also provides a simple NSFetchRequest for all your requesting needs with this
 * name variable that you must have.
 */

protocol ManagedObjectType: AnyObject {
    
    static var entityName: String { get }
}


extension ManagedObjectType {

    /*
     * implementation call:
     * let fetchRequest: NSFetchRequest<Movie> = Movie.createFetchRequest()
     *
     * This is a waste of time since it requires
     * the same amount of time as the standard
     * way.
     */
//    static public func createFetchRequest<T: NSManagedObject>() -> NSFetchRequest<T> {
//
//        return NSFetchRequest<T>(entityName: entityName)
//    }


    static public func createFetchRequestResult() -> NSFetchRequest<NSFetchRequestResult> {

        return NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
    }
}
