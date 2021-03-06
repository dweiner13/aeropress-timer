//
//  RecipeDetail.swift
//  aeropress
//
//  Created by Dan Weiner on 10/3/21.
//

import SwiftUI
import CoreData
import IntentsUI

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

    @Environment(\.save)
    private var save

    var isEditing: Bool {
        editMode?.wrappedValue.isEditing ?? true
    }

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

    func toggleEditing() {
        switch editMode?.wrappedValue {
        case .active, .transient: editMode?.wrappedValue = .inactive
        case .inactive: editMode?.wrappedValue = .active
        case .some: return
        case nil: return
        }
    }

    @AppStorage("RecipeDetail.isNotesExpanded")
    var isNotesExpanded = false

    var body: some View {
        SwiftUI.List {
            TextField("Title", text: titleBinding, prompt: nil)
                .multilineTextAlignment(.leading)
                .font(.headline)
                .focused($focusedField, equals: .title)
            Section("Notes") {
                ZStack(alignment: .bottomTrailing) {
                    TextEditor(text: notesBinding)
                        .frame(minHeight: isNotesExpanded ? 300 : 80)
                        .focused($focusedField, equals: .notes)
                    Button { isNotesExpanded.toggle() } label: {
                        Image(systemName: isNotesExpanded
                              ? "arrow.down.right.and.arrow.up.left"
                              : "arrow.up.left.and.arrow.down.right")
                    }
                    .frame(width: 30, height: 30)
                    .offset(x: 15, y: 4)
                }
            }
            Section("Steps") {
                ForEach(steps) { step in
                    RecipeStepListItem(step: step, index: index(of: step))
                        .focused($focusedField, equals: .duration)
                }
                .onMove { fromIndices, toIndex in
                    guard fromIndices.count == 1 else {
                        dwFatalError("onMove received more than 1 index ??? this is not supported.")
                    }
                    let fromIndex = fromIndices.first!
                    let mutableSet = NSMutableOrderedSet(orderedSet: recipe.unwrappedSteps)
                    mutableSet.moveObjects(at: fromIndices, to: fromIndex < toIndex ? toIndex - 1 : toIndex)
                    recipe.steps = mutableSet

                    save()
                }
                .onDelete { indices in
                    let stepsToDelete = indices.map { steps[$0] }
                    stepsToDelete.forEach { step in
                        viewContext.delete(step)
                    }

                    save()
                }
                Button {
                    withAnimation {
                        addStep()
                    }
                } label: {
                    Label("Add step", systemImage: "plus")
                }
            }
        }
        .onChange(of: focusedField) { newValue in
            // Save whenever focus blurs
            if newValue == nil {
                save()
            }
        }
//        .environment(\.editMode, .constant(.active))
        .listStyle(.insetGrouped)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $presentingTimerView) {
            TimerView(recipe: recipe)
        }
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
            ToolbarItem(placement: .navigationBarLeading) {
                EditButton()
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
        save()
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
