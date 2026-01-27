//
//  HomeView.swift
//  OMT
//
//  Created by 이인호 on 1/21/26.
//

import SwiftUI
import ComposableArchitecture

struct HomeView: View {
    let store: StoreOf<HomeFeature>
    
    var body: some View {
        VStack(spacing: 0) {
            // 고정 텍스트
            Text("고정 헤더")
                .typography(.h2_1)
                .padding(.horizontal, 20)
                .padding(.top, 16)
            
            // 스크롤 가능한 영역
            ScrollView {
                VStack(spacing: 0) {
                    VStack {
                        topCalendar
                        progressSection
                    }
                    .padding(.bottom, 24)
                    
                    todayMission
                        .padding(.bottom, 48)
                    
                    analysisSummary
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
            }
        }
    }
}

extension HomeView {
    private var topCalendar: some View {
        HStack {
            ForEach(0..<7, id: \.self) { index in
                Circle()
            }
        }
    }
    
    private var progressSection: some View {
        VStack {
            Circle()
                .frame(width: 100, height: 100)
                .foregroundStyle(.gray)
            
            VStack(alignment: .leading) {
                Text("LEVEL 02")
                    .typography(.sub_b4_1)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 6)
                    .foregroundStyle(.gray10)
                    .background(.secondary1)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                
                CustomProgressBar(progress: 0.6)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
        }
    }
}

extension HomeView {
    private var todayMission: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("오늘의 미션")
                .typography(.h2_1)
            
            if store.user?.hasPersonalSetting == true {
                missionCard
            } else {
//                emptyMission
                missionCard
            }
        }
    }
    
    private var missionCard: some View {
        VStack(spacing: 16) {
            missionInfo
            proposalButton
        }
        .padding([.horizontal, .top], 12)
        .padding(.bottom, 14)
        .background(.greenGray2)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
    
    private var emptyMission: some View {
        HStack {
            Circle()
                .frame(width: 100, height: 100)
            
            VStack(alignment: .leading) {
                Text("아직 미션이 생성되지 않았어요!")
                Text("개인 설정을 완료하여 미션을 받아보세요.")
            }
        }
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
            
            Button {
                
            } label: {
                Image(systemName: "checkmark.circle")
            }
        }
        .padding([.horizontal, .top], 8)
        .padding(.bottom, 14)
        .background(.gray0)
        .cornerRadius(10)
    }
    
    private var proposalButton: some View {
        Button {
            store.send(.missionChatTapped)
        } label: {
            Text("채팅으로 미션 제안받기")
                .padding()
                .frame(maxWidth: .infinity)
                .typography(.btn2_disabled)
                .foregroundStyle(.gray9)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.primary4)
                )
                .contentShape(Rectangle())
        }
    }
}

extension HomeView {
    private var analysisSummary: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("분석 요약")
                .typography(.h2_1)
            
            if let analysis = store.analysisData {
                analysisCard
            } else {
//                emptyAnalysis
                analysisGraph
                analysisDetailButton
            }
        }
    }
    
    private var analysisCard: some View {
        VStack(spacing: 24) {
            analysisGraph
            analysisDetailButton
        }
    }
    
    private var analysisGraph: some View {
        HStack(alignment: .bottom, spacing: 16) {
            CircularProgressBar(progress: 0.6)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("이번주에 미션 n개를 성공했어요!")
                    .font(.paperlogySemiBold(size: 15))
                
                Text("지금처럼 꾸준히 익어가면, 목표에 한 걸음 더 가까워질 거에요.")
                    .typography(.sub_b3_2)
                    .lineLimit(nil)
            }
        }
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
                .typography(.btn2_disabled)
                .foregroundStyle(.gray9)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.primary4)
                )
                .contentShape(Rectangle())
        }
    }
    
    private var emptyAnalysis: some View {
        HStack {
            Circle()
                .frame(width: 100, height: 100)
            
            VStack(alignment: .leading) {
                Text("아직 분석할 데이터가 없어요!")
                Text("OMT와 함께 미션을 수행하며 데이터를 쌓아보아요!")
            }
        }
    }
}

