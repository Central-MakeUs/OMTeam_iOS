//
//  ReportView.swift
//  OMT
//
//  Created by 이인호 on 1/26/26.
//

import SwiftUI
import ComposableArchitecture

struct ReportView: View {
    let store: StoreOf<ReportFeature>

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 12) {
                Image("logo")
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                
                if !store.hasReport {
                    VStack {
                        HStack {
                            weekNavigationHeader
                            Spacer()
                            Button {
                                
                            } label: {
                                Image("refresh")
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                } else {
                    VStack(spacing: 28) {
                        VStack(spacing: 20) {
                            HStack {
                                weekNavigationHeader
                                Spacer()
                                Button {
                                    
                                } label: {
                                    Image("refresh")
                                }
                            }
                            
                            successRateCard
                            topDifficultiesCard
                            recommendCard
                        }
                        
                        Spacer()
                        
                        analysisDetailButton
                    }
                    .padding(.horizontal, 20)
                }
            }
            .background(.gray2)
            
            // 데이터 없을 때만 중앙에 표시
            if !store.hasReport {
                emptyReport
            }
            
            if store.isDatePickerPresented {
                DatePickerModal(store: store)
            }
        }
        .onAppear {
            store.send(.onAppear)
        }
    }
}

extension ReportView {
    private var weekNavigationHeader: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Button {
                    store.send(.previousWeekTapped)
                } label: {
                    Image("arrow_back_02")
                }
                
                Button {
                    store.send(.dateTapped)
                } label: {
                    HStack(spacing: 4) {
                        Text(store.displayText)
                            .typography(.sub_btn2_enabled)
                            .foregroundStyle(.gray11)
                        
                        Image("down")
                    }
                }
                
                Button {
                    store.send(.nextWeekTapped)
                } label: {
                    Image("arrow_forth")
                }
            }
        }
    }
}

extension ReportView {
    private var successRateCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 16) {
                Image("icon_dart")
                    .resizable()
                    .frame(width: 56, height: 56)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("이번주 미션 성공률")
                        .foregroundStyle(.gray10)

                    Text("\(Int(store.thisWeekSuccessRate))%")
                        .typography(.h1)
                        .foregroundStyle(.gray13)
                }
            }
            .padding(.vertical, 10)
            .padding(.leading, 7.5)
            .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 12) {
                ForEach(store.dailyResults, id: \.date) { mission in
                    let weekday = Calendar.current.component(.weekday, from: mission.date)
                    let dayName = Calendar.current.shortWeekdaySymbols[weekday - 1]
                    VStack(spacing: 12) {
                        Text(dayName)
                            .typography(mission.result.font)
                            .foregroundStyle(mission.result.textColor)
                        Image(mission.result.imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 32, height: 32)
                    }
                }
            }
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
        }
        .padding(.top, 4)
        .padding(.bottom, 8)
        .padding(.horizontal, 12)
        .background(.white)
        .cornerRadius(16)
    }
}

extension ReportView {
    private var topDifficultiesCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 8) {
                Image("icon_good")
                
                Text("미션이 힘들었던 이유를 살펴봤어요!")
                    .typography(.h4)
                    .foregroundStyle(.gray11)
            }
            
            if store.topDifficulties.isEmpty {
                Text("데이터가 없음")
            } else {
                ForEach(store.topDifficulties, id: \.self) { difficulty in
                    Text(difficulty)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white)
        .cornerRadius(16)
    }
}

extension ReportView {
    private var recommendCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("OMT의 제안")
                .typography(.h3)
                .foregroundStyle(.gray11)
            
            Text(store.overallFeedback)
                .typography(.sub_b2_2)
                .foregroundStyle(.gray10)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white)
        .cornerRadius(16)
    }
}

extension ReportView {
    private var analysisDetailButton: some View {
        NavigationLink {
            DetailReportView(store: store)
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
        }
        .padding(.bottom, 28)
    }
}


extension ReportView {
    private var emptyReport: some View {
        VStack(spacing: 43) {
            Image("emptyReport")
                .resizable()
                .scaledToFit()
                .frame(width: 212, height: 186)
            
            VStack(spacing: 16) {
                Text("아직 분석할 데이터가 없어요!")
                    .typography(.h1)
                    .foregroundStyle(.gray13)
                
                HStack(spacing: 0) {
                    Text("OMT")
                        .typography(.sub_b2_1)
                        .foregroundStyle(.primary8)
                    Text("와 함께 건강한 습관을 만들어봐요")
                        .typography(.sub_b2_1)
                        .foregroundStyle(.gray10)
                }
            }
        }
    }
}
