//
//  ListEditor.swift
//  aeropress
//
//  Created by Dan Weiner on 10/23/21.
//

import SwiftUI

struct ListEditor: View {
    @FetchRequest(sortDescriptors: [.init(keyPath: \List.title, ascending: true)],
                  animation: .default)
    private var lists: FetchedResults<List>

    @Environment(\.save)
    var save

    var body: some View {
        NavigationView {
            SwiftUI.List {
                ForEach(lists) { list in
                    NavigationLink("\(list.title ?? "") \(list.isInternal ? "(internal)" : "")") {
                        SwiftUI.List {
                            ForEach(list.recipesUnwrapped) { recipe in
                                Text("\(recipe.unwrappedTitle)")
                            }
                        }
                        .navigationTitle(list.title ?? "")
                    }
                }
                .onDelete { indices in
                    indices
                        .map { lists[$0] }
                        .forEach {
                            $0.managedObjectContext?.delete($0)
                            save()
                        }
                }
            }
            .navigationTitle("Lists")
        }
    }
}

struct ListEditor_Previews: PreviewProvider {
    static var previews: some View {
        ListEditor()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
