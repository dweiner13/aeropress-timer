//
//  Persistence.swift
//  aeropress
//
//  Created by Dan Weiner on 10/3/21.
//

import CoreData

/// From Xcode template
struct PersistenceController {
    static let shared = PersistenceController()

    static func previewRecipes() -> [Recipe] {
        try! preview.container.viewContext.fetch(Recipe.fetchRequest())
    }

    private(set) var previewFavoritesList: List!

    static var preview: PersistenceController = {
        var persistenceController = PersistenceController(inMemory: true)
        let viewContext = persistenceController.container.viewContext
        let recipes: [Recipe] = (0..<10).map {
            let recipe = newRecipeFromTemplate(in: viewContext)
            recipe.title = "Recipe \($0 + 1)"
            return recipe
        }
        let previewFavoritesList = try! List.getOrCreateFavoritesList(context: viewContext)
        previewFavoritesList.addToRecipes(recipes.first!)
        persistenceController.previewFavoritesList = previewFavoritesList
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return persistenceController
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "aeropress")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                Typical reasons for an error here include:
                * The parent directory does not exist, cannot be created, or disallows writing.
                * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                * The device is out of space.
                * The store could not be migrated to the current model version.
                Check the error message to determine what the actual problem was.
                */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
    }
}


func newRecipeFromTemplate(in context: NSManagedObjectContext) -> Recipe {
    let newRecipe = Recipe(context: context)
    newRecipe.title = "Recipe \(Int.random(in: 0..<100))"

    var step = RecipeStep(context: context)
    step.durationSeconds = 10
    step.kind = RecipeStep.Kind.pour.rawValue
    step.recipe = newRecipe
    newRecipe.addToSteps(step)

    step = RecipeStep(context: context)
    step.durationSeconds = 15
    step.kind = RecipeStep.Kind.stir.rawValue
    step.recipe = newRecipe
    newRecipe.addToSteps(step)

    step = RecipeStep(context: context)
    step.durationSeconds = 45
    step.kind = RecipeStep.Kind.steep.rawValue
    step.recipe = newRecipe
    newRecipe.addToSteps(step)

    step = RecipeStep(context: context)
    step.durationSeconds = 15
    step.kind = RecipeStep.Kind.pour.rawValue
    step.recipe = newRecipe
    newRecipe.addToSteps(step)

    step = RecipeStep(context: context)
    step.durationSeconds = 5
    step.kind = RecipeStep.Kind.flip.rawValue
    step.recipe = newRecipe
    newRecipe.addToSteps(step)

    step = RecipeStep(context: context)
    step.durationSeconds = 20
    step.kind = RecipeStep.Kind.plunge.rawValue
    step.recipe = newRecipe
    newRecipe.addToSteps(step)

    return newRecipe
}
