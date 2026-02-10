//
//  EditMyInfoView.swift
//  OMT
//
//  Created by 이인호 on 2/10/26.
//

import SwiftUI
import ComposableArchitecture

struct EditMyInfoView: View {
    @Bindable var store: StoreOf<MyFeature>
    
    var body: some View {
        VStack {
            withdrawButton
        }
    }
}

extension EditMyInfoView {
    private var withdrawButton: some View {
        Button {
            store.send(.withdrawButtonTapped)
        } label: {
            Text("회원탈퇴")
        }
    }
}
