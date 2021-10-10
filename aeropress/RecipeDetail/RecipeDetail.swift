//
//  RecipeDetail.swift
//  aeropress
//
//  Created by Dan Weiner on 10/3/21.
//

import SwiftUI
import CoreData

struct StickyHeader<Content: View>: View {

    var minHeight: CGFloat
    var content: Content

    init(minHeight: CGFloat = 200, @ViewBuilder content: () -> Content) {
        self.minHeight = minHeight
        self.content = content()
    }

    var body: some View {
        GeometryReader { geo in
            if(geo.frame(in: .global).minY <= 0) {
                content
                    .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
            } else {
                content
                    .offset(y: -geo.frame(in: .global).minY)
                    .frame(width: geo.size.width, height: geo.size.height + geo.frame(in: .global).minY)
            }
        }.frame(minHeight: minHeight)
    }
}

struct RecipeDetail: View {

    enum Field {
        case title
        case notes
        case duration
    }

    @FocusState
    var focusedField: Field?

    @ObservedObject
    var recipe: Recipe

    @Environment(\.managedObjectContext)
    private var viewContext

    @Environment(\.editMode)
    private var editMode

    @Environment(\.dismiss)
    private var dismiss

    @State
    private var presentingTimerView = false

    var steps: [RecipeStep] {
        recipe.unwrappedSteps.array as! [RecipeStep]
    }

    func index(of step: RecipeStep) -> Int {
        steps.firstIndex(of: step)!
    }

    let titleBinding: Binding<String>
    let notesBinding: Binding<String>

    init(recipe: Recipe) {
        self.recipe = recipe
        titleBinding = .init {
            recipe.unwrappedTitle
        } set: { newValue in
            recipe.title = newValue
        }
        notesBinding = .init {
            recipe.notes ?? ""
        } set: { newValue in
            recipe.notes = newValue
        }
    }

    var isEditing: Bool {
        editMode?.wrappedValue.isEditing ?? true
    }

    func toggleEditing() {
        switch editMode?.wrappedValue {
        case .active, .transient: editMode?.wrappedValue = .inactive
        case .inactive: editMode?.wrappedValue = .active
        case .some: return
        case nil: return
        }
    }

    var body: some View {
        List {
            TextField("Title", text: titleBinding, prompt: nil)
                .multilineTextAlignment(.leading)
                .font(.title)
                .foregroundColor(.accentColor)
                .focused($focusedField, equals: .title)
            Section("Notes") {
                VStack(alignment: .leading) {
                    TextEditor(text: notesBinding)
                        .frame(minHeight: 100)
                        .focused($focusedField, equals: .notes)
                }
            }
            Section("Steps") {
                ForEach(steps) { step in
                    RecipeStepListItem(step: step, index: index(of: step))
                        .focused($focusedField, equals: .duration)
                }
                .onMove { fromIndices, toIndex in
                    guard fromIndices.count == 1 else { fatalError() }
                    let fromIndex = fromIndices.first!
                    let mutableSet = NSMutableOrderedSet(orderedSet: recipe.unwrappedSteps)
                    mutableSet.moveObjects(at: fromIndices, to: fromIndex < toIndex ? toIndex - 1 : toIndex)
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
            Section {
                Button {
                    withAnimation {
                        addStep()
                    }
                } label: {
                    Label("Add step", systemImage: "plus")
                }.disabled(editMode?.wrappedValue.isEditing ?? true)
            }
        }
        .onChange(of: focusedField) { newValue in
            // Save whenever focus blurs
            if newValue == nil {
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
        .environment(\.editMode, .constant(.active))
        .listStyle(.insetGrouped)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $presentingTimerView) {
            TimerView(recipe: recipe)
        }
        .navigationTitle("Edit Recipe")
        .toolbar {
            ToolbarItem {
                if focusedField != nil {
                    Button {
                        $focusedField.wrappedValue = nil
                        editMode?.wrappedValue = .inactive
                    } label: {
                        Image(systemName: "keyboard.chevron.compact.down")
                            .font(.body.bold())
                    }
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button { dismiss() } label: { Text("Done").bold() }
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

struct RecipeDetail_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            RecipeDetail(recipe: PersistenceController.previewRecipes().first!)
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}
