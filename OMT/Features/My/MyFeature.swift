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

        var nicknameEditSheetPresented = false
        var nicknameEditText = ""

        var isNicknameValid: Bool {
            let text = nicknameEditText
            guard !text.isEmpty, text.count <= 8 else { return false }
            let hasSpecialChar = text.range(of: "[^가-힣ㄱ-ㅎㅏ-ㅣa-zA-Z0-9]", options: .regularExpression) != nil
            return !hasSpecialChar
        }

        var nicknameErrorMessage: String? {
            let text = nicknameEditText
            guard !text.isEmpty else { return nil }
            if text.count > 8 { return "글자수를 초과했어요!" }
            let hasSpecialChar = text.range(of: "[^가-힣ㄱ-ㅎㅏ-ㅣa-zA-Z0-9]", options: .regularExpression) != nil
            if hasSpecialChar { return "특수문자는 입력할 수 없습니다." }
            return nil
        }
    }

    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case onAppear
        case fetchOnboardingResponse(OnboardingDataDTO)
        case notificationToggled(Bool)
        case logoutButtonTapped
        case logoutConfirmed
        case logoutCanceled
        case nicknameEditSheetOpen
        case nicknameEditSheetClose
        case nicknameEditConfirmed

        case delegate(Delegate)

        enum Delegate {
            case logout
        }
    }
    
    enum MenuItem: String, CaseIterable {
        case notification = "알림 설정"
        case editProfile = "내 정보 수정하기"
        case etc = "기타"
        case logout = "로그아웃"
    }
    
    enum EtcMenuItem: String, CaseIterable {
        case notice = "공지사항"
        case faq = "FAQ"
        case contactUs = "문의하기"
        case privacyPolicy = "개인정보 정책"
        case termsOfService = "이용약관"
        
        var iconName: String {
            switch self {
            case .notice: return "megaphone"
            case .faq: return ""
            case .contactUs: return "envelope"
            case .privacyPolicy: return "lock.shield"
            case .termsOfService: return "doc.text"
            }
        }
    }
    
    @Dependency(\.networkManager) var networkManager

    var body: some ReducerOf<Self> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .binding:
                return .none

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

            case .nicknameEditSheetOpen:
                state.nicknameEditText = state.nickname
                state.nicknameEditSheetPresented = true
                return .none

            case .nicknameEditSheetClose:
                state.nicknameEditSheetPresented = false
                return .none

            case .nicknameEditConfirmed:
                state.nickname = state.nicknameEditText
                state.nicknameEditSheetPresented = false
                // TODO: API call to update nickname
                return .none

            case .delegate:
                return .none
            }
        }
    }
}

