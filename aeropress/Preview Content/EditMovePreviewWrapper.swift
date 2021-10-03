//
//  EditMovePreviewWrapper.swift
//  aeropress
//
//  Created by Dan Weiner on 10/3/21.
//

import SwiftUI

struct EditModePreviewWrapper<Content: View>: View {
    @State var editMode: EditMode = .inactive
    var content: Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content()
    }

    var body: some View {
        // Can't access @State outside of render loop (e.g. in preview creation)
        content.environment(\.editMode, $editMode)
    }
}
