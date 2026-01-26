//
//  CustomProgressBar.swift
//  OMT
//
//  Created by 이인호 on 1/21/26.
//

import SwiftUI

struct CustomProgressBar: View {
    let progress: Double  // 0.0 ~ 1.0
    let height: CGFloat = 16
    
    var body: some View {
        HStack {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: height / 2)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: height)

                    RoundedRectangle(cornerRadius: height / 2)
                        .fill(Color.blue)
                        .frame(width: geometry.size.width * progress, height: height)
                }
            }
            .frame(height: height)
            
            Text("\(Int(progress * 100))%")
                .typography(.h1)
                .foregroundColor(.primary)
        }
    }
}


struct CircularProgressBar: View {
    let progress: Double
    let lineWidth: CGFloat = 16
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    Color.blue,
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
            
            // 중앙 텍스트
            Text("\(Int(progress * 100))%")
                .typography(.h3)
                .foregroundColor(.primary)
        }
        .frame(width: 100, height: 100)
    }
}

