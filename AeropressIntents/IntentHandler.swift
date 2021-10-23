//
//  IntentHandler.swift
//  AeropressIntents
//
//  Created by Dan Weiner on 10/22/21.
//

import Intents
import CoreData

class IntentHandler: INExtension {
    
    override func handler(for intent: INIntent) -> Any {
        log.debug("IntentHandler handling intent \(intent.debugDescription)")
        switch intent {
        case is StartRecipeIntent: return StartRecipeHandler()
        default: return self
        }
    }

    override init() {
        super.init()
        setUpLogging()
    }
    
}

extension NSUserActivity {
    convenience init(_ intent: StartRecipeIntent) {
        self.init(activityType: "StartRecipeIntent")
        self.userInfo = ["recipeURI": intent.recipe?.identifier as Any]
    }
}

class StartRecipeHandler: NSObject {
    private var coordinator: NSPersistentStoreCoordinator
    private var context: NSManagedObjectContext

    override init() {
        context = PersistenceController.shared.container.viewContext
        coordinator = PersistenceController.shared.container.persistentStoreCoordinator
        super.init()
    }

    private func recipes(searchTerm: String?) async throws -> [IntentRecipe] {
        guard let searchTerm = searchTerm else {
            return try await recipes()
        }
        let request = Recipe.fetchRequest()
        request.predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchTerm)
        return try await context.perform {
            try self.context
                .fetch(request)
                .map(IntentRecipe.init(recipe:))
        }
    }

    private func recipes() async throws -> [IntentRecipe] {
        try await context.perform {
            try self.context
                .fetch(Recipe.fetchRequest())
                .map(IntentRecipe.init(recipe:))
        }
    }

    private func recipe(withURI managedObjectURI: String) async -> IntentRecipe? {
        guard let url = URL(string: managedObjectURI),
              let id = coordinator.managedObjectID(forURIRepresentation: url) else {
            return nil
        }
        return await context.perform {
            (self.context.object(with: id) as? Recipe)
                .map(IntentRecipe.init(recipe:))
        }
    }
}

extension StartRecipeHandler: StartRecipeIntentHandling {
    func handle(intent: StartRecipeIntent) async -> StartRecipeIntentResponse {
        guard let managedObjectURI = intent.recipe?.identifier,
              let recipe = await recipe(withURI: managedObjectURI) else {
            return StartRecipeIntentResponse(code: .failure, userActivity: nil)
        }
        return StartRecipeIntentResponse(code: .continueInApp,
                                         userActivity: NSUserActivity(intent))
    }

    func resolveRecipe(for intent: StartRecipeIntent) async -> IntentRecipeResolutionResult {
        guard let managedObjectURI = intent.recipe?.identifier,
              let recipe = await recipe(withURI: managedObjectURI) else {
            do {
                return .disambiguation(with: try await recipes())
            } catch {
                return .confirmationRequired(with: nil)
            }
        }
        return .success(with: recipe)
    }

    func provideRecipeOptionsCollection(for intent: StartRecipeIntent,
                                        searchTerm: String?,
                                        with completion: @escaping (INObjectCollection<IntentRecipe>?, Error?) -> Void) {
        Task {
            do {
                let recipes = try await self.recipes(searchTerm: searchTerm)
                let collection = INObjectCollection(items: recipes)
                completion(collection, nil)
            } catch {
                completion(nil, error)
            }
        }
    }
}
