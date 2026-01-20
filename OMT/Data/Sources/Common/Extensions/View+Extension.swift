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
}

