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
    let weekdays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    var body: some View {
        ZStack {
            VStack(spacing: 12) {
                Text("OMT")
                
                ScrollView {
                    VStack(spacing: 28) {
                        VStack(spacing: 20) {
                            HStack {
                                weekNavigationHeader
                                Spacer()
                                Button {
                                    
                                } label: {
                                    Image(systemName: "arrow.clockwise.circle")
                                }
                            }
                            
                            successRateCard
                            topDifficultiesCard
                            recommendCard
                        }
                        
                        analysisDetailButton
                    }
                    .padding(.horizontal, 20)
                }
            }
            .background(.gray2)
            
            if store.isDatePickerPresented {
                DatePickerModal(store: store)
            }
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
                
                HStack(spacing: 4) {
                    Button {
                        store.send(.dateTapped)
                    } label: {
                        Text(store.displayText)
                            .typography(.sub_btn2_enabled)
                            .foregroundStyle(.gray11)
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
                    
                    Text("57%")
                        .typography(.h1)
                        .foregroundStyle(.gray13)
                }
            }
            .padding(.vertical, 10)
            .padding(.leading, 7.5)
            .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 12) {
                ForEach(weekdays, id: \.self) { day in
                    VStack(spacing: 12) {
                        Text(day)
                            .typography(.sub_b4_3)
                            .foregroundStyle(.gray8)
                        Image("apple_success")
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
            
            Text("다음주에는 수요일을 쉬는 날로 두고, 목・금요일에는 간단한 미션을 선택하는 건 어때요?")
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
            DetailReportView()
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
    }
}

