//
//  EtcView.swift
//  OMT
//
//  Created by 이인호 on 2/5/26.
//

import SwiftUI

struct EtcView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            ForEach(MyFeature.EtcMenuItem.allCases, id: \.self) { item in
                NavigationLink(destination: destinationView(for: item)) {
                    HStack {
                        Image(item.iconName)
                        Text(item.rawValue)
                            .typography(.sub_b2_2)
                            .foregroundStyle(.gray10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .contentShape(Rectangle())
                    }
                }
                .buttonStyle(.plain)
                .padding(.vertical, 18)
                .padding(.horizontal, 12)
                
                if item != MyFeature.EtcMenuItem.allCases.last {
                    Divider()
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .customNavigationBar(
            centerView: {
                Text("기타")
                    .typography(.h2_2)
                    .foregroundStyle(.gray11)
            },
            leftView: {
                Button {
                    dismiss()
                } label: {
                    Image("arrow_back_01")
                }
            },
        )
    }
    
    @ViewBuilder
    private func destinationView(for item: MyFeature.EtcMenuItem) -> some View {
        switch item {
        case .notice:
            WebView(
                url: URL(string: "https://slashpage.com/omt-policy-terms/y9e1xp2x5p5p1m7k35vz?e=1&post=5r398nmnx4xyemvwje7y")!,
                title: "공지사항"
            )
        case .faq:
            WebView(
                url: URL(string: "https://slashpage.com/omt-policy-terms/ndvwx7287q7d7m3z6jpg?e=1")!,
                title: "FAQ"
            )
        case .contactUs:
            Text("문의하기")
        case .privacyPolicy:
            WebView(
                url: URL(string: "https://slashpage.com/omt-policy-terms/5r398nmnx6zxzmvwje7y")!,
                title: "개인정보 정책"
            )
        case .termsOfService:
            WebView(
                url: URL(string: "https://slashpage.com/omt-policy-terms")!,
                title: "이용약관"
            )
        }
    }
}

