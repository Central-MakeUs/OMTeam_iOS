//
//  HealthSourcesFooter.swift
//  OMT
//
//  Created by 이인호 on 2/18/26.
//

import SwiftUI

struct HealthSourceInfoButton: View {
    @Environment(\.openURL) private var openURL
    @State private var showSources = false

    private let exerciseURL = URL(string: "https://www.who.int/news-room/fact-sheets/detail/physical-activity")!
    private let dietURL = URL(string: "https://www.who.int/news-room/fact-sheets/detail/healthy-diet")!

    var body: some View {
        Button {
            showSources.toggle()
        } label: {
            Image("icon_question")
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
        }
        .buttonStyle(.plain)
        .popover(isPresented: $showSources, arrowEdge: .top) {
            VStack(alignment: .leading, spacing: 12) {
                Text("건강정보 출처")
                    .typography(.sub_b2_1)
                    .foregroundStyle(.gray11)

                Button {
                    openURL(exerciseURL)
                } label: {
                    HStack(spacing: 6) {
                        Text("WHO 신체활동 가이드라인")
                            .typography(.sub_b3_1)
                            .foregroundStyle(.primary8)
                            .underline()
                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 10))
                            .foregroundStyle(.primary8)
                    }
                }
                .buttonStyle(.plain)

                Button {
                    openURL(dietURL)
                } label: {
                    HStack(spacing: 6) {
                        Text("WHO 건강한 식단 가이드라인")
                            .typography(.sub_b3_1)
                            .foregroundStyle(.primary8)
                            .underline()
                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 10))
                            .foregroundStyle(.primary8)
                    }
                }
                .buttonStyle(.plain)
            }
            .padding(16)
            .presentationCompactAdaptation(.popover)
        }
    }
}
