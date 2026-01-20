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
        
        case sendLoginInfoToServer(type: SocialType, idToken: String)
        
        // 부모 피쳐
        case delegate(Delegate)
        
        enum Delegate {
            case moveToOnBoarding
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
                    
                    if let data = response.data, !data.onboardingCompleted {
                        await send(.delegate(.moveToOnBoarding))
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
