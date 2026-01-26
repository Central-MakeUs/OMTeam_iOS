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
            VStack {
                Text("OMT")
                
                ScrollView {
                    VStack {
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
                        
                        analysisDetailButton
                    }
                    .padding()
                }
            }
            .background(.gray)
            
            if store.isDatePickerPresented {
                DatePickerModal(store: store)
            }
        }
    }
}

extension ReportView {
    private var weekNavigationHeader: some View {
        VStack(alignment: .leading) {
            HStack {
                Button {
                    store.send(.previousWeekTapped)
                } label: {
                    Image(systemName: "chevron.left")
                }
                
                Button {
                    store.send(.dateTapped)
                } label: {
                    Text(store.displayText)
                }
                
                Button {
                    store.send(.nextWeekTapped)
                } label: {
                    Image(systemName: "chevron.right")
                }
            }
        }
    }
}

extension ReportView {
    private var successRateCard: some View {
        VStack {
            HStack {
                Image("")
                VStack(alignment: .leading) {
                    Text("이번주 미션 성공률")
                    Text("57%")
                }
            }
            HStack {
                ForEach(weekdays, id: \.self) { day in
                    VStack {
                        Text(day)
                        Circle()
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.white)
        .cornerRadius(16)
    }
}

extension ReportView {
    private var topDifficultiesCard: some View {
        VStack(alignment: .leading) {
            Text("Top2")
            
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
        VStack(alignment: .leading) {
            Text("제안")
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white)
        .cornerRadius(16)
    }
}

extension ReportView {
    private var analysisDetailButton: some View {
        Button {
            
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
}

