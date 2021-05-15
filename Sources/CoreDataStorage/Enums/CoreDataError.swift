//
//  CoreDataError.swift
//  CoreDataDemo1
//
//  Created by Boyce Estes on 5/2/21.
//

import Foundation

enum CoreDataError: Error {
    case modelURLNotFound(forResourceName: String)
    case modelLoadingFailed(forURL: URL)
}

