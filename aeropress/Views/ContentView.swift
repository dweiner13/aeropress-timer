//
//  ContentView.swift
//  aeropress
//
//  Created by Dan Weiner on 10/3/21.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext)
    private var viewContext

    @Environment(\.favoritesList)
    private var favoritesList: List!

    @Environment(\.editMode)
    private var editMode

    @Environment(\.save)
    private var save

    var isEditing: Bool {
        editMode?.wrappedValue.isEditing ?? true
    }

    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Recipe.title,
                                                     ascending: true)],
                  animation: .default)
    private var notFavoriteRecipes: FetchedResults<Recipe>

    @State
    var currentTimerRecipe: Recipe?

    @State
    var currentEditingRecipe: Recipe?

    @State
    var showingDeleteConf: Bool = false

    var body: some View {
        NavigationView {
            SwiftUI.List {
                if favoritesList.recipesUnwrapped.isEmpty {
                    viewsForRecipes(notFavoriteRecipes)
                } else {
                    Section {
                        viewsForRecipes(favoritesList.recipesUnwrapped)
                            .onMove { fromIndices, toIndex in
                                guard fromIndices.count == 1 else { fatalError() }
                                let fromIndex = fromIndices.first!
                                let mutableSet = NSMutableOrderedSet(orderedSet: favoritesList.recipes!)
                                mutableSet.moveObjects(at: fromIndices, to: fromIndex < toIndex ? toIndex - 1 : toIndex)
                                favoritesList.recipes = mutableSet

                                save()
                            }
                    } header: {
                        HStack {
                            Text("Pinned")
                            Image(systemName: "pin.circle.fill")
                                .imageScale(.large)
                                .symbolRenderingMode(.multicolor)
                        }
                    }
                    Section("All Recipes") {
                        viewsForRecipes(notFavoriteRecipes)
                    }
                }
            }
                .listStyle(.sidebar)
                .navigationTitle("Recipes")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        EditButton()
                    }
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: addRecipe) {
                            Label("Add Recipe", systemImage: "plus")
                        }
                    }
                }
            Text("Select a recipe")
        }
        .sheet(item: $currentTimerRecipe) { recipe in
            TimerView(recipe: recipe)
        }
        .sheet(item: $currentEditingRecipe) { recipe in
            NavigationView {
                RecipeDetail(recipe: recipe)
            }
        }
    }

    @ViewBuilder
    private func viewsForRecipes<C: RandomAccessCollection>(_ recipes: C) -> some DynamicViewContent where C.Element == Recipe {
        ForEach.init(recipes) { recipe in
            HStack(spacing: 16) {
                Button(recipe.title ?? "") { runRecipe(recipe) }
                Spacer()
                editButton(recipe: recipe)
                    .labelStyle(.iconOnly)
                    .buttonStyle(.borderless)
                    .imageScale(.large)
            }
            .padding(.trailing, 8)
            .contextMenu {
                runButton(recipe: recipe)
                editButton(recipe: recipe)
                Divider()
                toggleFavoriteButton(recipe: recipe)
                duplicateButton(recipe: recipe)
                deleteButton(recipe: recipe)
            }
            .swipeActions(edge: .leading) {
                deleteButton(recipe: recipe)
                duplicateButton(recipe: recipe)
            }
            .swipeActions(edge: .trailing) {
                toggleFavoriteButton(recipe: recipe)
            }
        }
    }

    @ViewBuilder
    private func runButton(recipe: Recipe) -> some View {
        Button { runRecipe(recipe) } label: {
            Label("Start Recipe", systemImage: "play")
        }.tint(.blue)
    }

    @ViewBuilder
    private func editButton(recipe: Recipe) -> some View {
        Button { currentEditingRecipe = recipe } label: {
            Label("Recipe Details", systemImage: "info.circle")
        }
    }

    @ViewBuilder
    private func duplicateButton(recipe: Recipe) -> some View {
        Button { duplicateRecipe(recipe) } label: {
            Label("Duplicate Recipe", systemImage: "plus.square.on.square")
        }.tint(.blue)
    }

    @ViewBuilder
    private func deleteButton(recipe: Recipe) -> some View {
        Button(role: .destructive) { deleteRecipe(recipe) } label: {
            Label("Delete Recipe", systemImage: "trash")
        }
    }

    private func toggleFavoriteButton(recipe: Recipe) -> some View {
        let isFavorite = favoritesList.recipesUnwrapped.contains(recipe)
        return Button { toggleFavoriteRecipe(recipe) } label: {
            Label(isFavorite ? "Unpin Recipe" : "Pin Recipe",
                  systemImage: isFavorite ? "pin.slash" : "pin")
        }
            .tint(.orange)
    }

    private func runRecipe(_ recipe: Recipe) {
        currentTimerRecipe = recipe
    }

    private func duplicateRecipe(_ recipe: Recipe) {
        withAnimation {
            _ = Recipe(recipe: recipe, context: viewContext)

            save()
        }
    }

    private func deleteRecipe(_ recipe: Recipe) {
        withAnimation {
            viewContext.delete(recipe)

            save()
        }
    }

    private func toggleFavoriteRecipe(_ recipe: Recipe) {
        withAnimation {
            if favoritesList.recipesUnwrapped.contains(recipe) {
                favoritesList.removeFromRecipes(recipe)
            } else {
                favoritesList.addToRecipes(recipe)
            }

            save()
        }
    }

    private func addRecipe() {
        withAnimation {
            _ = newRecipeFromTemplate(in: viewContext)

            save()
        }
    }
}

private let recipeFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environment(\.favoritesList, PersistenceController.preview.previewFavoritesList)
    }
}
