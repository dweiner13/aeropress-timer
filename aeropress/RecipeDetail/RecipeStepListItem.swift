//
//  RecipeStepListItem.swift
//  aeropress
//
//  Created by Dan Weiner (TTG) on 10/9/21.
//

import SwiftUI

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
            menu = menu.replacingChildren(RecipeStep.Kind.allCases.map({ kind in
                UIAction(title: kind.description,
                         state: selectedKind == kind ? .on : .off,
                         handler: { _ in self.selectedKind.wrappedValue = kind })
            }))
            button?.menu = UIMenu(children: [UIAction(title: selectedKind.description, handler: { _ in })])
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
        let button = UIButton(configuration: .borderless(), primaryAction: nil)
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
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text("\(index + 1).")
            HStack(alignment: .firstTextBaseline, spacing: 0) {
                HStack(spacing: 8) {
                    MenuButton($step.unwrappedKind)
//                    Button {
//                        showingDetail.toggle()
//                    } label: {
//                        Text("\(step.unwrappedKind.description)")
//                    }
//                    .foregroundColor(.accentColor)
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
                    Text(" s")
                        .foregroundColor(.secondary)
                        .fontWeight(.regular)
                        .lineLimit(1)
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
        EditModePreviewWrapper {
            List(PersistenceController.previewRecipes().first!.steps!.array as! [RecipeStep]) { step in
                RecipeStepListItem(step: step, index: 1)
            }.environment(\.editMode, .constant(.active))
        }
    }
}
