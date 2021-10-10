//
//  RecipeStepListItem.swift
//  aeropress
//
//  Created by Dan Weiner (TTG) on 10/9/21.
//

import SwiftUI
import UIKit

struct MenuButton: UIViewRepresentable {

    class Coordinator {
        var button: UIButton? {
            didSet {
                updateMenu(selectedKind: selectedKind.wrappedValue)
            }
        }
        var menu: UIMenu
        var selectedKind: Binding<RecipeStep.Kind> {
            didSet {
                updateMenu(selectedKind: selectedKind.wrappedValue)
            }
        }

        init(selected: Binding<RecipeStep.Kind>) {
            selectedKind = selected
            menu = UIMenu()
        }

        func refresh() {
            guard button?.title(for: .normal) != selectedKind.wrappedValue.description else {
                return
            }
            updateMenu(selectedKind: selectedKind.wrappedValue)
        }

        private func updateMenu(selectedKind: RecipeStep.Kind) {
            let menuActions = RecipeStep.Kind.allCases.map({ kind in
                UIAction(title: kind.description,
                         state: selectedKind == kind ? .on : .off) { _ in
                    self.selectedKind.wrappedValue = kind
                    self.updateMenu(selectedKind: kind)
                }
            })
            button?.menu = UIMenu(title: "", children: menuActions)
            button?.setTitle(selectedKind.description, for: .normal)
        }
    }

    let selected: Binding<RecipeStep.Kind>

    init(_ selected: Binding<RecipeStep.Kind>) {
        self.selected = selected
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(selected: selected)
    }

    func makeUIView(context: Context) -> UIButton {
        var configuration = UIButton.Configuration.bordered()
        configuration.imagePlacement = .trailing
        configuration.imagePadding = 8
        configuration.preferredSymbolConfigurationForImage = .init(pointSize: 10, weight: .semibold)
        configuration.buttonSize = .medium
        configuration.cornerStyle = .dynamic
        let button = UIButton(configuration: configuration, primaryAction: nil)
//        button.setImage(.init(systemName: "chevron.up.chevron.down"), for: .normal)
        context.coordinator.button = button
        button.showsMenuAsPrimaryAction = true
        return button
    }

    func updateUIView(_ uiView: UIButton, context: Context) {
        context.coordinator.selectedKind = selected
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

    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            Text("\(index + 1).")
                .foregroundColor(.secondary)
                .font(.headline)
            HStack(alignment: .center, spacing: 8) {
                MenuButton($step.unwrappedKind)
                    .fixedSize()
                Spacer()
                Text("for")
                    .font(.body)
                    .foregroundColor(.secondary)
//                if focusedField != nil {
//                    Button("Done") {
//                        focusedField = nil
//                    }
//                    .buttonStyle(.borderedProminent)
//                }
                TextField("",
                          value: $step.durationSeconds,
                          format: .number.precision(.fractionLength(0)),
                          prompt: Text(""))
                    .focused($focusedField, equals: .durationTextField)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.accentColor)
                    .keyboardType(.numberPad)
                    .frame(width: 30)
                    .padding(6)
                    .fixedSize()
                    .background(Color(UIColor.secondarySystemFill))
                    .cornerRadius(6)
                Text(" s")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            .sheet(isPresented: $showingDetail) {
                NavigationView {
                    KindPicker(step: step, index: index)
                }
            }
        }
        .padding(.vertical, 16)
    }
}

struct RecipeStepListItem_Previews: PreviewProvider {
    static var previews: some View {
        EditModePreviewWrapper {
            NavigationView {
                List(PersistenceController.previewRecipes().first!.steps!.array as! [RecipeStep]) { step in
                    RecipeStepListItem(step: step, index: 1)
                }.environment(\.editMode, .constant(.active))
            }
        }
    }
}
