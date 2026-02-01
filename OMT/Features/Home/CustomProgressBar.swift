//
//  CustomProgressBar.swift
//  OMT
//
//  Created by 이인호 on 1/21/26.
//

import SwiftUI

struct CustomProgressBar: View {
    let progress: Double  // 0.0 ~ 1.0
    let width: CGFloat = 270
    let height: CGFloat = 20
    
    var body: some View {
        HStack {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: height / 2)
                        .fill(.gray2)
                        .frame(height: height)

                    RoundedRectangle(cornerRadius: height / 2)
                        .fill(.primary5)
                        .frame(width: geometry.size.width * progress, height: height)
                }
            }
            .frame(width: width, height: height)
            
            Spacer()
            
            Text("\(Int(progress * 100))%")
                .typography(.sub_btn3_enabled)
                .foregroundColor(.gray13)
        }
    }
}


struct CircularProgressBar: View {
    let progress: Double
    let lineWidth: CGFloat = 15.3
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(.gray2, lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    .primary6,
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
            
            // 중앙 텍스트
            Text("\(Int(progress * 100))%")
                .typography(.b2)
                .foregroundColor(.primary9)
        }
        .frame(width: 82.7, height: 82.7)
    }
}
