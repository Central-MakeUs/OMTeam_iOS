//
//  RootView.swift
//  OMT
//
//  Created by 이인호 on 1/11/26.
//

import SwiftUI
import ComposableArchitecture

struct RootView: View {
    let store: StoreOf<RootContainer>
    
    @State private var currentView: RootContainer.ViewStatus = .login
    
    var body: some View {
        switch store.currentView {
        case .login:
            LoginView(store: store.scope(
                state: \.login,
                action: \.login)
            )
        case .onboarding:
            if let onboardingStore = store.scope(
                state: \.onboarding,
                action: \.onboarding
            ) {
                OnboardingView(
                    store: onboardingStore
                )
            }
        case .mainTab:
            EmptyView()
        }
    }
}
