//
//  MovieModel.swift
//  CoreDataDemo1
//
//  Created by Boyce Estes on 5/9/21.
//

import Foundation

/*
 * When objects need to be inserted into Core Data and they get a little complicated,
 * we could deal with this by creating a Dictionary, or we could simply create a
 * custom model object.

 * This will make passing around Movie information much easier, and will be even more useful
 * if we are actually making network calls.
 */

// Include Decodable/Encodable(or Codable) if necessary
public struct MovieModel: Decodable {

    let title: String
    let overview: String?
    let popularity: Double
    let releaseDate: Date?


    enum CodingKeys: String, CodingKey {
        case title
        case overview
        case popularity
        case releaseDate = "release_date"
    }


    // Had to make decoding manual because Date needed to be taken from a string to the correct date.
    // smh.
    public init(from decoder: Decoder) throws {

        let container = try decoder.container(keyedBy: CodingKeys.self)

        title = try container.decode(String.self, forKey: .title)
        overview = try container.decode(String.self, forKey: .overview)
        popularity = try container.decode(Double.self, forKey: .popularity)

        let releaseDateString = try container.decodeIfPresent(String.self, forKey: .releaseDate)
        let formatter = DateFormatter.yyyyMMdd

        if let releaseDateString = releaseDateString {

            guard let date = formatter.date(from: releaseDateString) else {

                throw DecodingError.dataCorruptedError(forKey: .releaseDate, in: container, debugDescription: "Date string does not match expected")
            }

            releaseDate = date
        } else {
            releaseDate = nil
        }
    }
}


struct MovieModelResponse: Decodable {

    let results: [MovieModel]
}
