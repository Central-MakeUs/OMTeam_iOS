//
//  HomeView.swift
//  OMT
//
//  Created by 이인호 on 1/21/26.
//

import SwiftUI
import ComposableArchitecture

struct HomeView: View {
    @Bindable var store: StoreOf<HomeFeature>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 고정 로고
            Image("logo")
                .padding(.horizontal, 20)
                .padding(.vertical, 12)

            // 스크롤 가능한 영역
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    VStack(spacing: 0) {
                        topCalendar
                        progressSection
                    }
                    .padding(.bottom, 24)

                    todayMission
                        .padding(.bottom, 48)

                    analysisSummary
                }
            }
        }
        .onAppear {
            store.send(.onAppear)
        }
        .sheet(
            item: $store.scope(state: \.missionRecommendSheet, action: \.missionRecommendSheet)
        ) { sheetStore in
            MissionRecommendSheetView(store: sheetStore)
                .presentationDetents([.height(578)])
                .presentationCornerRadius(32)
        }
    }
}

extension HomeView {
    private var topCalendar: some View {
        HStack(spacing: 18) {
            ForEach(store.dailyResults.indices, id: \.self) { index in
                VStack {
                    let mission = store.dailyResults[index]

                    Image(mission.result.imageName)
                    Text(dayString(from: mission.date))
                        .typography(mission.result.font)
                        .foregroundStyle(mission.result.textColor)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(.gray1)
    }
    
    private var progressSection: some View {
        ZStack {
            Image("background")
                .resizable()
                .scaledToFill()
                .frame(height: 280)
            
            VStack(spacing: 0) {
                VStack(spacing: 21) {
                    Text(store.encouragementMessage)
                        .typography(.sub_b4_2)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .foregroundStyle(.gray11)
                        .background(
                            Capsule()
                                .fill(.gray0)
                        )
                    
                    Image(store.characterImageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 133)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("LEVEL \(String(format: "%02d", store.characterLevel))")
                        .typography(.sub_b4_1)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 6)
                        .foregroundStyle(.gray10)
                        .background(.secondary1)
                        .clipShape(RoundedRectangle(cornerRadius: 4))

                    CustomProgressBar(progress: Double(store.experiencePercent) / 100.0)
                }
                .padding(.horizontal, 8)
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
        }
    }
    
    private func dayString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
}

extension HomeView {
    private var todayMission: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image("icon_dart")
                Text("오늘의 미션")
                    .typography(.h2_1)
                    .foregroundStyle(.gray13)
            }
            
            missionCard
            
            // 개인 설정을 필수로 받아서 필요시 주석 해제
//            if store.user?.hasPersonalSetting == true {
//                missionCard
//            } else {
//                emptyMission
//            }
        }
        .padding(.horizontal, 20)
    }
    
    private var missionCard: some View {
        VStack(spacing: 16) {
            if store.hasActiveMission, let mission = store.activeMission {
                // In progress mission
                activeMissionInfo(mission: mission)
                completeButton
            } else if store.hasCompletedMission, let mission = store.completeMission {
                // Completed mission
                completedMissionInfo(mission: mission)
                anotherMissionButton
                    
            } else {
                // No mission
                missionInfo
                proposalButton
            }
        }
        .padding([.horizontal, .top], 12)
        .padding(.bottom, 14)
        .background(.greenGray2)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private func activeMissionInfo(mission: RecommendDTO) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 10) {
                Text(mission.mission.type == .exercise ? "운동 미션" : "식단 미션")
                    .typography(.sub_b4_2)
                    .padding(4)
                    .foregroundStyle(.secondary7)
                    .background(.secondary2)
                    .clipShape(RoundedRectangle(cornerRadius: 4))

                Text(mission.mission.name)
                    .typography(.sub_btn1_enabled)
                    .foregroundStyle(.gray11)
            }

            Spacer()
        }
        .padding([.horizontal, .top], 8)
        .padding(.bottom, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.gray0)
        .cornerRadius(10)
    }

    private func completedMissionInfo(mission: CompleteMissionDataDTO) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 10) {
                Text("미션 01")
                    .typography(.sub_b4_2)
                    .padding(4)
                    .foregroundStyle(.secondary7)
                    .background(.secondary2)
                    .clipShape(RoundedRectangle(cornerRadius: 4))

                Text("내일 다시 만나요!")
                    .typography(.sub_btn1_enabled)
                    .foregroundStyle(.gray8)
            }

            Spacer()

            if mission.result == "SUCCESS" {
                Image("icon_check")
            }
        }
        .padding([.horizontal, .top], 8)
        .padding(.bottom, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.gray0)
        .cornerRadius(10)
    }

    private var completeButton: some View {
        Button {
            store.send(.missionCompleteTapped)
        } label: {
            Text("미션 인증하기")
                .padding()
                .frame(maxWidth: .infinity)
                .typography(.btn2_enabled)
                .foregroundStyle(.gray12)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.primary7)
                )
                .contentShape(Rectangle())
        }
    }

    private var anotherMissionButton: some View {
        Button {
            store.send(.missionRecommendTapped)
        } label: {
            Text("다음 미션 제안받기")
                .padding()
                .frame(maxWidth: .infinity)
                .typography(.btn2_enabled)
                .foregroundStyle(.gray9)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.primary4)
                )
                .contentShape(Rectangle())
        }
        .disabled(true)
    }
    
    private var emptyMission: some View {
        HStack(spacing: 16) {
            Image("emptyMission")
                .resizable()
                .scaledToFit()
                .frame(width: 84, height: 84)
            
            VStack(alignment: .leading, spacing: 6) {
                Text("아직 미션이 생성되지 않았어요!")
                    .typography(.b1)
                    .foregroundStyle(.gray11)
                Text("개인 설정을 완료하여 미션을 받아보세요.")
                    .typography(.sub_b4_3)
                    .foregroundStyle(.gray9)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var missionInfo: some View {
        HStack {
            VStack(alignment: .leading, spacing: 10) {
                Text("미션 01")
                    .typography(.sub_b4_2)
                    .padding(4)
                    .foregroundStyle(.secondary7)
                    .background(.secondary2)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                
                Text("채팅을 통해 미션을 받아보세요!")
                    .typography(.sub_btn1_enabled)
                    .foregroundStyle(.gray8)
            }
            
            Spacer()
        }
        .padding([.horizontal, .top], 8)
        .padding(.bottom, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.gray0)
        .cornerRadius(10)
    }
    
    private var proposalButton: some View {
        Button {
            store.send(.missionRecommendTapped)
        } label: {
            Text("미션 제안받기")
                .padding()
                .frame(maxWidth: .infinity)
                .typography(.btn2_enabled)
                .foregroundStyle(.gray12)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.primary7)
                )
                .contentShape(Rectangle())
        }
    }
}

extension HomeView {
    private var analysisSummary: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image("icon_note")
                Text("분석 요약")
                    .typography(.h2_1)
                    .foregroundStyle(.gray13)
            }
            
            if store.totalSuccessCount > 0 {
                analysisCard
            } else {
                emptyAnalysis
            }
        }
        .padding(.horizontal, 20)
    }
    
    private var analysisCard: some View {
        VStack(spacing: 24) {
            analysisGraph
            analysisDetailButton
        }
    }
    
    private var analysisGraph: some View {
        HStack(alignment: .bottom, spacing: 16) {
            CircularProgressBar(progress: store.thisWeekSuccessRate / 100.0)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("이번주에 미션 \(store.totalSuccessCount)개를 성공했어요!")
                    .font(.paperlogySemiBold(size: 15))

                Text(store.overallFeedback)
                    .typography(.sub_b3_2)
                    .lineLimit(nil)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 4)
        .padding(.vertical, 8)
    }
    
    private var analysisDetailButton: some View {
        Button {
            store.send(.analysisDetailTapped)
        } label: {
            Text("더 자세한 분석 보기")
                .padding()
                .frame(maxWidth: .infinity)
                .typography(.btn2_enabled)
                .foregroundStyle(.gray12)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.primary7)
                )
                .contentShape(Rectangle())
        }
    }
    
    private var emptyAnalysis: some View {
        HStack(spacing: 16) {
            Image("emptyAnalysis")
                .resizable()
                .scaledToFit()
                .frame(width: 84, height: 84)
            
            VStack(alignment: .leading, spacing: 6) {
                Text("아직 분석할 데이터가 없어요!")
                    .typography(.b1)
                    .foregroundStyle(.gray11)
                Text("OMT와 함께 미션을 수행하며 데이터를 쌓아보아요!")
                    .typography(.sub_b4_3)
                    .foregroundStyle(.gray9)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
    }
}

