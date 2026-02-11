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
        .sheet(isPresented: $store.nicknameEditSheetPresented) {
            NicknameEditSheetView(store: store)
                .presentationDetents([.height(365)])
                .presentationCornerRadius(32)
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
                    .buttonStyle(.plain)
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
                
                NavigationLink(destination: EditAppGoalView(store: store)) {
                    Text("수정하기")
                        .typography(.sub_btn3_enabled)
                        .foregroundStyle(.greenGray12)
                }
                .buttonStyle(.plain)
                .padding(10)
                .background(.primary7)
                .clipShape(RoundedRectangle(cornerRadius: 4))
            }
            
            HStack(spacing: 8) {
                Image("goal")
                Text(store.appGoalText)
                    .typography(.h3)
                    .foregroundStyle(.gray11)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 27)
            .frame(height: 91)
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
        .buttonStyle(.plain)
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
            EditMyInfoView(store: store)
        case .etc:
            EtcView()
        default:
            EmptyView()
        }
    }
}

struct NicknameEditSheetView: View {
    @Bindable var store: StoreOf<MyFeature>
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Image("arrow_close")
                }
            }
            .padding(.bottom, 16)

            VStack(alignment: .leading, spacing: 11) {
                Text("닉네임 변경하기")
                    .typography(.btn1_enabled)
                    .foregroundStyle(.gray12)

                HStack(spacing: 0) {
                    Text("새롭게 사용하실 닉네임")
                        .typography(.sub_btn3_enabled)
                        .foregroundStyle(.error)

                    Text("을 입력해주세요.")
                        .typography(.sub_btn3_enabled)
                        .foregroundStyle(.gray9)
                }
            }
            .padding(.bottom, 28)

            TextField(
                "",
                text: $store.nicknameEditText,
                prompt: Text("닉네임을 입력해주세요. (최대 8글자)")
                    .typography(.sub_btn3_disabled)
                    .foregroundStyle(.gray6)
            )
            .focused($isFocused)
            .padding()
            .frame(height: 60)
            .typography(.sub_btn2_enabled)
            .foregroundStyle(.gray10)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.greenGray2)
                    .strokeBorder(.greenGray4, lineWidth: 1)
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
                dismiss()
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
        .padding(.top, 20)
        .padding(.bottom, 10)
        .contentShape(Rectangle())
        .onTapGesture {
            isFocused = false
        }
    }
}
