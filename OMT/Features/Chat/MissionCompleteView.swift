//
//  MissionCompleteView.swift
//  OMT
//
//  Created by 이인호 on 2/7/26.
//

import SwiftUI
import ComposableArchitecture

struct MissionCompleteView: View {
    @Bindable var store: StoreOf<ChatFeature>

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                List {
                    // Assistant message asking about result
                    resultQuestionMessage
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                        .listRowBackground(Color.clear)

                    // User selection message
                    if let result = store.selectedResult {
                        userResultMessage(result: result)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                            .listRowBackground(Color.clear)
                            .id("userResult")

                        // Assistant response with complete button
                        completeConfirmMessage(result: result)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                            .listRowBackground(Color.clear)
                            .id("completeButton")
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .onChange(of: store.selectedResult) { _, _ in
                    withAnimation {
                        proxy.scrollTo("completeButton", anchor: .bottom)
                    }
                }
            }
        }
        .customNavigationBar(
            centerView: {
                Text("미션 완료")
                    .typography(.h2_2)
                    .foregroundStyle(.gray11)
            }
        )
    }

    // MARK: - Assistant message asking about result
    private var resultQuestionMessage: some View {
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
                    if let mission = store.currentMission {
                        Text("\(mission.mission.name) 미션은 잘 마쳤나요?")
                            .typography(.sub_b2_4)
                            .foregroundColor(.gray12)
                    } else {
                        Text("미션은 잘 마쳤나요?")
                            .typography(.sub_b2_4)
                            .foregroundColor(.gray12)
                    }

                    VStack(spacing: 10) {
                        // Success button
                        Button {
                            if store.selectedResult == nil {
                                store.send(.resultSelected("SUCCESS"))
                            }
                        } label: {
                            Text("성공했어요")
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
                        .allowsHitTesting(store.selectedResult == nil)
                        .buttonStyle(PlainButtonStyle())

                        // Fail button
                        Button {
                            if store.selectedResult == nil {
                                store.send(.resultSelected("FAILURE"))
                            }
                        } label: {
                            Text("실패했어요")
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
                        .allowsHitTesting(store.selectedResult == nil)
                        .buttonStyle(PlainButtonStyle())
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

    // MARK: - User result message
    private func userResultMessage(result: String) -> some View {
        HStack(alignment: .bottom, spacing: 8) {
            Spacer()
            Text(result == "SUCCESS" ? "성공했어요" : "실패했어요")
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

    // MARK: - Complete confirm message
    private func completeConfirmMessage(result: String) -> some View {
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
                    if result == "SUCCESS" {
                        Text("미션을 성공하셨군요! 수고하셨습니다.")
                            .typography(.sub_b2_4)
                            .foregroundColor(.gray12)
                    } else {
                        Text("다음에는 더 잘할 수 있을 거예요!")
                            .typography(.sub_b2_4)
                            .foregroundColor(.gray12)
                    }

                    Button {
                        store.send(.backToHome)
                    } label: {
                        Text("홈으로 돌아가기")
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

