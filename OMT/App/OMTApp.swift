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
    static let store = Store(initialState: AppFeature.State.login(LoginFeature.State())) {
        AppFeature()
    }
    
    init() {
        let kakaoNativeAppKey = Bundle.main.infoDictionary?["NATIVE_APP_KEY"] as? String ?? ""
        KakaoSDK.initSDK(appKey: kakaoNativeAppKey)
    }
    
    var body: some Scene {
        WindowGroup {
            AppView(store: OMTApp.store)
        }
    }
}
