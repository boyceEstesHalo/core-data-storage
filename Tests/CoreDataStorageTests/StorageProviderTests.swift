//
//  StorageProviderTests.swift
//  CoreDataDemo1Tests
//
//  Created by Boyce Estes on 4/28/21.
//

import XCTest
@testable import CoreDataStorage

class StorageProviderTests: XCTestCase {
    
    // 0.024 sec
    func test_parseAndSave_saveEachRecord_slow() {

        // This is an example of a performance test case.
        let storageProvider = MockStorageProvider()
        
        self.measure {
            // Put the code you want to measure the time of here.
            storageProvider.parseMovieDataFromJSON(with: .saveEachRecord)
        }
    }


    // 0.008 sec
    func test_parseAndSave_saveOnceForAllRecords_fast() {

        let storageProvider = MockStorageProvider()

        self.measure {
            // Put the code you want to measure the time of here.
            storageProvider.parseMovieDataFromJSON(with: .saveOnceForAllRecords)
        }
    }


    /*
     * 0.007 sec
     */
    func test_parseAndSave_batchInsert_fastest() {

        let storageProvider = MockStorageProvider()

        self.measure {

            storageProvider.parseMovieDataFromJSON(with: .batchInsert)
        }
    }
}
