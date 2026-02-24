//
//  MissionRecommendSheetView.swift
//  OMT
//
//  Created by 이인호 on 2/9/26.
//

import SwiftUI
import ComposableArchitecture

struct MissionRecommendSheetView: View {
    @Bindable var store: StoreOf<MissionRecommendSheetFeature>
    @Environment(\.dismiss) private var dismiss

    private var isRefetching: Bool {
        store.isLoading && store.selectedRecommendation == nil
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Image("arrow_close")
                }
            }
            .padding(.top, 20)
            .padding(.bottom, 10)
            .padding(.trailing, 20)
            
            sheetHeader
                .padding(.horizontal, 20)
                .padding(.bottom, 12)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 10) {
                    ForEach(store.recommendations, id: \.recommendedMissionId) { recommendation in
                        MissionOptionCard(
                            recommendation: recommendation,
                            isSelected: store.selectedRecommendation?.recommendedMissionId == recommendation.recommendedMissionId
                        ) {
                            store.send(.recommendationSelected(recommendation))
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 2)
            }

            VStack(spacing: 0) {
                Rectangle()
                    .fill(.greenGray3)
                    .frame(height: 1)
                
                bottomButtons
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
            }
            .background(.greenGray1)
        }
        .background(.gray0)
        .overlay {
            if isRefetching {
                Color.black.opacity(0.25)
                    .ignoresSafeArea()
                    .overlay {
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(.gray0)
                    }
            }
        }
    }

    private var sheetHeader: some View {
        HStack(spacing: 8) {
            Image("icon_dart")
            Text("오늘 도전해볼 미션을 선택하세요!")
                .typography(.h2_1)
                .foregroundStyle(.gray13)
        }
    }

    private var bottomButtons: some View {
        HStack(spacing: 9) {
            Button {
                store.send(.refetchTapped)
            } label: {
                Text("다시 제안받기")
                    .typography(.btn2_enabled)
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .foregroundStyle(.greenGray9)
                    .background(.greenGray5)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .buttonStyle(.plain)
            .frame(width: 126)
            .disabled(store.isLoading)

            Button {
                store.send(.startMissionTapped)
            } label: {
                if store.isLoading && store.selectedRecommendation != nil {
                    ProgressView()
                        .tint(.gray12)
                        .frame(maxWidth: .infinity)
                        .padding()
                } else {
                    Text("미션 시작하기")
                        .typography(.btn2_enabled)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .foregroundStyle(store.selectedRecommendation != nil ? .gray12 : .gray9)
                        .background(store.selectedRecommendation != nil ? .primary7 : .primary4)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity)
            .disabled(store.selectedRecommendation == nil || store.isLoading)
        }
    }
}

struct MissionOptionCard: View {
    let recommendation: RecommendDTO
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(recommendation.mission.type == .exercise ? "운동 미션" : "식단 미션")
                        .typography(.sub_b4_2)
                        .padding(4)
                        .foregroundStyle(.secondary7)
                        .background(.secondary2)
                        .clipShape(RoundedRectangle(cornerRadius: 4))

                    Spacer()

                    difficultyStars(difficulty: recommendation.mission.difficulty)
                }

                Text(recommendation.mission.name)
                    .typography(.h3)
                    .foregroundStyle(.gray11)
                    .multilineTextAlignment(.leading)

                HStack(spacing: 8) {
                    HStack(spacing: 4) {
                        Image("icon_time")
                        Text("\(recommendation.mission.estimatedMinutes)분")
                    }
                    .typography(.sub_b4_2)
                    .foregroundStyle(.gray7)

                    HStack(spacing: 4) {
                        Image("icon_calories")
                        Text("\(recommendation.mission.estimatedCalories)kcal")
                    }
                    .typography(.sub_b4_2)
                    .foregroundStyle(.gray7)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? .primary1 : .gray1)
                    .strokeBorder(isSelected ? .primary3 : .gray3, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }

    private func difficultyStars(difficulty: Int) -> some View {
        HStack(spacing: 2) {
            ForEach(1...5, id: \.self) { index in
                Image(index <= difficulty ? "star_enabled" : "star_disabled")
            }
        }
    }
}
