//
//  MyFeature.swift
//  OMT
//
//  Created by 이인호 on 2/3/26.
//

import Foundation
import ComposableArchitecture

@Reducer
struct MyFeature {
    @ObservableState
    struct State: Equatable {
        var isNotificationOn = false
        var showLogoutAlert = false
    }
    
    enum Action {
        case notificationToggled(Bool)
        case logoutButtonTapped
        case logoutConfirmed
        case logoutCanceled
        
        case delegate(Delegate)
        
        enum Delegate {
            case logout
        }
    }
    
    enum MenuItem: String, CaseIterable {
        case notification = "알림 설정"
        case editProfile = "내 정보 수정하기"
        case inquiry = "문의하기"
        case etc = "기타"
        case logout = "로그아웃"
    }
    
    @Dependency(\.networkManager) var networkManager
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .notificationToggled(let isOn):
                state.isNotificationOn = isOn
            
            case .logoutButtonTapped:
                state.showLogoutAlert = true
                
            case .logoutConfirmed:
                state.showLogoutAlert = false
                
            case .logoutCanceled:
                state.showLogoutAlert = false
                
            default:
                break
            }
            
            return .none
        }
    }
}

