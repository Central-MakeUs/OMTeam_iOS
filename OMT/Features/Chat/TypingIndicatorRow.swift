//
//  TypingIndicatorRow.swift
//  OMT
//
//  Created by 이인호 on 2/11/26.
//

import SwiftUI

struct TypingIndicatorRow: View {
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            VStack(alignment: .leading) {
                HStack(spacing: 8) {
                    Image("profile")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)

                    Text("채팅봇")
                        .typography(.sub_b2_1)
                        .foregroundColor(.gray11)
                }

                HStack {
                    Image("icon_ellipsis")
                }
                .padding(16)
                .background(.gray2)
                .clipShape(
                    UnevenRoundedRectangle(
                        topLeadingRadius: 0,
                        bottomLeadingRadius: 12,
                        bottomTrailingRadius: 12,
                        topTrailingRadius: 12
                    )
                )
            }

            Spacer()
        }
    }
}
