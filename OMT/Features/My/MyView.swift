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
            Spacer()
            menuList
        }
        .padding(.horizontal, 20)
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
    }
}

extension MyView {
    private var profile: some View {
        VStack(spacing: 16) {
            Image("profile")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
            
            Text("닉네임")
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
                Text("OMT와 함께 운동 습관 형성하기")
                    .typography(.h3)
                    .foregroundStyle(.gray11)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 27)
            .frame(maxWidth: .infinity)
            .background(.gray2)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
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
        case .inquiry:
            Text("문의하기")
        case .etc:
            Text("기타")
        default:
            EmptyView()
        }
    }
}

