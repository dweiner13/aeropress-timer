//
//  RecipeStep+.swift
//  aeropress
//
//  Created by Dan Weiner on 10/3/21.
//

import CoreData

extension RecipeStep {
    enum Kind: Int16, CustomStringConvertible, CaseIterable, Identifiable, Hashable {
        case pour = 0
        case stir = 1
        case steep = 2
        case flip = 3
        case plunge = 4

        var id: Int16 {
            rawValue
        }

        var description: String {
            switch self {
            case .pour:
                return "Pour"
            case .stir:
                return "Stir"
            case .steep:
                return "Steep"
            case .flip:
                return "Flip"
            case .plunge:
                return "Plunge"
            }
        }
    }

    var unwrappedKind: Kind {
        set {
            kind = newValue.rawValue
        }
        get {
            Kind(rawValue: kind)!
        }
    }
}
