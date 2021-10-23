//
//  IntentRecipe+.swift
//  aeropress
//
//  Created by Dan Weiner on 10/22/21.
//

import Foundation
import Intents

extension IntentRecipe {
    convenience init(recipe: Recipe) {
        self.init(identifier: recipe.objectID.uriRepresentation().absoluteString,
                  display: recipe.unwrappedTitle,
                  subtitle: nil,
                  image: recipe.isFavorite ? INImage.systemImageNamed("pin.fill") : nil)
    }
}
