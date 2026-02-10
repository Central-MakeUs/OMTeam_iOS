//
//  View+Extension.swift
//  OMT
//
//  Created by 이인호 on 1/21/26.
//

import SwiftUI

extension View {
    
    func typography(_ style: Typography) -> some View {
        self
            .font(style.font)
            .lineSpacing(style.lineSpacing)
            .kerning(style.letterSpacing)
    }
    
    func tabBarDivider(color: Color = Color(uiColor: .greenGray3)) -> some View {
        self.overlay(
            VStack {
                Spacer()
                Rectangle()
                    .fill(color)
                    .frame(height: 1)
            }
            , alignment: .bottom
        )
    }
    
    func customNavigationBar<C: View, L: View, R: View>(
        @ViewBuilder centerView: @escaping () -> C = { EmptyView() },
        @ViewBuilder leftView: @escaping () -> L = { EmptyView() },
        @ViewBuilder rightView: @escaping () -> R = { EmptyView() },
        overlay: Bool = false,
        backgroundColor: Color? = nil
    ) -> some View {
        self.modifier(CustomNavigationBarModifier(centerView: centerView,
                                                 leftView: leftView,
                                                 rightView: rightView,
                                                 overlay: overlay,
                                                 backgroundColor: backgroundColor))
    }
}

