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
            HStack {
                Text(title)
                    .padding()
                    .frame(maxWidth: .infinity)
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(selected ? Color.blue : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(selected ? Color.blue : Color.clear, lineWidth: 1)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}
