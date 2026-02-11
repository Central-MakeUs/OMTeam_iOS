//
//  CustomTabView.swift
//  OMT
//
//  Created by 이인호 on 1/26/26.
//

import SwiftUI
import ComposableArchitecture

struct CustomTabView: View {
    // 자식
    @Bindable var store: StoreOf<RootContainer>
    
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
        
        appearance.shadowColor = .clear
        appearance.shadowImage = nil
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        NavigationStack {
            
            TabView(selection: $store.selectedTab.sending(\.tabSelected))  {
                Tab("HOME",
                    image: store.selectedTab == .home ? "home_enabled" : "home_disabled",
                    value: RootContainer.Tab.home) {
                    HomeView(store: store.scope(state: \.home, action: \.home))
                        .tabBarDivider()
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
                        .tabBarDivider()
                }
                
                Tab("MY PAGE",
                    image: store.selectedTab == .myPage ? "my_enabled" : "my_disabled",
                    value: RootContainer.Tab.myPage) {
                    MyView(store: store.scope(state: \.my, action: \.my))
                        .tabBarDivider()
                }
            }
        }
        .overlay {
            if store.home.isLoadingRecommendations {
                Color.black.opacity(0.25)
                    .ignoresSafeArea()
                    .overlay {
                        VStack(spacing: 16) {
                            ProgressView()
                                .scaleEffect(1.5)
                                .tint(.gray0)

                            Text("오늘의 추천 미션 가져오는 중..")
                                .typography(.sub_b2_2)
                                .foregroundStyle(.gray0)
                        }
                    }
            }
        }
        .overlay {
            if let alertType = store.alertType {
                CustomAlertView(
                    alertType: alertType,
                    onCancel: {
                        store.send(.alertCanceled)
                    },
                    onConfirm: {
                        store.send(.alertConfirmed)
                    }
                )
                .transition(.opacity)
                .animation(.easeInOut(duration: 0.2), value: store.alertType)
            }
        }
    }
}

