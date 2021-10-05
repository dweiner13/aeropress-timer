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
}
