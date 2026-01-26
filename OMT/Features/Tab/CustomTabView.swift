//
//  CustomTabView.swift
//  OMT
//
//  Created by 이인호 on 1/26/26.
//

import SwiftUI
import ComposableArchitecture

struct CustomTabView: View {
    let store: StoreOf<RootContainer>
    
    init(store: StoreOf<RootContainer>) {
        self.store = store
        
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground
        
        appearance.shadowColor = UIColor.separator
        appearance.shadowImage = nil
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        TabView(selection: Binding(
                get: { store.selectedTab },
                set: { store.send(.tabSelected($0)) }
            )
        ) {
            Tab("HOME", systemImage: "house", value: RootContainer.Tab.home) {
                HomeView(store: store.scope(state: \.home, action: \.home))
            }
            
            Tab("CHAT", systemImage: "message", value: RootContainer.Tab.chat) {
                ChatView(store: store.scope(state: \.chat, action: \.chat))
            }
            
            Tab("REPORT", systemImage: "chart.bar", value: RootContainer.Tab.analysis) {
                ReportView(store: store.scope(state: \.report, action: \.report))
            }
            
            Tab("MY PAGE", systemImage: "person", value: RootContainer.Tab.myPage) {
                Text("마이")
            }
        }
    }
}

