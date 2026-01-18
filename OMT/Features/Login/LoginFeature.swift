//
//  LoginFeature.swift
//  OMT
//
//  Created by 이인호 on 1/11/26.
//

import Foundation
import ComposableArchitecture

@Reducer
struct LoginFeature {
    @ObservableState
    struct State: Equatable { }
    
    enum Action {
        case appleLoginTapped
        case kakaoLoginTapped
        case googleLoginTapped
        
        case sendAppleLoginInfoToServer(authCode: String, idToken: String)
        case sendLoginInfoToServer(type: SocialType, idToken: String)
        
        // 부모 피쳐
        case delegate(Delegate)
        
        enum Delegate {
            case moveToOnBoarding
        }
    }
    
    enum SocialType {
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
                    let result = try await authentication.appleLogin()
                    
                    await send(.sendAppleLoginInfoToServer(authCode: result.authorizationCode, idToken: result.idToken))
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

            case .sendLoginInfoToServer(let type, let idToken):
                return .run { send in
                    let response = try await networkManager.requestNetwork(
                        dto: LoginResponseDTO.self,
                        router: type == .kakao
                        ? AuthRouter.kakaoLogin(LoginRequestDTO(idToken: idToken))
                        : AuthRouter.googleLogin(LoginRequestDTO(idToken: idToken))
                    )
                    
                    if let data = response.data, data.onboardingCompleted {
                        await send(.delegate(.moveToOnBoarding))
                    }
                }
                
            case .sendAppleLoginInfoToServer(let authCode, let idToken):
                return .run { send in
                    let response = try await networkManager.requestNetwork(dto: LoginResponseDTO.self, router: AuthRouter.appleLogin(
                        AppleLoginRequestDTO(authorizationCode: authCode, idToken: idToken)
                    ))
                    
                    if let data = response.data, data.onboardingCompleted {
                        print(data)
                        await send(.delegate(.moveToOnBoarding))
                    }
                }
                
            default:
                break
            }
            
            return .none
        }
    }
}
