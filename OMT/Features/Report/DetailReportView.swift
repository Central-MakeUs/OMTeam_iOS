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
        (label: "목", value: 7)
    ]
    
    var body: some View {
        VStack {
            chartCard
        }
    }
}

extension DetailReportView {
    private var chartCard: some View {
        VStack {
            barChart
            chartSummary
        }
        .padding()
        .background(.gray0)
        .cornerRadius(10)
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
            Text("ㅇㅇㅇㅇㅇ")
        }
        .background(.primary2)
    }
}

