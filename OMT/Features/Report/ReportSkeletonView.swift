//
//  ReportSkeletonView.swift
//  OMT
//
//  Created by 이인호 on 2/24/26.
//

import SwiftUI

struct ReportSkeletonView: View {
    @State private var shimmerOffset: CGFloat = 0

    var body: some View {
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
    }

    private var skeletonShapes: some View {
        VStack(spacing: 12) {
            VStack(spacing: 20) {
                HStack {
                    Rectangle()
                        .fill(.gray4)
                        .frame(width: 226, height: 20)
                        .clipShape(RoundedRectangle(cornerRadius: 32))

                    Spacer()

                    Circle()
                        .fill(.gray4)
                        .frame(width: 24, height: 24)
                }

                successRateSkeletonCard
                topDifficultiesSkeletonCard
                recommendSkeletonCard
            }
            .padding(.bottom, 16)

            Rectangle()
                .fill(.gray4)
                .frame(height: 56)
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}

extension ReportSkeletonView {
    private var successRateSkeletonCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 16) {
                Circle()
                    .fill(.gray5)
                    .frame(width: 56, height: 56)

                VStack(alignment: .leading, spacing: 8) {
                    Rectangle()
                        .fill(.gray5)
                        .frame(width: 160, height: 18)
                        .clipShape(RoundedRectangle(cornerRadius: 32))

                    Rectangle()
                        .fill(.gray5)
                        .frame(width: 56, height: 22)
                        .clipShape(RoundedRectangle(cornerRadius: 32))
                }
            }
            .padding(.vertical, 10)
            .padding(.leading, 7.5)
            .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 12) {
                ForEach(0..<7, id: \.self) { _ in
                    Circle()
                        .fill(.gray5)
                        .frame(width: 32, height: 32)
                }
            }
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
        }
        .padding(.top, 4)
        .padding(.bottom, 8)
        .padding(.horizontal, 12)
        .background(.gray4)
        .cornerRadius(12)
    }
}

extension ReportSkeletonView {
    private var topDifficultiesSkeletonCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 8) {
                Circle()
                    .fill(.gray5)
                    .frame(width: 24, height: 24)

                Rectangle()
                    .fill(.gray5)
                    .frame(width: 272, height: 18)
                    .clipShape(RoundedRectangle(cornerRadius: 32))
            }

            ForEach(0..<2, id: \.self) { _ in
                HStack(spacing: 16) {
                    Circle()
                        .fill(.gray5)
                        .frame(width: 20, height: 20)

                    Rectangle()
                        .fill(.gray5)
                        .frame(width: 200, height: 18)
                        .clipShape(RoundedRectangle(cornerRadius: 32))
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.gray4)
        .cornerRadius(12)
    }
}

extension ReportSkeletonView {
    private var recommendSkeletonCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Rectangle()
                    .fill(.gray5)
                    .frame(width: 32, height: 32)
                    .clipShape(RoundedRectangle(cornerRadius: 6))

                Rectangle()
                    .fill(.gray5)
                    .frame(width: 88, height: 22)
                    .clipShape(RoundedRectangle(cornerRadius: 32))
            }

            Rectangle()
                .fill(.gray5)
                .frame(width: 304, height: 18)
                .clipShape(RoundedRectangle(cornerRadius: 32))

            Rectangle()
                .fill(.gray5)
                .frame(width: 304, height: 18)
                .clipShape(RoundedRectangle(cornerRadius: 32))
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.gray4)
        .cornerRadius(12)
    }
}

