//
//  LoginSuccessView.swift
//  OMT
//
//  Created by 이인호 on 2/3/26.
//

import SwiftUI
import ComposableArchitecture

struct LoginSuccessView: View {
    @Bindable var store: StoreOf<LoginFeature>
    
    var body: some View {
        VStack {
            Spacer()
            
            VStack(spacing: 40) {
                Image("linkSuccess")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 266, height: 263)
                
                VStack(spacing: 16) {
                    Text("계정 연동이 완료되었어요!")
                        .typography(.h1)
                        .foregroundStyle(.gray13)
                    
                    HStack(spacing: 0) {
                        Text("OMT")
                            .typography(.sub_b2_1)
                            .foregroundStyle(.primary8)
                        Text("와함께 건강한 습관을 만들어봐요")
                            .typography(.sub_b2_1)
                            .foregroundStyle(.gray10)
                    }
                }
            }
            
            Spacer()
            
            Button {
                store.send(.loginSuccessButtonTapped)
            } label: {
                Text("OMT 시작하기")
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .typography(.btn2_enabled)
                    .foregroundColor(.gray12)
                    .background(.primary7)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .padding(.horizontal, 20)
    }
}
