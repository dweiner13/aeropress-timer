//
//  RecipeDetail.swift
//  aeropress
//
//  Created by Dan Weiner on 10/3/21.
//

import SwiftUI
import CoreData

struct RecipeDetail: View {
    @ObservedObject
    var recipe: Recipe

    @Environment(\.managedObjectContext)
    private var viewContext

    var steps: [RecipeStep] {
        recipe.unwrappedSteps.array as! [RecipeStep]
    }

    func index(of step: RecipeStep) -> Int {
        steps.firstIndex(of: step)!
    }

    var body: some View {
        List {
            ForEach(steps) { step in
                RecipeStepListItem(step: step, index: index(of: step))
            }
            .onMove { fromIndices, toIndex in
                let mutableSet = NSMutableOrderedSet(orderedSet: recipe.unwrappedSteps)
                mutableSet.moveObjects(at: fromIndices, to: max(0, toIndex - fromIndices.count))
                recipe.steps = mutableSet

                do {
                    try viewContext.save()
                } catch {
                    // Replace this implementation with code to handle the error appropriately.
                    // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    let nsError = error as NSError
                    fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                }
            }
            .onDelete { indices in
                let stepsToDelete = indices.map { steps[$0] }
                stepsToDelete.forEach { step in
                    viewContext.delete(step)
                }

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
        .listStyle(.plain)
        .navigationTitle(recipe.unwrappedTitle)
        .toolbar {
            ToolbarItem {
                EditButton()
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    withAnimation {
                        addStep()
                    }
                } label: {
                    Label("Add", systemImage: "plus")
                }
            }
        }
    }

    func addStep() {
        let step = RecipeStep(context: viewContext)
        step.unwrappedKind = .pour
        step.durationSeconds = 15
        step.recipe = recipe
        recipe.addToSteps(step)
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

struct RecipeStepListItem: View {
    @ObservedObject
    var step: RecipeStep
    let index: Int

    @Environment(\.managedObjectContext)
    private var viewContext

    @Environment(\.editMode)
    private var editMode

    @State
    private var showingDetail = false

    enum Field: Hashable {
        case durationTextField
    }

    @FocusState
    private var focusedField: Field?

    //                TextField("Duration",
    //                          value: $step.durationSeconds,
    //                          format: .number.precision(.fractionLength(0)),
    //                          prompt: Text("Seconds"))
    //                    .focused($focusedField, equals: .durationTextField)
    //                    .foregroundColor(.accentColor)
    ////                    .multilineTextAlignment(.leading)
    //                    .keyboardType(.numberPad)

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text("\(index + 1).")
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                HStack(spacing: 8) {
                    Button {
                        showingDetail.toggle()
                    } label: {
                        Text("\(step.unwrappedKind.description)")
                    }
                    .foregroundColor(.accentColor)
                }
                Spacer()
                HStack(spacing: 8) {
                    TextField("",
                              value: $step.durationSeconds,
                              format: .number.precision(.fractionLength(0)),
                              prompt: Text(""))
                        .focused($focusedField, equals: .durationTextField)
                        .multilineTextAlignment(.trailing)
                        .foregroundColor(.accentColor)
                        .keyboardType(.numberPad)
                        .fixedSize()
                        .textFieldStyle(.roundedBorder)
                    Text(" seconds")
                        .foregroundColor(.secondary)
                        .fontWeight(.regular)
                }
            }
            .sheet(isPresented: $showingDetail) {
                NavigationView {
                    KindPicker(step: step, index: index)
                }
            }
        }
        .padding(.vertical, 8)
        .font(.headline)
    }
}

struct KindPicker: View {
    @ObservedObject
    var step: RecipeStep

    let index: Int

    var body: some View {
        Form {
            Picker("", selection: $step.kind) {
                ForEach(RecipeStep.Kind.allCases) { kind in
                    Text(kind.description)
                }
            }
            .pickerStyle(.inline)
        }
        .navigationTitle("Step \(index + 1)")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct RecipeDetail_Previews: PreviewProvider {
    static var previews: some View {
        EditModePreviewWrapper {
            NavigationView {
                RecipeDetail(recipe: PersistenceController.previewRecipes().first!)
                    .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            }
        }
    }
}
