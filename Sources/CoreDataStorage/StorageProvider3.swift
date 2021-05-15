//
//  StorageProvdier.swift
//  CoreDataDemo1
//
//  Created by Boyce Estes on 4/26/21.
//

import Foundation
import CoreData


public class StorageProvider3 {

    // MARK: - Properties
    public static let modelName = "CoreDataModel1"
    // There should only be one model object ever loaded in - This is to prevent
    // ambiguous Entity errors when creating MockCoreDataStacks
    static var model: NSManagedObjectModel?

    lazy public var persistentContainer: NSPersistentContainer = {
        // Load Core Data Persistent Container
        var container: NSPersistentContainer
        let name = StorageProvider3.modelName
        do {
            container = NSPersistentContainer(name: name, managedObjectModel: try StorageProvider3.model(name: name))
        } catch {
            fatalError("Failed to load model with error: \(error)")
        }

        container.loadPersistentStores { _, error in

            if let error = error {
                fatalError("Core Data store failed to load with error: \(error)")
            }
        }

        return container
    }()


    // Main Context
    var mainContext: NSManagedObjectContext {

        return persistentContainer.viewContext
    }


    // MARK: - Lifecycle
    init() {

        // Print directory when initializing the CoreDataStack so we can open the persistent store manually
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        print(paths[0])
    }


    // MARK: - Static Methods
    // Method to maintain exactly one model
    static func model(name: String) throws -> NSManagedObjectModel {

        if model == nil {
            model = try loadModel(name: name, bundle: Bundle.module)
        }
        return model!
    }


    static func loadModel(name: String, bundle: Bundle) throws -> NSManagedObjectModel {

        let name = StorageProvider3.modelName
        guard let modelURL = bundle.url(forResource: name, withExtension: "momd") else {
            throw CoreDataError.modelURLNotFound(forResourceName: name)
        }

        guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
            throw CoreDataError.modelLoadingFailed(forURL: modelURL)
        }

        return model
    }


    // MARK: - Instance Methods
    // TODO: Test this by using batch method, then test using a normal save method on each value,
    // then test using inserting each and then saving once at the end
    // First step
    func parseMovieDataFromJSON(with insertMethod: InsertMethodType) {

        print("parse...")
        var movieData = [String]()
        guard let path = Bundle.module.url(forResource: "Movies5Pages", withExtension: "json") else {
            assertionFailure("Could not get seed data.")
            return
        }

        do {
            let data = try Data(contentsOf: path, options: .mappedIfSafe)

            let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)

            if let jsonResult = jsonResult as? [String: Any],
               let movies = jsonResult["results"] as? [Any] {

                for movie in movies {
                    if let movie = movie as? [String: Any] {

                        let movieName = movie["title"] as! String
                        movieData.append(movieName)
                    }
                }
            } else {
                fatalError("Couldn't parse 'Movies.json'")
            }
        } catch {
            // handle error
            print("failed to parse movie with error: \(error)")
        }

        switch insertMethod {

        case .saveEachRecord:
            insertMovieSaveEachRecord(movieData)

        case .saveOnceForAllRecords:
            insertMovieSaveOnce(movieData)

        case .batchInsert:
            batchInsertData(movieData, for: Movie.entity())
        }
    }


    func parseMovieDataFromJSONIntoMovie(with insertMethod: InsertMethodType) {
        var movieData = [MovieModel]()
        guard let path = Bundle.main.path(forResource: "Movies5Pages", ofType: "json") else {
            assertionFailure("Could not get seed data.")
            return
        }

        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let jsonData = try decoder.decode(MovieModelResponse.self, from: data)

            movieData = jsonData.results
        } catch {
            // handle error
            print("failed to parse movie with error: \(error)")
        }

        switch insertMethod {

        case .saveEachRecord:
            print("Out of order for now.")
//            insertMovieSaveEachRecord(movieData)

        case .saveOnceForAllRecords:
            print("Out of order for now.")
//            insertMovieSaveOnce(movieData)

        case .batchInsert:
            batchInsertData(movieData, for: Movie.entity())
        }
    }


    // Generic batch insert for whatever array of objects.
    public func batchInsertData<T>(_ insertData: [T], for entityDescription: NSEntityDescription) {

        print("insert batch data")

        guard !insertData.isEmpty,
              let entityName = entityDescription.name else { return }

        var batchInsertRequest: NSBatchInsertRequest?

        switch entityName {
        case Movie.entityName:
            guard let movieData = insertData as? [MovieModel] else { return }
            batchInsertRequest = Movie.newBatchInsertRequest(with: movieData)

        default:
            return
        }

        guard let batchInsertRequest = batchInsertRequest else { return }

        batchInsertRequest.resultType = .objectIDs
        do {
            let result = try mainContext.execute(batchInsertRequest) as? NSBatchInsertResult
            let insertedObjectIDs = result?.result as? [NSManagedObjectID]

            // Create dictionary to hold all managed objects that were inserted in persistent store
            let changes: [AnyHashable: Any] = [NSInsertedObjectIDsKey: insertedObjectIDs ?? []]

            // merge changes to all contexts that might have managed objects in memory
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [mainContext])
        } catch {
            assertionFailure("Failed to batch insert movie data with error: \(error)")
        }
    }


    private func insertMovieSaveEachRecord(_ movieData: [String]) {

        for movieName in movieData {
            let movieRecord = Movie(context: mainContext)
            movieRecord.title = movieName
            save()
        }
    }


    private func insertMovieSaveOnce(_ movieData: [String]) {

        print("insert save each record:")

        for movieName in movieData {
            print("insert movieName: \(movieName)")
            let movieRecord = Movie(context: mainContext)
            movieRecord.title = movieName
        }

        save()
    }


    func save(backgroundContext: NSManagedObjectContext? = nil) {
        let context = backgroundContext ?? mainContext
        guard context.hasChanges else { return }

        do {
            try context.save()
        } catch let error as NSError {
            print("Failed to save with error: \(error), \(error.userInfo)")
            context.rollback()
        }
    }


    public func deleteObjectsById() {

        // Do not include property values - full managed object
        // Alternative could be to declare as NSFetchRequest<NSManagedObjectID> and then set request.resultType = .managedObjectIDResultType

        let fetchRequest = Movie.createFetchRequest()
        fetchRequest.includesPropertyValues = false

        do {
            let movies = try mainContext.fetch(fetchRequest)

            for movie in movies {
                mainContext.delete(movie)
            }

            save()
        } catch {
            assertionFailure("CoreData failed to delete with error: \(error)")
        }
    }


    public func deleteObjectsMoviesWithPropertyValues() {

        let fetchRequest = Movie.createFetchRequest()

        do {
            let movies = try mainContext.fetch(fetchRequest)

            for movie in movies {
                mainContext.delete(movie)
            }

            save()
        } catch {
            assertionFailure("CoreData failed to delete with error: \(error)")
        }
    }


    /*
     * Deletion rules are not respected by batch deletes. Your entity relationships will need to be
     * deleted manually.
     *
     * Must manually update your in-memory entites. You can use mergeChanges on managed object context
     * to do this.
     */
    public func batchDelete() {

        print("batch delete")

        // Create fetch request
        let fetchRequest = Movie.createFetchRequestResult()

        // Create Batch Delete Request
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        batchDeleteRequest.resultType = .resultTypeObjectIDs

        do {
            // Execute the batch delete request
            let result = try mainContext.execute(batchDeleteRequest) as? NSBatchDeleteResult
            let deletedObjectIDs = result?.result as? [NSManagedObjectID]

            // Create dictionary to hold all managed objects that were deleted in persistent store
            let changes: [AnyHashable: Any] = [NSDeletedObjectIDsKey: deletedObjectIDs ?? []]

            // merge changes to all contexts that might have managed objects in memory
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [mainContext])

        } catch {
            assertionFailure("CoreData failed to batch delete with error: \(error)")
        }
    }


    // Let's do all our UserData stuff here too, I mean this IS a StorageProvider, no?
    func fetchCurrentMovieSortOption() -> MovieSortOption {

        let rawMovieSortOrder = UserDefaults.standard.integer(forKey: UserDefaultKeys.movieSortOrder.rawValue)
        return MovieSortOption(rawValue: rawMovieSortOrder) ?? MovieSortOption.title
    }


    func setCurrentMovieSortOption(to movieSortOrder: MovieSortOption) {

        let rawMovieSortOrder = UserDefaultKeys.movieSortOrder.rawValue
        UserDefaults.standard.set(rawMovieSortOrder, forKey: UserDefaultKeys.movieSortOrder.rawValue)
    }
}


