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
        var hasLoaded = false
        var nickname: String = ""
        var appGoalText: String = ""
        var isNotificationOn = false

        var availableStartTime: String = ""
        var availableEndTime: String = ""
        var minExerciseMinutes: Int = 0
        var preferredExercises: [String] = []
        var lifestyleType: LifestyleType = .regularDaytime
        
        var nicknameEditSheetPresented = false
        var nicknameEditText = ""

        var appGoalEditText = ""

        var selectedAvailableTime: WorkTimeOption?

        var originalAvailableTime: WorkTimeOption {
            WorkTimeOption(serverStartTime: availableStartTime)
        }

        var isAvailableTimeChanged: Bool {
            guard let selected = selectedAvailableTime else { return false }
            return selected != originalAvailableTime
        }

        var selectedLifestyleType: LifestyleType?

        var isLifestyleTypeChanged: Bool {
            guard let selected = selectedLifestyleType else { return false }
            return selected != lifestyleType
        }

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
        
        var isAppGoalValid: Bool {
            let text = appGoalEditText
            guard !text.isEmpty, text.count <= 15 else { return false }
            
            return true
        }
        
        var appGoalErrorMessage: String? {
            let text = appGoalEditText
            guard !text.isEmpty else { return nil }
            if text.count > 15 { return "입력할 수 있는 글자 수를 초과했어요." }
            return nil
        }
    }

    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case onAppear
        case fetchOnboardingResponse(OnboardingDataDTO)
        case notificationToggled(Bool)
        case logoutButtonTapped
        case nicknameEditSheetOpen
        case nicknameEditConfirmed
        case appGoalEditConfirmed
        case withdrawButtonTapped

        case editAvaliableTime
        case editMinExerciseMinutes
        case editPreferredExercises
        case editLifestyleType

        case availableTimeSelected(WorkTimeOption)
        case availableTimeEditConfirmed

        case lifestyleTypeSelected(LifestyleType)
        case lifestyleTypeEditConfirmed

        case delegate(Delegate)

        enum Delegate {
            case showLogoutAlert
            case showWithdrawAlert
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
            case .notice: return "icon_announcement"
            case .faq: return "icon_FAQ"
            case .contactUs: return "icon_question"
            case .privacyPolicy: return "icon_policy"
            case .termsOfService: return "icon_info"
            }
        }
    }
    
    enum ListItem: String, CaseIterable {
        case avaliableTime = "운동 가능 시간"
        case minExerciseMinutes = "미션에 투자할 수 있는 시간"
        case preferredExercises = "선호 운동"
        case lifestyleType = "평소 생활 패턴"
    }
    
    @Dependency(\.networkManager) var networkManager

    var body: some ReducerOf<Self> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .onAppear:
                guard !state.hasLoaded else { return .none }
                state.hasLoaded = true

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
                state.appGoalEditText = data.appGoalText
                state.isNotificationOn = data.remindEnabled && data.checkinEnabled && data.reviewEnabled
                state.availableStartTime = data.availableStartTime
                state.availableEndTime = data.availableEndTime
                state.minExerciseMinutes = data.minExerciseMinutes
                state.preferredExercises = data.preferredExercises
                state.lifestyleType = data.lifestyleType

            case .notificationToggled(let isOn):
                state.isNotificationOn = isOn
                
                return .run { [networkManager] _ in
                    let requestDTO = UpdateAlertRequestDTO(
                        remindEnabled: isOn,
                        checkinEnabled: isOn,
                        reviewEnabled: isOn
                    )
                    _ = try await networkManager.requestNetwork(
                        dto: OnboardingResponseDTO.self,
                        router: OnboardingRouter.updateAlert(requestDTO)
                    )
                } catch: { error, _ in
                    print(error)
                }

            case .logoutButtonTapped:
                return .send(.delegate(.showLogoutAlert))
                
            case .withdrawButtonTapped:
                return .send(.delegate(.showWithdrawAlert))

            case .nicknameEditSheetOpen:
                state.nicknameEditText = state.nickname
                state.nicknameEditSheetPresented = true

            case .nicknameEditConfirmed:
                let newNickname = state.nicknameEditText
                state.nickname = newNickname

                return .run { [networkManager] _ in
                    let requestDTO = UpdateNicknameRequestDTO(nickname: newNickname)
                    _ = try await networkManager.requestNetwork(
                        dto: OnboardingResponseDTO.self,
                        router: OnboardingRouter.updateNickname(requestDTO)
                    )
                } catch: { error, _ in
                    print(error)
                }

            case .appGoalEditConfirmed:
                let newAppGoal = state.appGoalEditText
                state.appGoalText = newAppGoal

                return .run { [networkManager] _ in
                    let requestDTO = UpdateAppGoalRequestDTO(appGoalText: newAppGoal)
                    _ = try await networkManager.requestNetwork(
                        dto: OnboardingResponseDTO.self,
                        router: OnboardingRouter.updateAppGoal(requestDTO)
                    )
                } catch: { error, _ in
                    print(error)
                }

            case .availableTimeSelected(let option):
                state.selectedAvailableTime = option

            case .availableTimeEditConfirmed:
                guard let selected = state.selectedAvailableTime else { return .none }
                state.availableStartTime = selected.startTime
                state.availableEndTime = selected.endTime
                state.selectedAvailableTime = nil

                return .run { [networkManager] _ in
                    let requestDTO = UpdateAvailableTimeRequestDTO(
                        availableStartTime: selected.startTime,
                        availableEndTime: selected.endTime
                    )
                    _ = try await networkManager.requestNetwork(
                        dto: OnboardingResponseDTO.self,
                        router: OnboardingRouter.updateAvailableTime(requestDTO)
                    )
                } catch: { error, _ in
                    print(error)
                }

            case .lifestyleTypeSelected(let type):
                state.selectedLifestyleType = type

            case .lifestyleTypeEditConfirmed:
                guard let selected = state.selectedLifestyleType else { return .none }
                state.lifestyleType = selected
                state.selectedLifestyleType = nil

                return .run { [networkManager] _ in
                    let requestDTO = UpdateLifestyleRequestDTO(lifestyleType: selected)
                    _ = try await networkManager.requestNetwork(
                        dto: OnboardingResponseDTO.self,
                        router: OnboardingRouter.updateLifestyle(requestDTO)
                    )
                } catch: { error, _ in
                    print(error)
                }

            default:
                break
            }
            
            return .none
        }
    }
}

