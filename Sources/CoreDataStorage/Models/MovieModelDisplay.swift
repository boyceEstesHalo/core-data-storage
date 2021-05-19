//
//  MovieModelDisplay.swift
//  CoreDataDemo1
//
//  Created by Boyce Estes on 5/18/21.
//

import Foundation

/*
 * This would be whatever Movie data that we want to display to the view.
 * Ideally we would not need to mess around with any optional stuff.
 * For ex:
 * Release Date could not exist - in that case, I don't want to deal with that
 * information in my View. Instead, I would like to do that in my view-model and
 * deliver a nice and easy package of displayable strings to my View.

 */

public struct MovieModelDisplay {

    public let releaseDate: String
    public let popularity: String
    public let title: String

    public init(movie: Movie) {

        if let releaseDate = movie.releaseDate {
            let formatter = DateFormatter.yyyyMMdd
            self.releaseDate = formatter.string(from: releaseDate)
        } else {
            self.releaseDate = "TBD"
        }

        self.popularity = String(movie.popularity)
        self.title = movie.title
    }
}
