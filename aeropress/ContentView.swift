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
        animation: .default)
    private var recipes: FetchedResults<Recipe>

    var body: some View {
        NavigationView {
            LazyVGrid(columns: [GridItem(), GridItem()]) {
                ForEach(recipes) { recipe in
                    ZStack(alignment: .topLeading) {
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color(UIColor.secondarySystemBackground))
                            .frame(height: 150)
                        Text("\(recipe.title ?? "")")
                            .padding(12)
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                Button {
                                    // do nothing
                                } label: {
                                    Image(systemName: "play.circle.fill")
                                        .resizable()
                                        .frame(width: 30, height: 30).padding()
                                }

                            }
                        }
                    }
                }
            }.padding()
//            List {
//                ForEach(recipes) { recipe in
//                    NavigationLink {
//                        RecipeDetail(recipe: recipe)
//                    } label: {
//                        Text("\(recipe.title ?? "")")
//                    }
//                }
//                .onDelete(perform: deleteRecipes)
//            }
//                .listStyle(.grouped)
//                .navigationTitle("Recipes")
//                .toolbar {
//                    ToolbarItem(placement: .navigationBarTrailing) {
//                        EditButton()
//                    }
//                    ToolbarItem {
//                        Button(action: addRecipe) {
//                            Label("Add Recipe", systemImage: "plus")
//                        }
//                    }
//                }
            Text("Select a recipe")
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

    private func deleteRecipes(offsets: IndexSet) {
        withAnimation {
            offsets.map { recipes[$0] }.forEach(viewContext.delete)

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
