//
//  OMTAlertView.swift
//  OMT
//
//  Created by 이인호 on 2/10/26.
//

import SwiftUI

enum OMTAlertType: Equatable {
    case logout
    case withdraw
    case withdrawComplete

    var title: String {
        switch self {
        case .logout:
            return "로그아웃"
        case .withdraw:
            return "탈퇴하기"
        case .withdrawComplete:
            return "다시 만나요"
        }
    }

    var message: String {
        switch self {
        case .logout:
            return "정말 로그아웃 하시겠어요?"
        case .withdraw:
            return "정말 탈퇴하시겠어요?\n탈퇴 시 모든 데이터가 삭제됩니다."
        case .withdrawComplete:
            return "회원 탈퇴가 완료되었습니다.\n그동안 이용해 주셔서 감사합니다."
        }
    }

    var confirmButtonTitle: String {
        switch self {
        case .logout:
            return "로그아웃"
        case .withdraw:
            return "탈퇴하기"
        case .withdrawComplete:
            return "확인"
        }
    }

    var showCancelButton: Bool {
        switch self {
        case .logout, .withdraw:
            return true
        case .withdrawComplete:
            return false
        }
    }

    var isDestructive: Bool {
        switch self {
        case .logout, .withdraw:
            return true
        case .withdrawComplete:
            return false
        }
    }
}

struct OMTAlertView: View {
    let alertType: OMTAlertType
    let onCancel: () -> Void
    let onConfirm: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture {
                    if alertType.showCancelButton {
                        onCancel()
                    }
                }

            VStack(spacing: 0) {
                Text(alertType.title)
                    .typography(.h3)
                    .foregroundStyle(.gray12)
                    .padding(.top, 28)
                    .padding(.bottom, 12)

                Text(alertType.message)
                    .typography(.sub_b2_2)
                    .foregroundStyle(.gray9)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 24)

                HStack(spacing: 12) {
                    if alertType.showCancelButton {
                        Button {
                            onCancel()
                        } label: {
                            Text("취소")
                                .typography(.btn2_enabled)
                                .foregroundStyle(.gray10)
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                                .background(.gray3)
                                .cornerRadius(10)
                        }
                    }

                    Button {
                        onConfirm()
                    } label: {
                        Text(alertType.confirmButtonTitle)
                            .typography(.btn2_enabled)
                            .foregroundStyle(alertType.isDestructive ? .gray0 : .gray12)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(alertType.isDestructive ? .error : .primary7)
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .frame(width: 300)
            .background(.gray0)
            .cornerRadius(16)
        }
    }
}

#Preview {
    OMTAlertView(
        alertType: .logout,
        onCancel: {},
        onConfirm: {}
    )
}
