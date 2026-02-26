//
//  RootContainer.swift
//  OMT
//
//  Created by 이인호 on 1/11/26.
//

import Foundation
import ComposableArchitecture
import Firebase

@Reducer
struct RootContainer {
    @ObservableState
    struct State: Equatable {
        var showSplash = true
        var currentView: ViewStatus
        var selectedTab: Tab = .home
        var alertType: AlertType?

        var login = LoginFeature.State()
        var onboarding: OnboardingFeature.State?
        var home = HomeFeature.State()
        var chat = ChatFeature.State()
        var report = ReportFeature.State()
        var my = MyFeature.State()

        var isLoggedIn: Bool {
            KeychainManager.shared.refreshToken != nil
        }

        init() {
            if KeychainManager.shared.refreshToken != nil {
                self.currentView = .home
            } else {
                self.currentView = .login
            }
        }
    }
    
    enum Action {
        case login(LoginFeature.Action)
        case onboarding(OnboardingFeature.Action)
        case home(HomeFeature.Action)
        case chat(ChatFeature.Action)
        case report(ReportFeature.Action)
        case my(MyFeature.Action)
        case tabSelected(Tab)
        case showAlert(AlertType)
        case alertCanceled
        case alertConfirmed
        case withdrawCompleted
        case logoutCompleted
        case splashAppeared
        case splashCompleted
        case splashDataFetched(CharacterDataDTO?, WeeklyReportsDataDTO?, MissionStatusDataDTO?)
    }
    
    enum ViewStatus: Hashable {
        case login
        case loginSuccess
        case onboarding
        case home
    }
    
    enum Tab {
        case home, chat, analysis, myPage
    }

    @Dependency(\.networkManager) var networkManager

    var body: some ReducerOf<Self> {
        Scope(state: \.login, action: \.login) {
            LoginFeature()
        }
        
        Scope(state: \.home, action: \.home) {
            HomeFeature()
        }
        
        Scope(state: \.chat, action: \.chat) {
            ChatFeature()
        }
        
        Scope(state: \.report, action: \.report) {
            ReportFeature()
        }
        
        Scope(state: \.my, action: \.my) {
            MyFeature()
        }
        
        Reduce { state, action in
            switch action {
            case .login(.delegate(.moveToHome)):
                state.currentView = .home
                state.selectedTab = .home
                state.onboarding = nil

            case .login(.delegate(.moveToLoginSuccess)):
                state.currentView = .loginSuccess

            case .login(.delegate(.moveToOnBoarding)):
                state.currentView = .onboarding
                state.onboarding = OnboardingFeature.State()

            case .onboarding(.delegate(.onboardingCompleted)):
                state.currentView = .home
                state.selectedTab = .home
                state.onboarding = nil

                //  온보딩 완료 후 알림 ON이면 FCM 토큰 저장
                let isNotificationOn = UserDefaults.standard.bool(forKey: "isNotificationOn")
                if isNotificationOn {
                    return .run { [networkManager] _ in
                        if let fcmToken = try? await Messaging.messaging().token() {
                            _ = try? await networkManager.requestNetwork(
                                dto: APIResponse<String>.self,
                                router: NotificationRouter.saveFCMToken(FCMTokenRequestDTO(fcmToken: fcmToken))
                            )
                        }
                    }
                }

            case let .tabSelected(tab):
                state.selectedTab = tab

            case .home(.delegate(.switchToAnalysisTab)):
                state.selectedTab = .analysis

            case let .home(.delegate(.switchToCompleteMode(mission))):
                state.selectedTab = .chat
                return .send(.chat(.sendCompleteMissionRequest(mission)))

            case .chat(.delegate(.missionCompleted)):
                state.selectedTab = .home

            case .my(.delegate(.showLogoutAlert)):
                state.alertType = .logout

            case .my(.delegate(.showWithdrawAlert)):
                state.alertType = .withdraw

            case let .showAlert(alertType):
                state.alertType = alertType

            case .alertCanceled:
                state.alertType = nil

            case .alertConfirmed:
                guard let alertType = state.alertType else { return .none }
                state.alertType = nil

                switch alertType {
                case .logout:
                    return .run { [networkManager] send in
                        // 로그아웃 시 FCM 토큰 삭제
                         _ = try? await networkManager.requestNetwork(
                            dto: APIResponse<String>.self,
                            router: NotificationRouter.deleteFCMToken
                        )
                        await send(.logoutCompleted)
                    }
                    
                case .withdraw:
                    return .run { [networkManager] send in
                        _ = try await networkManager.requestNetwork(
                            dto: WithdrawResponseDTO.self,
                            router: AuthRouter.withdraw
                        )
                        await send(.withdrawCompleted)
                    } catch: { error, _ in
                        print(error)
                    }
                    
                case .withdrawComplete:
                    KeychainManager.shared.deleteTokens()
                    UserDefaults.standard.removeObject(forKey: "isNotificationOn")
                    state.currentView = .login
                    state.my = MyFeature.State()
                    state.home = HomeFeature.State()
                    state.chat = ChatFeature.State()
                    state.report = ReportFeature.State()

                case .privacyConsentDeclined:
                    break
                }

            case .logoutCompleted:
                KeychainManager.shared.deleteTokens()
                UserDefaults.standard.removeObject(forKey: "isNotificationOn")
                state.currentView = .login
                state.my = MyFeature.State()
                state.home = HomeFeature.State()
                state.chat = ChatFeature.State()
                state.report = ReportFeature.State()

            case .withdrawCompleted:
                state.alertType = .withdrawComplete

            case .onboarding(.delegate(.privacyConsentWithdrawCompleted)):
                KeychainManager.shared.deleteTokens()
                UserDefaults.standard.removeObject(forKey: "isNotificationOn")
                state.currentView = .login
                state.onboarding = nil
                state.my = MyFeature.State()
                state.home = HomeFeature.State()
                state.chat = ChatFeature.State()
                state.report = ReportFeature.State()

            case .splashAppeared:
                let isLoggedIn = state.isLoggedIn
                return .run { [networkManager] send in
                    let startTime = Date()

                    if isLoggedIn {
                        let calendar = Calendar.mondayFirst
                        let today = Date()
                        let (year, month, weekOfMonth) = calendar.weekInfoFromFirstMonday(for: today)

                        let isNotificationOn: Bool

                        if UserDefaults.standard.object(forKey: "isNotificationOn") == nil {
                            // 재설치 케이스: onboarding fetch를 기존 호출들과 병렬로 실행
                            async let onboardingResponse = try? networkManager.requestNetwork(
                                dto: OnboardingResponseDTO.self,
                                router: OnboardingRouter.fetchOnboarding
                            )
                            async let characterResponse = try? networkManager.requestNetwork(
                                dto: CharacterResponseDTO.self,
                                router: CharacterRouter.fetchCharacter
                            )
                            async let weeklyResponse = try? networkManager.requestNetwork(
                                dto: WeeklyReportsResponseDTO.self,
                                router: ReportRouter.fetchWeeklyReports(year: year, month: month, weekOfMonth: weekOfMonth)
                            )
                            async let missionResponse = try? networkManager.requestNetwork(
                                dto: MissionStatusResponseDTO.self,
                                router: MissionRouter.dailyMissionStatus
                            )
                            let (onboarding, character, weekly, mission) = await (onboardingResponse, characterResponse, weeklyResponse, missionResponse)

                            let fetchedIsOn = onboarding?.data.map {
                                $0.remindEnabled && $0.checkinEnabled && $0.reviewEnabled
                            } ?? false
                            UserDefaults.standard.set(fetchedIsOn, forKey: "isNotificationOn")
                            isNotificationOn = fetchedIsOn

                            await send(.splashDataFetched(character?.data, weekly?.data, mission?.data))
                        } else {
                            async let characterResponse = try? networkManager.requestNetwork(
                                dto: CharacterResponseDTO.self,
                                router: CharacterRouter.fetchCharacter
                            )
                            async let weeklyResponse = try? networkManager.requestNetwork(
                                dto: WeeklyReportsResponseDTO.self,
                                router: ReportRouter.fetchWeeklyReports(year: year, month: month, weekOfMonth: weekOfMonth)
                            )
                            async let missionResponse = try? networkManager.requestNetwork(
                                dto: MissionStatusResponseDTO.self,
                                router: MissionRouter.dailyMissionStatus
                            )
                            let (character, weekly, mission) = await (characterResponse, weeklyResponse, missionResponse)

                            isNotificationOn = UserDefaults.standard.bool(forKey: "isNotificationOn")

                            await send(.splashDataFetched(character?.data, weekly?.data, mission?.data))
                        }

                        if isNotificationOn, let fcmToken = try? await Messaging.messaging().token() {
                            _ = try? await networkManager.requestNetwork(
                                dto: APIResponse<String>.self,
                                router: NotificationRouter.saveFCMToken(FCMTokenRequestDTO(fcmToken: fcmToken))
                            )
                        }
                    }

                    let elapsed = Date().timeIntervalSince(startTime)
                    let remaining = max(0, 1.5 - elapsed)

                    if remaining > 0 {
                        try? await Task.sleep(for: .seconds(remaining))
                    }

                    await send(.splashCompleted)
                }

            case .splashCompleted:
                state.showSplash = false

            case let .splashDataFetched(character, weekly, mission):
                if let character {
                    state.home.characterLevel = character.level
                    state.home.experiencePercent = character.experiencePercent
                    state.home.encouragementMessage = character.encouragementMessage
                }
                if let weekly {
                    state.home.thisWeekSuccessRate = weekly.thisWeekSuccessRate
                }
                if let mission {
                    state.home.hasActiveMission = mission.hasInProgressMission
                    state.home.hasCompletedMission = mission.hasCompletedMission
                    if mission.hasInProgressMission {
                        state.home.activeMission = mission.currentMission
                    }
                    if mission.hasCompletedMission {
                        state.home.completeMission = mission.missionResult
                    }
                }

            default:
                break
            }

            return .none
        }
        .ifLet(\.onboarding, action: \.onboarding) {
            OnboardingFeature()
        }
    }
}
