//
//  ReportFeature.swift
//  OMT
//
//  Created by 이인호 on 1/26/26.
//

import Foundation
import ComposableArchitecture

struct DayOfWeekStat: Equatable, Identifiable {
    let id: String
    let dayName: String
    let successCount: Int
}

@Reducer
struct ReportFeature {
    @ObservableState
    struct State: Equatable {
        var currentDate: Date = Date()
        var isDatePickerPresented: Bool = false

        var hasReport: Bool = false
        var lastWeekSuccessRate: Double = 0.0
        var thisWeekSuccessRate: Double = 0.0
        var thisWeekSuccessCount: Int = 0
        var topDifficulties: [String] = []
        var dailyResults: [DailyMission] = []
        var overallFeedback: String = ""
        var weeklyFeedback: String = ""

        var dayOfWeekStats: [DayOfWeekStat] = []
        var monthlySummary: String = ""
        var monthlyRecommendation: String = ""

        var exerciseCount: Int {
            dailyResults.filter { $0.missionType == .exercise }.count
        }
        var dietCount: Int {
            dailyResults.filter { $0.missionType == .diet }.count
        }
        var successCount: Int {
            dailyResults.filter { $0.result == .success }.count
        }
        
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
            let calendar = Calendar.mondayFirst
            let (year, month, weekOfMonth) = calendar.weekInfoFromFirstMonday(for: currentDate)
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

        // MARK: - 네트워크 요청 액션
        // 리포트 화면은 3개의 서로 다른 API를 호출하여 데이터를 조합합니다.
        // 각 API 응답의 데이터 구조가 다르기 때문에, 응답별로 별도의 Response 액션이 필요합니다.

        /// 주간 리포트 요청 - 주간 성공률, 일별 미션 결과, AI 피드백을 가져옵니다
        case fetchWeeklyReports
        /// 주간 리포트 응답 - 성공률, 일별 결과, 실패 원인 랭킹 등을 State에 반영합니다
        case fetchWeeklyReportsResponse(WeeklyReportsDataDTO)
        /// 일일 피드백 응답 - 오늘의 AI 피드백 텍스트를 State에 반영합니다
        case fetchDailyFeedbackResponse(DailyFeedbackDataDTO)
        /// 주간 리포트 요청 실패 - 데이터를 초기화하여 빈 화면을 표시합니다
        case fetchWeeklyReportsFailed
        /// 월간 패턴 요청 - 요일별 성공 통계와 월간 AI 피드백을 가져옵니다 (DetailReportView에서 사용)
        case fetchMonthlyPattern
        /// 월간 패턴 응답 - 요일별 통계와 월간 피드백을 State에 반영합니다
        case fetchMonthlyPatternResponse(MonthlyPatternDataDTO)

        // MARK: - 사용자 인터랙션 액션
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
                let calendar = Calendar.mondayFirst
                let (year, month, weekOfMonth) = calendar.weekInfoFromFirstMonday(for: state.currentDate)

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
                state.lastWeekSuccessRate = 0.0
                state.thisWeekSuccessRate = 0.0
                state.thisWeekSuccessCount = 0
                state.topDifficulties = []
                state.overallFeedback = ""
                return .none

            case .fetchMonthlyPattern:
                return .run { [networkManager] send in
                    let response = try await networkManager.requestNetwork(
                        dto: MonthlyPatternResponseDTO.self,
                        router: ReportRouter.monthlyPattern
                    )
                    if let data = response.data {
                        await send(.fetchMonthlyPatternResponse(data))
                    }
                } catch: { error, send in
                    print(error)
                }

            case .fetchMonthlyPatternResponse(let data):
                state.dayOfWeekStats = data.dayOfWeekStats.map {
                    DayOfWeekStat(id: $0.dayOfWeek.rawValue, dayName: $0.dayName, successCount: $0.successCount)
                }
                state.monthlySummary = data.aiFeedback.dayOfWeekFeedbackTitle ?? ""
                state.monthlyRecommendation = data.aiFeedback.dayOfWeekFeedbackContent ?? ""
                return .none

            case .fetchDailyFeedbackResponse(let data):
                state.overallFeedback = data.feedbackText
                return .none

            case .fetchWeeklyReportsResponse(let data):
                state.hasReport = data.dailyResults.contains { $0.status != .notPerformed }
                state.lastWeekSuccessRate = data.lastWeekSuccessRate
                state.thisWeekSuccessRate = data.thisWeekSuccessRate
                state.thisWeekSuccessCount = data.thisWeekSuccessCount
                state.topDifficulties = data.aiFeedback.failureReasonRanking.map { $0.category }
                state.weeklyFeedback = data.aiFeedback.weeklyFeedback ?? ""

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
                if let newDate = Calendar.mondayFirst.date(
                    byAdding: .weekOfYear,
                    value: -1,
                    to: state.currentDate
                ) {
                    state.currentDate = newDate
                }
                return .send(.fetchWeeklyReports)

            case .nextWeekTapped:
                if let newDate = Calendar.mondayFirst.date(
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

                let calendar = Calendar.mondayFirst
                if let date = calendar.dateFromFirstMondayWeek(week: week, month: month, year: year) {
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

