//
//  AeropressApp.swift
//  aeropress
//
//  Created by Dan Weiner on 10/3/21.
//

import SwiftUI
import CoreData

struct FavoritesListKey: EnvironmentKey {
    static let defaultValue: List? = nil
}

struct SaveKey: EnvironmentKey {
    static let defaultValue: (() -> Void) = {}
}

extension EnvironmentValues {
    var favoritesList: List? {
        get {
            self[FavoritesListKey.self]
        }
        set {
            self[FavoritesListKey.self] = newValue
        }
    }

    var save: () -> Void {
        get {
            self[SaveKey.self]
        }
        set {
            self[SaveKey.self] = newValue
        }
    }
}

func errorMessage(coreDataError: NSError) -> String {
    switch coreDataError.code {
    case NSManagedObjectConstraintMergeError:
        guard let constraintErrors = coreDataError.userInfo[NSPersistentStoreSaveConflictsErrorKey] as? [NSConstraintConflict],
              let constraintError = constraintErrors.first else {
            return "A constraint merge error has occurred."
        }
        return "Two items have the same value for \"\(constraintError.constraint.first!)\"."
    default: return coreDataError.localizedDescription
    }
}

@main
struct AeropressApp: App {
    let persistenceController: PersistenceController
    let favoritesList: List

    @State
    var showingError = false
    @State
    var error: Error?

    var body: some Scene {
        WindowGroup {
            SpriteKitHarness()
//            ContentView()
//                .environment(\.managedObjectContext, persistenceController.container.viewContext)
//                .environment(\.favoritesList, favoritesList)
//                .environment(\.save, attemptSave)
//                .alert("Error", isPresented: $showingError, presenting: error) { error in
//                    Button("OK") {}.keyboardShortcut(.defaultAction)
//                } message: { error in
//                    Text(errorMessage(coreDataError: error as NSError))
//                }

        }
    }

    func attemptSave() {
        do {
            try persistenceController.container.viewContext.save()
        } catch {
            showingError = true
            self.error = error
            print("🚨 dumping Core Data error:")
            dump(error)
            persistenceController.container.viewContext.rollback()
        }
    }

    init() {
        persistenceController = PersistenceController.shared
        do {
            favoritesList = try List.getOrCreateFavoritesList(context: persistenceController.container.viewContext)
        } catch {
            fatalError("Could not get or create Favorites list due to error \(error.localizedDescription).")
        }
    }
}
