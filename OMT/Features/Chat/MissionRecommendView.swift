//
//  MissionRecommendView.swift
//  OMT
//
//  Created by 이인호 on 2/7/26.
//

import SwiftUI
import ComposableArchitecture

struct MissionRecommendView: View {
    let store: StoreOf<ChatFeature>

    var body: some View {
        VStack(spacing: 0) {
            if store.isLoading && store.recommendations.isEmpty {
                Spacer()
                ProgressView()
                Spacer()
            } else {
                ScrollViewReader { proxy in
                    List {
                        // Assistant message with recommendation options
                        recommendationMessage
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                            .listRowBackground(Color.clear)

                        // User selection message
                        if let selected = store.selectedRecommendation {
                            userSelectionMessage(selected: selected)
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                                .listRowBackground(Color.clear)
                                .id("userSelection")

                            // Assistant response with start button
                            if store.showStartMissionButton {
                                startMissionMessage(selected: selected)
                                    .listRowSeparator(.hidden)
                                    .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                                    .listRowBackground(Color.clear)
                                    .id("startButton")
                            }
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .onChange(of: store.selectedRecommendation) { _, _ in
                        withAnimation {
                            proxy.scrollTo("startButton", anchor: .bottom)
                        }
                    }
                }
            }
        }
        .customNavigationBar(
            centerView: {
                Text("미션 추천")
                    .typography(.h2_2)
                    .foregroundStyle(.gray11)
            }
        )
    }

    // MARK: - Assistant message with recommendation options
    private var recommendationMessage: some View {
        HStack(alignment: .bottom, spacing: 8) {
            VStack(alignment: .leading) {
                HStack {
                    Image("profile")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)

                    Text("채팅봇")
                }

                VStack(alignment: .leading, spacing: 20) {
                    Text("오늘의 미션을 추천해 드릴게요! 아래에서 원하는 미션을 선택해주세요.")
                        .typography(.sub_b2_4)
                        .foregroundColor(.gray12)

                    VStack(spacing: 10) {
                        ForEach(store.recommendations) { recommendation in
                            Button {
                                if store.selectedRecommendation == nil {
                                    store.send(.recommendSelected(recommendation))
                                }
                            } label: {
                                Text(recommendation.mission.name)
                                    .typography(.btn2_enabled)
                                    .lineLimit(nil)
                                    .multilineTextAlignment(.center)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 10)
                                    .frame(maxWidth: .infinity)
                                    .foregroundColor(.gray12)
                                    .background(
                                        Capsule()
                                            .fill(.primary2)
                                    )
                                    .overlay(
                                        Capsule()
                                            .stroke(.primary3, lineWidth: 1)
                                    )
                            }
                            .allowsHitTesting(store.selectedRecommendation == nil)
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 11)
                .background(.gray2)
                .clipShape(
                    UnevenRoundedRectangle(
                        topLeadingRadius: 0,
                        bottomLeadingRadius: 12,
                        bottomTrailingRadius: 12,
                        topTrailingRadius: 12
                    )
                )
                .frame(maxWidth: 250, alignment: .leading)
            }
            Spacer()
        }
    }

    // MARK: - User selection message
    private func userSelectionMessage(selected: Recommendation) -> some View {
        HStack(alignment: .bottom, spacing: 8) {
            Spacer()
            Text(selected.mission.name)
                .typography(.sub_b2_4)
                .padding(.horizontal, 12)
                .padding(.vertical, 11)
                .foregroundColor(.gray12)
                .background(.primary5)
                .clipShape(
                    UnevenRoundedRectangle(
                        topLeadingRadius: 12,
                        bottomLeadingRadius: 12,
                        bottomTrailingRadius: 0,
                        topTrailingRadius: 12
                    )
                )
                .frame(maxWidth: 250, alignment: .trailing)
        }
    }

    // MARK: - Start mission message
    private func startMissionMessage(selected: Recommendation) -> some View {
        HStack(alignment: .bottom, spacing: 8) {
            VStack(alignment: .leading) {
                HStack {
                    Image("profile")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)

                    Text("채팅봇")
                }

                VStack(alignment: .leading, spacing: 20) {
                    Text("\(selected.mission.name) 미션을 선택하셨네요! 미션이 끝나면 다시 알려주세요.")
                        .typography(.sub_b2_4)
                        .foregroundColor(.gray12)

                    Button {
                        store.send(.startMissionTapped)
                    } label: {
                        if store.isLoading {
                            ProgressView()
                                .tint(.gray12)
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                        } else {
                            Text("미션 시작하기")
                                .typography(.btn2_enabled)
                                .lineLimit(nil)
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .frame(maxWidth: .infinity)
                                .foregroundColor(.gray12)
                                .background(.primary7)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    .disabled(store.isLoading)
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 11)
                .background(.gray2)
                .clipShape(
                    UnevenRoundedRectangle(
                        topLeadingRadius: 0,
                        bottomLeadingRadius: 12,
                        bottomTrailingRadius: 12,
                        topTrailingRadius: 12
                    )
                )
                .frame(maxWidth: 250, alignment: .leading)
            }
            Spacer()
        }
    }
}

