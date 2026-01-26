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
            VStack {
                topCalendar
                progressSection
            }
            
            Spacer()
            
            todayMission
            
            Spacer()
            
            analysisSummary
        }
        .padding(.horizontal)
        .padding(.top, 16)
        .padding(.bottom, 32)
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
                    .foregroundStyle(.black)
                    .backgroundStyle(.yellow)
                CustomProgressBar(progress: 0.6)
            }
        }
    }
}

extension HomeView {
    private var todayMission: some View {
        VStack(alignment: .leading) {
            Text("오늘의 미션")
            
            if store.user?.hasPersonalSetting == true {
                missionCard
            } else {
                emptyMission
            }
        }
    }
    
    private var missionCard: some View {
        VStack {
            missionInfo
            proposalButton
        }
        .padding()
        .background(.gray)
        .cornerRadius(16)
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
            VStack(alignment: .leading) {
                Text("미션 01")
                    .foregroundStyle(.yellow)
                    .backgroundStyle(.secondary)
                
                Text("채팅을 통해 미션을 받아보세요!")
            }
            
            Spacer()
            
            Button {
                
            } label: {
                Image(systemName: "checkmark.circle")
            }
        }
        .padding()
        .background(.white)
        .cornerRadius(16)
    }
    
    private var proposalButton: some View {
        Button {
            store.send(.missionChatTapped)
        } label: {
            Text("채팅으로 미션 제안받기")
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.primary5)
                )
                .contentShape(Rectangle())
        }
    }
}

extension HomeView {
    private var analysisSummary: some View {
        VStack(alignment: .leading) {
            Text("분석 요약")
            
            if let analysis = store.analysisData {
                analysisGraph
                analysisDetailButton
            } else {
                emptyAnalysis
            }
        }
    }
    
    private var analysisGraph: some View {
        HStack(alignment: .bottom) {
            CircularProgressBar(progress: 0.6)
            
            VStack(alignment: .leading) {
                Text("이번주에 미션 n개를 성공했어요!")
                Text("지금처럼 꾸준히 익어가면, 목표에 한 걸음 더 가까워질 거에요.")
            }
        }
    }
    
    private var analysisDetailButton: some View {
        Button {
            store.send(.analysisDetailTapped)
        } label: {
            Text("더 자세한 분석 보기")
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.primary5)
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

