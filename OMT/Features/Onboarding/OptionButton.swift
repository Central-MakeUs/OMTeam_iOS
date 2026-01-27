//
//  OptionButton.swift
//  OMT
//
//  Created by 이인호 on 1/19/26.
//

import SwiftUI

struct OptionButton: View {
    let title: String
    let selected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .typography(selected ? .btn1_enabled : .btn1_disabled)
                .padding()
                .frame(maxWidth: .infinity)
                .foregroundStyle(selected ? .gray12 : .gray9)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(selected ? .primary4 : .primary1)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(selected ? .primary6 : .primary3, lineWidth: 1)
                )
                .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}
