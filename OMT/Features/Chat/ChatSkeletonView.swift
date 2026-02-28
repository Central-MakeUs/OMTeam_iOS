//
//  ChatSkeletonView.swift
//  OMT
//
//  Created by 이인호 on 2/24/26.
//

import SwiftUI

struct ChatSkeletonView: View {
    @State private var shimmerOffset: CGFloat = 0

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 12) {
                HStack {
                    Image("logo")
                        .padding(.vertical, 12)
                    Spacer()
                }
                .padding(.horizontal, 20)

                skeletonShapes
                    .padding(.horizontal, 20)
                    .overlay(
                        GeometryReader { geo in
                            LinearGradient(
                                colors: [.clear, .white.opacity(0.55), .clear],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                            .frame(width: geo.size.width * 0.4)
                            .offset(x: shimmerOffset)
                            .onAppear {
                                shimmerOffset = -(geo.size.width * 0.4)
                                withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
                                    shimmerOffset = geo.size.width * 1.2
                                }
                            }
                        }
                        .clipped()
                        .mask(skeletonShapes.padding(.horizontal, 20))
                    )

                Spacer()
            }

            messageInput
        }
    }

    private var skeletonShapes: some View {
        VStack(alignment: .leading, spacing: 20) {
            ForEach(0..<3, id: \.self) { _ in
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(.gray6)
                            .frame(width: 24, height: 24)

                        Rectangle()
                            .fill(.gray4)
                            .frame(width: 56, height: 16)
                            .clipShape(RoundedRectangle(cornerRadius: 32))
                    }

                    Rectangle()
                        .fill(.gray3)
                        .frame(width: 205, height: 48)
                        .clipShape(
                            UnevenRoundedRectangle(
                                topLeadingRadius: 0,
                                bottomLeadingRadius: 12,
                                bottomTrailingRadius: 12,
                                topTrailingRadius: 12
                            )
                        )
                }

                HStack {
                    Spacer()
                    Rectangle()
                        .fill(.gray3)
                        .frame(width: 205, height: 48)
                        .clipShape(
                            UnevenRoundedRectangle(
                                topLeadingRadius: 12,
                                bottomLeadingRadius: 12,
                                bottomTrailingRadius: 0,
                                topTrailingRadius: 12
                            )
                        )
                }
            }
        }
    }

    private var messageInput: some View {
        HStack(spacing: 8) {
            TextField(
                "",
                text: .constant(""),
                prompt: Text("메시지를 입력해주세요.")
                    .typography(.sub_b3_1)
                    .foregroundStyle(.gray7)
            )
            .padding(.horizontal, 12)
            .padding(.vertical, 15)
            .typography(.sub_btn2_enabled)
            .foregroundStyle(.gray10)
            .background(.gray0)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(.greenGray3, lineWidth: 1)
            )

            Image("arrow_up")
                .frame(width: 48, height: 48)
                .background(.primary7)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
        .background(.greenGray2)
        .allowsHitTesting(false)
    }
}

