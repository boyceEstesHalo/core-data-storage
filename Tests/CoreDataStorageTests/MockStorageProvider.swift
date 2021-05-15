//
//  MockStorageProvider.swift
//  CoreDataDemo1Tests
//
//  Created by Boyce Estes on 5/1/21.
//

import Foundation
import CoreData
@testable import CoreDataStorage


/*
 * This could be ideal because we would only be loading this code in the Test
 * target. Keeping the main target as clean as possible would be great.
 *
 * HOWEVER, it would be nice to still keep some sort of mock interface in the
 * main target for the preview information.
 *
 * The downside is that we would want to make sure we are only using one model.
 * This might make it a little more difficult unless... we just reference the
 * superclass's static variable.
 */

class MockStorageProvider: StorageProvider3 {

    override init() {
        super.init()

        var container: NSPersistentContainer
        do {
            let name = StorageProvider3.modelName
            container = NSPersistentContainer(name: name, managedObjectModel: try StorageProvider3.model(name: name))
        } catch {
            fatalError("Failed to load model with error: \(error)")
        }
//        let container = NSPersistentContainer(name: name, managedObjectModel: StorageProvider.model(name: StorageProvider.modelName))

        // special file location, "Null Device" This is how you make the persistent
        // Container in-memory stored instead of disk. Once the test ends, this is wiped
        container.persistentStoreDescriptions[0].url =
          URL(fileURLWithPath: "/dev/null")

        container.loadPersistentStores { _, error in
            if let error = error as NSError? { fatalError("Failed to load store: \(error), \(error.userInfo)") }
        }

        self.persistentContainer = container
    }
}
