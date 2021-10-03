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

    @Environment(\.editMode)
    private var editMode

    var steps: [RecipeStep] {
        recipe.unwrappedSteps.array as! [RecipeStep]
    }

    func index(of step: RecipeStep) -> Int {
        steps.firstIndex(of: step)!
    }

    var body: some View {
        List {
            ForEach(steps) { step in
                if editMode?.wrappedValue.isEditing ?? true {
                    Section {
                        Text("Step \(index(of: step) + 1)")
                    }
                } else {
                    RecipeStepListItem(step: step, index: index(of: step))
                }
            }
            .onMove { fromIndices, toIndex in
                
            }
        }
        .navigationTitle(recipe.unwrappedTitle)
        .toolbar {
            ToolbarItem {
                EditButton()
            }
        }
    }
}

struct RecipeStepListItem: View {
    @ObservedObject
    var step: RecipeStep

    let index: Int

    @Environment(\.managedObjectContext)
    private var viewContext

    var body: some View {
        Section("Step \(index + 1)") {
            Picker("Kind", selection: $step.kind) {
                ForEach(RecipeStep.Kind.allCases) { kind in
                    Text(kind.description)
                }
            }
            .pickerStyle(.automatic)
            HStack {
                Text("Duration")
                Spacer()
                TextField("Duration", value: $step.durationSeconds, format: .number.precision(.fractionLength(0)), prompt: Text("Duration"))
                    .multilineTextAlignment(.trailing)
                    .foregroundColor(.accentColor)
//                    .frame(alignment: .trailing)

            }
//            Text("duration: \(step.durationSeconds.formatted(.number.precision(.significantDigits(2)))) seconds")
//            DatePicker(<#T##title: StringProtocol##StringProtocol#>, selection: <#T##Binding<Date>#>)
//            Slider(
//                value: $step.durationSeconds,
//                in: 1...60,
//                step: 1.0
//            ) {
//                Text("Duration")
//            }
        }
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
