//
//  CustomAlertView.swift
//  OMT
//
//  Created by 이인호 on 2/10/26.
//

import SwiftUI

struct CustomAlertView: View {
    let alertType: AlertType
    let onCancel: () -> Void
    let onConfirm: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.25)
                .ignoresSafeArea()
                .onTapGesture {
                    if alertType.showCancelButton {
                        onCancel()
                    }
                }

            VStack(spacing: 0) {
                Text(alertType.title)
                    .typography(.h2_2)
                    .foregroundStyle(.gray12)
                    .padding(.bottom, 28)

                Text(alertType.message)
                    .typography(.sub_b2_2)
                    .foregroundStyle(.gray9)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 52)

                HStack(spacing: 9) {
                    Button {
                        onConfirm()
                    } label: {
                        Text(alertType.confirmButtonTitle)
                            .typography(.btn4_enabled)
                            .foregroundStyle(alertType.isDestructive ? .greenGray9 : .gray12)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(alertType.isDestructive ? .greenGray5 : .primary7)
                            .cornerRadius(8)
                    }
                    
                    if alertType.showCancelButton {
                        Button {
                            onCancel()
                        } label: {
                            Text("취소하기")
                                .typography(.btn4_enabled)
                                .foregroundStyle(.gray12)
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                                .background(.primary7)
                                .cornerRadius(8)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 42)
            .padding(.bottom, 24)
            .frame(width: 335)
            .background(.gray0)
            .cornerRadius(12)
        }
    }
}
