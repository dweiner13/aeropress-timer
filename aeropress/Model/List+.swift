//
//  List+.swift
//  aeropress
//
//  Created by Dan Weiner on 10/10/21.
//

import CoreData

enum DWError: Int, CustomNSError, LocalizedError {
    case couldNotGetFavoritesList = 1

    var errorCode: Int { rawValue }

    var errorDomain: String { "org.danielweiner.aeropress" }

    var errorDescription: String? {
        switch self {
        case .couldNotGetFavoritesList: return "Could not get favorites list."
        }
    }
}

extension List {
    private static let kFavoritesListTitle = "_favorites"

    var recipesUnwrapped: [Recipe] {
        guard let recipes = recipes else { return [] }
        return recipes.array as! [Recipe]
    }

    var isFavoritesList: Bool {
        isInternal && title == Self.kFavoritesListTitle
    }

    static func getFavoritesList(context: NSManagedObjectContext) throws -> List {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "title == %@ and isInternal == true", kFavoritesListTitle)
        let results = try context.fetch(request)
        guard !results.isEmpty else {
            throw DWError.couldNotGetFavoritesList
        }
        return results[0]
    }

    static func getOrCreateFavoritesList(context: NSManagedObjectContext) throws -> List {
        do {
            return try getFavoritesList(context: context)
        } catch {
            if (error as? DWError) == .couldNotGetFavoritesList {
                return try createFavoritesList(context: context)
            } else {
                throw error
            }
        }
    }

    static func createFavoritesList(context: NSManagedObjectContext) throws -> List {
        let list = List(context: context)
        list.title = kFavoritesListTitle
        list.isInternal = true
        return list
    }
}
