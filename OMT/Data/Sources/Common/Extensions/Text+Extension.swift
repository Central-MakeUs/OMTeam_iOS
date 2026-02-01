//
//  Text+Extension.swift
//  OMT
//
//  Created by 이인호 on 1/28/26.
//

import SwiftUI

extension Text {
    func typography(_ style: Typography) -> Text {
        self
            .font(style.font)
            .kerning(style.letterSpacing)
    }
}
