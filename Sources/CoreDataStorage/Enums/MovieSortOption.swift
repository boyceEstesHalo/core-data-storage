//
//  MovieSortOption.swift
//  CoreDataDemo1
//
//  Created by Boyce Estes on 5/9/21.
//

import Foundation

enum MovieSortOption: Int {

    case popularity
    case releaseDate
    case title

    func display() -> String{
        
        switch self {
        case .popularity:
            return "Popularity"
        case .releaseDate:
            return "Release Date"
        case .title:
            return "Title"
        }
    }
}
