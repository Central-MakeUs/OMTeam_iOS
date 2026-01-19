//
//  OMTApp.swift
//  OMT
//
//  Created by 이인호 on 12/26/25.
//

import SwiftUI
import ComposableArchitecture
import KakaoSDKCommon
import KakaoSDKAuth

@main
struct OMTApp: App {
    static let store = Store(initialState: RootContainer.State(login: LoginFeature.State())) {
        RootContainer()
    }
    
    init() {
        let kakaoNativeAppKey = Bundle.main.infoDictionary?["NATIVE_APP_KEY"] as? String ?? ""
        KakaoSDK.initSDK(appKey: kakaoNativeAppKey)
    }
    
    var body: some Scene {
        WindowGroup {
            RootView(store: OMTApp.store)
                .onOpenURL { url in
                    if AuthApi.isKakaoTalkLoginUrl(url) {
                        _ = AuthController.handleOpenUrl(url: url)
                    }
                }
        }
    }
}
