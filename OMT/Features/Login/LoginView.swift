//
//  LoginView.swift
//  OMT
//
//  Created by 이인호 on 1/11/26.
//

import SwiftUI
import ComposableArchitecture

struct LoginView: View {
    let store: StoreOf<LoginFeature>
    
    var body: some View {
        VStack(spacing: 20) {
            Button {
                store.send(.appleLoginTapped)
            } label: {
                Text("애플 로그인")
            }
            
            Button {
                store.send(.kakaoLoginTapped)
            } label: {
                Text("카카오 로그인")
            }
        }
    }
}
