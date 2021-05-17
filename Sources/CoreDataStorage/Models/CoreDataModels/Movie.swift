//
//  Movie.swift
//  CoreDataDemo1
//
//  Created by Boyce Estes on 4/26/21.
//

import Foundation
import CoreData


public class Movie: NSManagedObject, ManagedObjectType {

    // MARK: Properties
    public static var entityName: String = "Movie"

    // Attributes
    @NSManaged public var title: String
    @NSManaged public var overview: String?
    @NSManaged public var popularity: Double
    @NSManaged public var releaseDate: Date?
    
    
    // MARK: Methods
    /*
     * This is a good method that you can have if you don't want to have typing
     */
    public static func createFetchRequest() -> NSFetchRequest<Movie> {

        return NSFetchRequest<Movie>(entityName: Movie.entityName)
    }


    public static func createFetchRequest(sortBy movieSortOption: MovieSortOption) -> NSFetchRequest<Movie> {

        let fetchRequest = Movie.createFetchRequest()

        switch movieSortOption {
        case .popularity:
            fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Movie.popularity, ascending: false)]
        case .releaseDate:
            fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Movie.releaseDate, ascending: false)]
        case .title:
            fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Movie.title, ascending: true)]
        }

        return fetchRequest
    }


    public static func fetchAll(in context: NSManagedObjectContext, sortKeyPath: KeyPath<Any, Any>) -> [String] {

        let fetchRequest = Movie.createFetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: sortKeyPath, ascending: true)]
        
        do {
            let movies = try context.fetch(fetchRequest)
            return movies.map(\.title)
            
        } catch {
            assertionFailure("Failed to fetch request with error: \(error)")
            return []
        }
    }


    public static func newBatchInsertRequest(with movieData: [MovieModel]) -> NSBatchInsertRequest {

        var index = 0
        let total = movieData.count

        // This is a recursive method. Return false until you want it to end.
        let batchInsert = NSBatchInsertRequest(entity: Movie.entity(), managedObjectHandler: { managedObject -> Bool in

            // Only finish the loop whenever we are at or above our total data
            guard index < total else { return true }

            if let movie = managedObject as? Movie {
                let movieInfo = movieData[index]
                movie.overview = movieInfo.overview
                movie.popularity = movieInfo.popularity
                movie.releaseDate = movieInfo.releaseDate
                movie.title = movieInfo.title
            } 

            index += 1
            return false
        })

        return batchInsert
    }
}
