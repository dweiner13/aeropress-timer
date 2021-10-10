//
//  Recipe+.swift
//  aeropress
//
//  Created by Dan Weiner on 10/3/21.
//

import CoreData

extension Recipe {
    var unwrappedTitle: String {
        title!
    }

    var unwrappedSteps: NSOrderedSet {
        steps ?? []
    }

    convenience init(recipe: Recipe, context: NSManagedObjectContext) {
        self.init(context: context)

        title = (recipe.title ?? "Recipe") + " copy"
        notes = recipe.notes

        for step in recipe.unwrappedSteps.array as! [RecipeStep] {
            let newStep = RecipeStep(recipeStep: step, context: context)
            newStep.recipe = self

            addToSteps(newStep)
        }
    }
}
