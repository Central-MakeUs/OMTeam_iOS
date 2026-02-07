//
//  MyView.swift
//  OMT
//
//  Created by 이인호 on 2/3/26.
//

import SwiftUI
import ComposableArchitecture

struct MyView: View {
    @Bindable var store: StoreOf<MyFeature>
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image("logo")
                    .padding(.vertical, 12)
                Spacer()
            }
            .padding(.bottom, 16)

            profile
            goal
            menuList
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .onAppear {
            store.send(.onAppear)
        }
        .alert("로그아웃", isPresented:  Binding(
            get: { store.showLogoutAlert },
            set: { _ in }
        )) {
            Button("취소", role: .cancel) {
                store.send(.logoutCanceled)
            }
            Button("로그아웃", role: .destructive) {
                store.send(.logoutConfirmed)
            }
        }
        .sheet(isPresented: $store.nicknameEditSheetPresented) {
            nicknameEditSheet
                .presentationDetents([.height(280)])
        }
    }
}

extension MyView {
    private var profile: some View {
        VStack(spacing: 16) {
            Image("profile")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .overlay(alignment: .bottomTrailing) {
                    Button {
                        store.send(.nicknameEditSheetOpen)
                    } label: {
                        Image("edit_nickname")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .offset(x: -5, y: -5)
                    }
                }

            Text(store.nickname)
                .typography(.h3)
                .foregroundStyle(.gray13)
        }
        .padding(.bottom, 28)
    }
}

extension MyView {
    private var goal: some View {
        VStack(spacing: 8) {
            HStack {
                Text("나의 목표")
                    .typography(.h4)
                    .foregroundStyle(.gray11)
                Spacer()
                Button {
                    
                } label: {
                    Text("수정하기")
                        .typography(.sub_btn3_enabled)
                        .foregroundStyle(.greenGray12)
                }
                .padding(10)
                .background(.primary7)
                .clipShape(RoundedRectangle(cornerRadius: 4))
            }
            
            HStack {
                Image("icon_exercise")
                Text(store.appGoalText)
                    .typography(.h3)
                    .foregroundStyle(.gray11)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 27)
            .frame(maxWidth: .infinity)
            .background(.gray2)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .padding(.bottom, 36)
    }
}

extension MyView {
    private var menuList: some View {
        VStack(spacing: 0) {
            ForEach(MyFeature.MenuItem.allCases, id: \.self) { item in
                VStack(spacing: 0) {
                    Group {
                        switch item {
                        case .notification:
                            alertSetting
                        case .logout:
                            logoutButton
                        default:
                            navigationCell(for: item)
                        }
                    }
                    .padding(.vertical, 18)
                    .padding(.horizontal, 12)
                    
                    if item != MyFeature.MenuItem.allCases.last {
                        Divider()
                    }
                }
            }
        }
        .padding(.bottom, 11)
    }
    
    private var alertSetting: some View {
        Toggle(isOn: $store.isNotificationOn.sending(\.notificationToggled)) {
            Text("알림 설정")
                .typography(.sub_b2_2)
                .foregroundStyle(.gray10)
        }
        .tint(.primary7)
    }
    
    private var logoutButton: some View {
        Button {
            store.send(.logoutButtonTapped)
        } label: {
            Text("로그아웃")
                .typography(.sub_b2_2)
                .foregroundStyle(.gray10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
        }
    }
    
    @ViewBuilder
    private func navigationCell(for item: MyFeature.MenuItem) -> some View {
        NavigationLink(destination: destinationView(for: item)) {
            Text(item.rawValue)
                .typography(.sub_b2_2)
                .foregroundStyle(.gray10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func destinationView(for item: MyFeature.MenuItem) -> some View {
        switch item {
        case .editProfile:
            Text("내정보수정")
        case .etc:
            EtcView()
        default:
            EmptyView()
        }
    }
}

extension MyView {
    private var nicknameEditSheet: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Spacer()
                Button {
                    store.send(.nicknameEditSheetClose)
                } label: {
                    Image("xmark")
                }
            }
            .padding(.bottom, 8)

            Text("닉네임 변경하기")
                .typography(.h3)
                .foregroundStyle(.gray11)
                .padding(.bottom, 8)

            Text("한글, 영어, 숫자를 사용하여 8글자 이내로 닉네임을 설정해주세요.")
                .typography(.sub_b2_4)
                .foregroundStyle(.gray8)
                .padding(.bottom, 16)

            TextField(
                "",
                text: $store.nicknameEditText,
                prompt: Text("닉네임을 입력해주세요. (최대 8글자)")
                    .typography(.sub_btn3_disabled)
                    .foregroundStyle(.gray6)
            )
            .padding()
            .typography(.sub_btn2_enabled)
            .foregroundStyle(.gray10)
            .background(.greenGray2)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(.greenGray4, lineWidth: 1)
            )
            .autocorrectionDisabled()

            if let errorMessage = store.nicknameErrorMessage {
                HStack {
                    Image("error_icon")
                    Text(errorMessage)
                        .typography(.sub_btn2_enabled)
                        .foregroundStyle(.error)
                }
                .padding(.top, 8)
            }

            Spacer()

            Button {
                store.send(.nicknameEditConfirmed)
            } label: {
                Text("변경하기")
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .typography(store.isNicknameValid ? .btn2_enabled : .btn2_disabled)
                    .foregroundColor(store.isNicknameValid ? .gray12 : .gray9)
                    .background(store.isNicknameValid ? .primary7 : .primary4)
                    .cornerRadius(12)
            }
            .disabled(!store.isNicknameValid)
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 20)
    }
}
