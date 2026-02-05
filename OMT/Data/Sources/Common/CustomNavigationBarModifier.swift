//
//  CustomNavigationBarModifier.swift
//  OMT
//
//  Created by 이인호 on 2/5/26.
//

import SwiftUI

struct CustomNavigationBarModifier<C: View, L: View, R: View>: ViewModifier {
    let centerView: () -> C
    let leftView: () -> L
    let rightView: () -> R
    let overlay: Bool

    init(
        @ViewBuilder centerView: @escaping () -> C = { EmptyView() },
        @ViewBuilder leftView: @escaping () -> L = { EmptyView() },
        @ViewBuilder rightView: @escaping () -> R = { EmptyView() },
        overlay: Bool = false,
    ) {
        self.centerView = centerView
        self.leftView = leftView
        self.rightView = rightView
        self.overlay = overlay
    }

    func body(content: Content) -> some View {
        Group {
            if overlay {
                ZStack(alignment: .top) {
                    content
                    
                    navBar
                }
            } else {
                VStack(spacing: 12) {
                    navBar
                    content
                }
            }
        }
        .navigationBarHidden(true)
    }
    
    @ViewBuilder
    private var navBar: some View {
        VStack(spacing: 0) {
            ZStack {
                HStack {
                    self.leftView()
                    
                    Spacer()
                    
                    self.rightView()
                }
                .padding(.leading, 20)
                .padding(.trailing, 20)
                
                HStack {
                    Spacer()
                    
                    self.centerView()
                    
                    Spacer()
                }
            }
            .padding(.vertical, 12)
            
            Rectangle()
                .fill(.gray3)
                .frame(height: 1)
            
        }
        .frame(maxWidth: .infinity)
    }
}

