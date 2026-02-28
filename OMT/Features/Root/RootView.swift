//
//  RootView.swift
//  OMT
//
//  Created by 이인호 on 1/11/26.
//

import SwiftUI
import ComposableArchitecture

struct RootView: View {
    @Bindable var store: StoreOf<RootContainer>

    var body: some View {
        Group {
            if store.showSplash {
                SplashView()
                    .onAppear {
                        store.send(.splashAppeared)
                    }
            } else {
                mainContent
            }
        }
        .animation(.easeInOut(duration: 0.3), value: store.showSplash)
        .animation(.easeInOut(duration: 0.3), value: store.currentView)
    }

    @ViewBuilder
    private var mainContent: some View {
        switch store.currentView {
        case .login:
            LoginView(store: store.scope(
                state: \.login,
                action: \.login)
            )
        case .loginSuccess:
            LoginSuccessView(store: store.scope(
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
        case .home:
            CustomTabView(store: store)
        }
    }
}
