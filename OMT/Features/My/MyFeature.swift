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
        var nickname: String = ""
        var appGoalText: String = ""
        var isNotificationOn = false
        var showLogoutAlert = false
    }

    enum Action {
        case onAppear
        case fetchOnboardingResponse(OnboardingDataDTO)
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
            case .onAppear:
                return .run { [networkManager] send in
                    let response = try await networkManager.requestNetwork(
                        dto: OnboardingResponseDTO.self,
                        router: OnboardingRouter.fetchOnboarding
                    )
                    if let data = response.data {
                        await send(.fetchOnboardingResponse(data))
                    }
                } catch: { error, send in
                    print(error)
                }

            case .fetchOnboardingResponse(let data):
                state.nickname = data.nickname
                state.appGoalText = data.appGoalText
                state.isNotificationOn = data.remindEnabled && data.checkinEnabled && data.reviewEnabled
                return .none

            case .notificationToggled(let isOn):
                state.isNotificationOn = isOn
                return .none

            case .logoutButtonTapped:
                state.showLogoutAlert = true
                return .none

            case .logoutConfirmed:
                state.showLogoutAlert = false
                return .none

            case .logoutCanceled:
                state.showLogoutAlert = false
                return .none

            case .delegate:
                return .none
            }
        }
    }
}

