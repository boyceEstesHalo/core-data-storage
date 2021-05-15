//
//  MovieProvider.swift
//  CoreDataDemo1
//
//  Created by Boyce Estes on 4/28/21.
//

import Foundation
import CoreData
import Combine

/*
 * This holds all logic responsible for the NSFetchedResultsController.
 * Whenever we break it into its own class like this we can separate the
 * Core Data logic from the rest of the business logic in the view-model.
 *
 * It makes for a cleaner view-model and allows for us to move class with
 * the rest of the Core Data classes.
 */
class MovieProvider: NSObject {

    // MARK: - Properties
    private var fetchedResultsController: NSFetchedResultsController<Movie>
    private var storageProvider: StorageProvider3

    let moviePassthroughSubject = PassthroughSubject<MovieProvider, Never>()
    
    var numberOfSections: Int {
        return fetchedResultsController.sections?.count ?? 0
    }

    var movieSortOrder: MovieSortOption


    // MARK: - Lifecycle
    init(storageProvider: StorageProvider3) {

        self.storageProvider = storageProvider

//        guard let movieSortOrder = MovieSortOption(rawValue: storageProvider.fetchCurrentMovieSortOption()) else { return }
        movieSortOrder = storageProvider.fetchCurrentMovieSortOption()
        let fetchRequest = Movie.createFetchRequest(sortBy: movieSortOrder)

        self.fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: storageProvider.mainContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )

        super.init()

        fetchedResultsController.delegate = self
        try! fetchedResultsController.performFetch()
        moviePassthroughSubject.send(self)
    }


    // MARK: - Methods
    func createFetchedResultsController(sortBy sortOption: MovieSortOption) {

        movieSortOrder = sortOption // update the new selection
        storageProvider.setCurrentMovieSortOption(to: movieSortOrder)
        let fetchRequest = Movie.createFetchRequest(sortBy: sortOption)

        self.fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: storageProvider.mainContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )

        fetchedResultsController.delegate = self
        try! fetchedResultsController.performFetch()
        moviePassthroughSubject.send(self)
    }


    func numberOfItemsInSection(_ section: Int) -> Int {
        
        guard let sections = fetchedResultsController.sections,
              sections.endIndex > section else {
            return 0
        }
        
        return sections[section].numberOfObjects
    }
    
    
    func object(at indexPath: IndexPath) -> Movie {
        
        return fetchedResultsController.object(at: indexPath)
    }
}


// MARK: - Fetched Results Controller Delegate
extension MovieProvider: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {

        moviePassthroughSubject.send(self)
    }
}
