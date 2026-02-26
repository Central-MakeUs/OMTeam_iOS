//
//  LoginFeature.swift
//  OMT
//
//  Created by 이인호 on 1/11/26.
//

import Foundation
import ComposableArchitecture
import Firebase

@Reducer
struct LoginFeature {
    @ObservableState
    struct State: Equatable { }
    
    enum Action {
        case appleLoginTapped
        case kakaoLoginTapped
        case googleLoginTapped
        case loginSuccessButtonTapped

        case sendLoginInfoToServer(type: SocialType, idToken: String)

        // 부모 피쳐
        case delegate(Delegate)

        enum Delegate {
            case moveToLoginSuccess
            case moveToOnBoarding
            case moveToHome
        }
    }
    
    enum SocialType {
        case apple
        case kakao
        case google
    }
    
    @Dependency(\.authentication) var authentication
    @Dependency(\.networkManager) var networkManager
    
    var body: some ReducerOf<Self> {
        Reduce {
            state,
            action in
            switch action {
            case .appleLoginTapped:
                return .run { send in
                    let idToken = try await authentication.appleLogin()
                    
                    await send(.sendLoginInfoToServer(type: .apple, idToken: idToken))
                }
                
            case .kakaoLoginTapped:
                return .run { send in
                    let idToken = try await authentication.kakaoLogin()
                    
                    await send(.sendLoginInfoToServer(type: .kakao, idToken: idToken))
                }
                
            case .googleLoginTapped:
                return .run { send in
                    let idToken = try await authentication.googleLogin()
                    
                    await send(.sendLoginInfoToServer(type: .google, idToken: idToken))
                }

            case .loginSuccessButtonTapped:
                return .send(.delegate(.moveToOnBoarding))

            case .sendLoginInfoToServer(let type, let idToken):
                return .run { send in
                    let router: AuthRouter = switch type {
                    case .apple:
                            .appleLogin(LoginRequestDTO(idToken: idToken))
                    case .kakao:
                            .kakaoLogin(LoginRequestDTO(idToken: idToken))
                    case .google:
                            .googleLogin(LoginRequestDTO(idToken: idToken))
                    }

                    let response = try await networkManager.requestNetwork(
                        dto: LoginResponseDTO.self,
                        router: router
                    )

                    if let data = response.data {
                        KeychainManager.shared.save(
                            accessToken: data.accessToken,
                            refreshToken: data.refreshToken
                        )

                        if data.onboardingCompleted {
                            let isNotificationOn: Bool

                            if UserDefaults.standard.object(forKey: "isNotificationOn") == nil {
                                // 재설치 또는 로그아웃 후 재로그인 시 서버에서 알림 설정 1회 fetch
                                let onboarding = try? await networkManager.requestNetwork(
                                    dto: OnboardingResponseDTO.self,
                                    router: OnboardingRouter.fetchOnboarding
                                )
                                let fetchedIsOn = onboarding?.data.map {
                                    $0.remindEnabled && $0.checkinEnabled && $0.reviewEnabled
                                } ?? false
                                UserDefaults.standard.set(fetchedIsOn, forKey: "isNotificationOn")
                                isNotificationOn = fetchedIsOn
                            } else {
                                isNotificationOn = UserDefaults.standard.bool(forKey: "isNotificationOn")
                            }

                            if isNotificationOn, let fcmToken = try? await Messaging.messaging().token() {
                                _ = try? await networkManager.requestNetwork(
                                    dto: APIResponse<String>.self,
                                    router: NotificationRouter.saveFCMToken(FCMTokenRequestDTO(fcmToken: fcmToken))
                                )
                            }
                            await send(.delegate(.moveToHome))
                        } else {
                            await send(.delegate(.moveToLoginSuccess))
                        }
                    }
                } catch: { error, send in
                    print(error, send)
                }

            default:
                break
            }
            
            return .none
        }
    }
}
