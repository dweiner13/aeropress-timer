//
//  KindPicker.swift
//  aeropress
//
//  Created by Dan Weiner (TTG) on 10/9/21.
//

import SwiftUI

struct KindPicker: View {
    @ObservedObject
    var step: RecipeStep

    @Environment(\.dismiss)
    var dismiss

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
        .onChange(of: step.kind, perform: { _ in
            dismiss()
        })
        .navigationTitle("Step \(index + 1)")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct KindPicker_Previews: PreviewProvider {
    static var previews: some View {
        KindPicker(step: PersistenceController.previewRecipes().first!.steps!.firstObject! as! RecipeStep, index: 1)
    }
}
