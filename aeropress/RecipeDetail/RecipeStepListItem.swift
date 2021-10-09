//
//  RecipeStepListItem.swift
//  aeropress
//
//  Created by Dan Weiner (TTG) on 10/9/21.
//

import SwiftUI

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
                if focusedField != nil {
                    Button("Done") {
                        focusedField = nil
                    }
                    .buttonStyle(.borderedProminent)
                }
                HStack(spacing: 8) {
                    TextField("",
                              value: $step.durationSeconds,
                              format: .number.precision(.fractionLength(0)),
                              prompt: Text(""))
                        .focused($focusedField, equals: .durationTextField)
                        .multilineTextAlignment(.trailing)
                        .foregroundColor(.accentColor)
                        .keyboardType(.numberPad)
                        .frame(width: 50)
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

struct RecipeStepListItem_Previews: PreviewProvider {
    static var previews: some View {
        RecipeStepListItem(step: PersistenceController.previewRecipes().first!.steps!.firstObject! as! RecipeStep, index: 1)
    }
}
