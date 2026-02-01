//
//  DetailReportView.swift
//  OMT
//
//  Created by 이인호 on 2/1/26.
//

import SwiftUI
import Charts

struct DetailReportView: View {
    let data = [
        (label: "월", value: 5),
        (label: "화", value: 8),
        (label: "수", value: 12),
        (label: "목", value: 7),
        (label: "금", value: 5),
        (label: "토", value: 8),
        (label: "일", value: 12),
    ]
    let weekdays = ["일요일", "월요일", "화요일", "수요일", "목요일", "금요일", "토요일"]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                successRateCard
                weeklyMissionCard
                omtRecommendationCard
            }
            .padding(.horizontal, 20)
        }
        .background(.gray2)
        .navigationTitle("상세 분석 보기")
    }
}

extension DetailReportView {
    private var successRateCard: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack {
                Image("icon_good")
                Text("지난주보다 미션 성공률이 올랐어요!")
                    .typography(.h3)
                    .foregroundStyle(.gray13)
            }
            rateChart
        }
        .padding([.top, .horizontal], 12)
        .padding(.bottom, 20)
        .frame(maxWidth: .infinity)
        .background(.gray0)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private var rateChart: some View {
        VStack(spacing: 8) {
            ComparisonBar(title: "지난주", percentage: 10, isHighlighted: false)
            ComparisonBar(title: "이번주", percentage: 57.1, isHighlighted: true)
        }
    }
}

extension DetailReportView {
    private var weeklyMissionCard: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack {
                Image("icon_exercise")
                Text("이번주 미션, 한 번 살펴볼까요?")
                    .typography(.h3)
                    .foregroundStyle(.gray13)
            }
            VStack(spacing: 20) {
                VStack(spacing: 16) {
                    weeklyMissionIcons
                    explanationText
                }
                failReasonSummary
            }
        }
        .padding(12)
        .background(.gray0)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private var weeklyMissionIcons: some View {
        HStack(spacing: 6) {
            ForEach(weekdays, id: \.self) { day in
                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(.secondary2)
                        
                        Image("icon_doughnut")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 28, height: 28)
                    }
                    
                    Text(day)
                        .typography(.sub_b4_3)
                        .foregroundStyle(.gray9)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    private var explanationText: some View {
        Text("일주일 동안 운동 미션 5번, 식단 미션 2번을\n선택했어요. 총 4번 성공했어요!")
            .typography(.sub_b2_2)
            .foregroundStyle(.gray11)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var failReasonSummary: some View {
        HStack {
            ZStack {
                Circle()
                    .fill(.secondary2)
                    .frame(width: 40, height: 40)
                
                Image("icon_exercise")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 28, height: 28)
            }
            
            Text("이번주는 야근과 약속 일정으로 인해\n미션을 실천하기 어려웠어요!")
                .typography(.sub_b2_3)
                .foregroundStyle(.gray11)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding([.top, .horizontal], 8)
        .padding(.bottom, 10)
        .frame(maxWidth: .infinity)
        .background(.primary2)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(.greenGray4, lineWidth: 1)
        )
    }
}

extension DetailReportView {
    private var omtRecommendationCard: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack {
                Image("icon_apple")
                Text("수요일엔 쉬어가는 건 어때요?")
                    .typography(.h3)
                    .foregroundStyle(.gray13)
            }
            VStack(spacing: 20) {
                barChart
                chartSummary
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(.gray0)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private var barChart: some View {
        VStack {
            Chart(data, id: \.label) { item in
                BarMark(
                    x: .value("Day", item.label),
                    y: .value("Value", item.value)
                )
                .foregroundStyle(.gray)
                .cornerRadius(8)
            }
            .frame(height: 150)
            .chartXAxis {
                AxisMarks { value in
                    AxisValueLabel {
                        if let label = value.as(String.self) {
                            Text(label)
                                .font(.pretendardMedium(size: 12))
                                .foregroundColor(.gray9)
                        }
                    }
                }
            }
            .chartYAxis(.hidden)
        }
    }
    
    private var chartSummary: some View {
        VStack {
            Text("지난 한 달을 보면, 수요일엔 쉬어가는 게 좋아요. 수요일은 휴식으로 두고, 목·금요일은가볍게 움직여볼까요?")
                .typography(.sub_b2_3)
                .foregroundStyle(.gray11)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding([.top, .horizontal], 8)
        .padding(.bottom, 10)
        .background(.primary2)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(.greenGray4, lineWidth: 1)
        )
    }
}

struct ComparisonBar: View {
    let title: String
    let percentage: Double
    let isHighlighted: Bool
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 16) {
                Text(title)
                
                HStack {
                    Spacer(minLength: 0)
                    Text("\(String(format: "%.1f", percentage)) %")
                        .padding(.horizontal, 10)
                        .padding(.vertical, 12)
                        .typography(.sub_btn3_enabled)
                        .foregroundStyle(isHighlighted ? .primary12 : .gray9)
                }
                .frame(width: max(70, (geometry.size.width - 100) * CGFloat(percentage / 100)))
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isHighlighted ? Color.primary6 : Color.gray3)
                )
            }
        }
        .frame(height: 40)
    }
}
