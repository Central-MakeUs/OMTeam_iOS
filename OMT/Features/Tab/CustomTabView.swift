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
        appearance.backgroundColor = .greenGray2
        
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(named: "gray11") ?? .black,
            .font: UIFont(name: "Pretendard-Medium", size: 11) ?? .systemFont(ofSize: 10)
        ]
        
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor(named: "gray9") ?? .gray,
            .font: UIFont(name: "Pretendard-Medium", size: 11) ?? .systemFont(ofSize: 10)
        ]
        
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
            Tab("HOME",
                image: store.selectedTab == .home ? "home_enabled" : "home_disabled",
                value: RootContainer.Tab.home) {
                HomeView(store: store.scope(state: \.home, action: \.home))
            }
            
            Tab("CHAT",
                image: store.selectedTab == .chat ? "chat_enabled" : "chat_disabled",
                value: RootContainer.Tab.chat) {
                ChatView(store: store.scope(state: \.chat, action: \.chat))
            }
            
            Tab("REPORT",
                image: store.selectedTab == .analysis ? "chart_enabled" : "chart_disabled",
                value: RootContainer.Tab.analysis) {
                ReportView(store: store.scope(state: \.report, action: \.report))
            }
            
            Tab("MY PAGE",
                image: store.selectedTab == .myPage ? "my_enabled" : "my_disabled",
                value: RootContainer.Tab.myPage) {
                Text("마이")
            }
        }
    }
}

