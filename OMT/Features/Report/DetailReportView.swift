//
//  DetailReportView.swift
//  OMT
//
//  Created by 이인호 on 2/1/26.
//

import SwiftUI
import Charts
import ComposableArchitecture

struct DetailReportView: View {
    @Bindable var store: StoreOf<ReportFeature>
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                successRateCard
                weeklyMissionCard
                omtRecommendationCard
            }
            .padding(.horizontal, 20)
        }
        .background(.gray2)
        .onAppear {
            store.send(.fetchMonthlyPattern)
        }
        .customNavigationBar(
            centerView: {
                Text("상세 분석 보기")
                    .typography(.h2_2)
                    .foregroundStyle(.gray11)
            },
            leftView: {
                Button {
                    dismiss()
                } label: {
                    Image("arrow_back_01")
                }
            },
        )
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
            ComparisonBar(title: "지난주", percentage: store.lastWeekSuccessRate, isHighlighted: false)
            ComparisonBar(title: "이번주", percentage: store.thisWeekSuccessRate, isHighlighted: true)
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
            ForEach(store.dailyResults, id: \.date) { mission in
                let weekday = Calendar.current.component(.weekday, from: mission.date)
                let dayName = Calendar.current.shortWeekdaySymbols[weekday - 1]

                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(mission.result == .success ? .secondary2 : .gray2)

                        if let missionType = mission.missionType {
                            Image(missionType == .exercise ? "icon_exercise" : "icon_doughnut")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 28, height: 28)
                        }
                    }

                    Text(dayName)
                        .typography(.sub_b4_3)
                        .foregroundStyle(.gray9)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var explanationText: some View {
        Text("일주일 동안 운동 미션 \(store.exerciseCount)번, 식단 미션 \(store.dietCount)번을\n선택했어요. 총 \(store.successCount)번 성공했어요!")
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

            Text(store.overallFeedback)
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
                Text(store.monthlySummary)
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
            Chart(store.dayOfWeekStats) { stat in
                BarMark(
                    x: .value("Day", stat.dayName),
                    y: .value("Value", stat.successCount)
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
            Text(store.monthlyRecommendation)
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
