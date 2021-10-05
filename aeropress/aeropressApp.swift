//
//  aeropressApp.swift
//  aeropress
//
//  Created by Dan Weiner on 10/3/21.
//

import SwiftUI

@main
struct aeropressApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
