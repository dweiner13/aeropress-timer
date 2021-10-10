//
//  ContentView.swift
//  aeropress
//
//  Created by Dan Weiner on 10/3/21.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Recipe.title, ascending: true)],
        predicate: NSPredicate(format: "isFavorite == true"),
        animation: .default)
    private var favoriteRecipes: FetchedResults<Recipe>

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Recipe.title, ascending: true)],
        predicate: NSPredicate(format: "isFavorite == false"),
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
            List {
                if favoriteRecipes.isEmpty {
                    viewsForRecipes(notFavoriteRecipes)
                } else {
                    Section {
                        viewsForRecipes(favoriteRecipes)
                    } header: {
                        HStack {
                            Text("Pinned")
                            Image(systemName: "pin.circle.fill")
                                .imageScale(.large)
                                .symbolRenderingMode(.multicolor)
                        }
                    }
                    Section("Recipes") {
                        viewsForRecipes(notFavoriteRecipes)
                    }
                }
            }
                .listStyle(.sidebar)
                .navigationTitle("Recipes")
                .toolbar {
                    ToolbarItem {
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
    private func viewsForRecipes(_ recipes: FetchedResults<Recipe>) -> some View {
        ForEach(recipes) { recipe in
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

    @ViewBuilder
    private func toggleFavoriteButton(recipe: Recipe) -> some View {
        Button { toggleFavoriteRecipe(recipe) } label: {
            Label(recipe.isFavorite ? "Unpin Recipe" : "Pin Recipe", systemImage: recipe.isFavorite ? "pin.slash" : "pin")
        }
        .tint(.orange)
    }

    private func runRecipe(_ recipe: Recipe) {
        currentTimerRecipe = recipe
    }

    private func duplicateRecipe(_ recipe: Recipe) {
        withAnimation {
            _ = Recipe(recipe: recipe, context: viewContext)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteRecipe(_ recipe: Recipe) {
        withAnimation {
            viewContext.delete(recipe)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func toggleFavoriteRecipe(_ recipe: Recipe) {
        withAnimation {
            recipe.isFavorite.toggle()

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func addRecipe() {
        withAnimation {
            _ = newRecipeFromTemplate(in: viewContext)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
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
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
