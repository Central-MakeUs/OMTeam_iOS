//
//  LoginView.swift
//  OMT
//
//  Created by 이인호 on 1/11/26.
//

import SwiftUI
import ComposableArchitecture

struct LoginView: View {
    @Bindable var store: StoreOf<LoginFeature>
    
    var body: some View {
        ZStack {
            Color.primary2
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                VStack(spacing: 33) {
                    Image("loginCharacter")
                        .padding(.leading, 32)
                    
                    Text("OMT를 시작하려면 로그인이 필요해요 :)")
                        .typography(.sub_b1)
                        .foregroundStyle(.gray9)
                }
                Spacer()
                loginButtons
            }
        }
    }
}

extension LoginView {
    private var loginButtons: some View {
        VStack(spacing: 12) {
            Button {
                store.send(.appleLoginTapped)
            } label: {
                Image("applelogin")
            }
            
            Button {
                store.send(.kakaoLoginTapped)
            } label: {
                Image("kakaologin")
            }
            
            Button {
                store.send(.googleLoginTapped)
            } label: {
                Image("googlelogin")
            }
        }
        .padding(.bottom, 22)
    }
}
