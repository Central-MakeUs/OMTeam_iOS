//
//  AppView.swift
//  OMT
//
//  Created by 이인호 on 1/11/26.
//

import SwiftUI
import ComposableArchitecture

struct AppView: View {
    let store: StoreOf<AppFeature>
    
    @State private var currentView: AppFeature.ViewStatus = .login
    
    var body: some View {
        switch currentView {
        case .login:
            LoginView(store: store.scope(
                state: \.login,
                action: \.login)
            )
        case .mainTab:
            EmptyView()
        }
    }
}
