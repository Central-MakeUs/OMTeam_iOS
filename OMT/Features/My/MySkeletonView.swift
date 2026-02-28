//
//  MySkeletonView.swift
//  OMT
//
//  Created by 이인호 on 2/24/26.
//

import SwiftUI

struct MySkeletonView: View {
    @State private var shimmerOffset: CGFloat = 0

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image("logo")
                    .padding(.vertical, 12)
                Spacer()
            }
            .padding(.bottom, 16)

            skeletonShapes
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
                    .mask(skeletonShapes)
                )

            Spacer()
        }
        .padding(.horizontal, 20)
    }

    private var skeletonShapes: some View {
        VStack(spacing: 0) {
            profileSkeleton
            goalSkeleton
            menuListSkeleton
        }
    }
}

extension MySkeletonView {
    private var profileSkeleton: some View {
        VStack(spacing: 16) {
            Circle()
                .fill(.gray3)
                .frame(width: 100, height: 100)

            Rectangle()
                .fill(.gray3)
                .frame(width: 60, height: 24)
                .clipShape(RoundedRectangle(cornerRadius: 32))
        }
        .padding(.bottom, 28)
    }
}

extension MySkeletonView {
    private var goalSkeleton: some View {
        VStack(spacing: 8) {
            HStack {
                Rectangle()
                    .fill(.gray3)
                    .frame(width: 222, height: 32)
                    .clipShape(RoundedRectangle(cornerRadius: 32))
                
                Spacer()
                
                Rectangle()
                    .fill(.gray3)
                    .frame(width: 68, height: 32)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            }
            
            Rectangle()
                .fill(.gray3)
                .frame(height: 91)
                .frame(maxWidth: .infinity)
                .background(.gray2)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .padding(.bottom, 36)
    }
}

extension MySkeletonView {
    private var menuListSkeleton: some View {
        VStack(spacing: 20) {
            ForEach(0..<4, id: \.self) { _ in
                Rectangle()
                    .fill(.gray3)
                    .frame(height: 32)
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 32))
            }
        }
        .padding(.bottom, 11)
    }
}

