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
    
    var body: some View {
        switch store.state {
        case .login:
            if let loginStore = store.scope(state: \.login, action: \.login) {
                LoginView(store: loginStore)
            }
        }
    }
}
