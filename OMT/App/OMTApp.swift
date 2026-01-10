//
//  OMTApp.swift
//  OMT
//
//  Created by 이인호 on 12/26/25.
//

import SwiftUI
import ComposableArchitecture

@main
struct OMTApp: App {
    static let store = Store(initialState: AppFeature.State.login(LoginFeature.State())) {
            AppFeature()
        }
    
    var body: some Scene {
        WindowGroup {
            AppView(store: OMTApp.store)
        }
    }
}
