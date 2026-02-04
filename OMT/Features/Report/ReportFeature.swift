//
//  ReportFeature.swift
//  OMT
//
//  Created by 이인호 on 1/26/26.
//

import Foundation
import ComposableArchitecture

@Reducer
struct ReportFeature {
    @ObservableState
    struct State: Equatable {
        var currentDate: Date = Date()
        var isDatePickerPresented: Bool = false
        
        var hasReport: Bool = false
        var thisWeekSuccessRate: Double = 0.0
        var topDifficulties: [String] = []
        var dailyResults: [DailyMission] = []
        var overallFeedback: String = ""
        
        var yearInput: String = ""
        var monthInput: String = ""
        var weekInput: String = ""
        
        var errorMessage: String? {
            if let year = Int(yearInput), !yearInput.isEmpty, year < 2026 {
                return "2026년도 이후의 년도를 입력해주세요."
            }
            if let month = Int(monthInput), !monthInput.isEmpty , (month < 1 || month > 12) {
                return "1-12 사이의 숫자를 입력해주세요. "
            }
            if let week = Int(weekInput), !weekInput.isEmpty, (week < 1 || week > 5) {
                return "1-5 사이의 숫자를 입력해주세요."
            }
            return nil
        }
        
        var displayText: String {
            let calendar = Calendar.current
            let year = calendar.component(.year, from: currentDate)
            let month = calendar.component(.month, from: currentDate)
            let weekOfMonth = calendar.component(.weekOfMonth, from: currentDate)
            
            return "\(year)년 \(month)월 \(weekOfMonth)주"
        }
        
        var isConfirmButtonEnabled: Bool {
            !yearInput.isEmpty &&
            !monthInput.isEmpty &&
            !weekInput.isEmpty &&
            errorMessage == nil
        }
    }
    
    enum Action {
        case onAppear
        case fetchWeeklyReports
        case fetchWeeklyReportsResponse(WeeklyReportsDataDTO)
        case fetchDailyFeedbackResponse(DailyFeedbackDataDTO)
        case fetchWeeklyReportsFailed
        case previousWeekTapped
        case nextWeekTapped
        case dateTapped
        case closeDatePicker
        case yearInputChanged(String)
        case monthInputChanged(String)
        case weekInputChanged(String)
        case confirmDateSelection
    }
    
    @Dependency(\.networkManager) var networkManager
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .send(.fetchWeeklyReports)

            case .fetchWeeklyReports:
                let calendar = Calendar.current
                let year = calendar.component(.year, from: state.currentDate)
                let month = calendar.component(.month, from: state.currentDate)
                let weekOfMonth = calendar.component(.weekOfMonth, from: state.currentDate)

                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                let today = formatter.string(from: Date())

                return .merge(
                    .run { [networkManager] send in
                        let response = try await networkManager.requestNetwork(
                            dto: WeeklyReportsResponseDTO.self,
                            router: ReportRouter.fetchWeeklyReports(year: year, month: month, weekOfMonth: weekOfMonth)
                        )
                        if let data = response.data {
                            await send(.fetchWeeklyReportsResponse(data))
                        }
                    } catch: { error, send in
                        print(error)
                        await send(.fetchWeeklyReportsFailed)
                    },
                    .run { [networkManager] send in
                        let response = try await networkManager.requestNetwork(
                            dto: DailyFeedbackResponseDTO.self,
                            router: ReportRouter.dailyFeedback(today)
                        )
                        if let data = response.data {
                            await send(.fetchDailyFeedbackResponse(data))
                        }
                    } catch: { error, send in
                        print(error)
                    }
                )

            case .fetchWeeklyReportsFailed:
                state.hasReport = false
                state.dailyResults = []
                state.thisWeekSuccessRate = 0.0
                state.topDifficulties = []
                state.overallFeedback = ""
                return .none

            case .fetchDailyFeedbackResponse(let data):
                state.overallFeedback = data.feedbackText
                return .none

            case .fetchWeeklyReportsResponse(let data):
                state.hasReport = data.dailyResults.contains { $0.status != .notPerformed }
                state.thisWeekSuccessRate = data.thisWeekSuccessRate
                state.topDifficulties = data.topFailureReasons.map { $0.reason }

                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"

                if let startDate = formatter.date(from: data.weekStartDate),
                   let endDate = formatter.date(from: data.weekEndDate) {
                    let resultsByDate = Dictionary(
                        uniqueKeysWithValues: data.dailyResults.map { ($0.date, $0) }
                    )
                    let calendar = Calendar.current
                    var missions: [DailyMission] = []
                    var current = startDate

                    while current <= endDate {
                        let key = formatter.string(from: current)
                        if let dto = resultsByDate[key] {
                            missions.append(DailyMission.from(dto))
                        } else {
                            missions.append(DailyMission.notPerformed(date: current))
                        }
                        guard let next = calendar.date(byAdding: .day, value: 1, to: current) else { break }
                        current = next
                    }

                    state.dailyResults = missions
                }
                return .none

            case .previousWeekTapped:
                if let newDate = Calendar.current.date(
                    byAdding: .weekOfYear,
                    value: -1,
                    to: state.currentDate
                ) {
                    state.currentDate = newDate
                }
                return .send(.fetchWeeklyReports)

            case .nextWeekTapped:
                if let newDate = Calendar.current.date(
                    byAdding: .weekOfYear,
                    value: 1,
                    to: state.currentDate
                ) {
                    state.currentDate = newDate
                }
                return .send(.fetchWeeklyReports)

            case .dateTapped:
                state.isDatePickerPresented = true
                return .none

            case .closeDatePicker:
                state.isDatePickerPresented = false
                return .none

            case let .yearInputChanged(text):
                state.yearInput = text.filter { $0.isNumber }
                return .none

            case let .monthInputChanged(text):
                state.monthInput = text.filter { $0.isNumber }
                return .none

            case let .weekInputChanged(text):
                state.weekInput = text.filter { $0.isNumber }
                return .none

            case .confirmDateSelection:
                guard let year = Int(state.yearInput),
                      let month = Int(state.monthInput),
                      let week = Int(state.weekInput),
                      year >= 2026,
                      month >= 1 && month <= 12,
                      week >= 1 && week <= 5 else {
                    return .none
                }

                var components = DateComponents()
                components.year = year
                components.month = month
                components.weekOfMonth = week
                components.weekday = Calendar.current.firstWeekday
                if let date = Calendar.current.date(from: components) {
                    state.currentDate = date
                }

                state.isDatePickerPresented = false
                state.yearInput = ""
                state.monthInput = ""
                state.weekInput = ""
                return .send(.fetchWeeklyReports)
            }
        }
    }
}

