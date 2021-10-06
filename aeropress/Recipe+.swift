//
//  Recipe+.swift
//  aeropress
//
//  Created by Dan Weiner on 10/3/21.
//

import CoreData

extension Recipe {
    convenience init(recipe: Recipe, context: NSManagedObjectContext) {
        self.init(context: context)
        title = recipe.title
        notes = recipe.notes

        for step in recipe.unwrappedSteps {

        }
    }

    var unwrappedTitle: String {
        title!
    }

    var unwrappedSteps: NSOrderedSet {
        steps ?? []
    }
}
