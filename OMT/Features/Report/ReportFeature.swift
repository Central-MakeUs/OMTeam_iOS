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
        
        var report: [String] = []
        
        var topDifficulties: [String] = ["야근으로 인한 피로감", "바쁜 약속 일정"]
        
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
            case .previousWeekTapped:
                if let newDate = Calendar.current.date(
                    byAdding: .weekOfYear,
                    value: -1,
                    to: state.currentDate
                ) {
                    state.currentDate = newDate
                }
                
            case .nextWeekTapped:
                if let newDate = Calendar.current.date(
                    byAdding: .weekOfYear,
                    value: 1,
                    to: state.currentDate
                ) {
                    state.currentDate = newDate
                }
                
            case .dateTapped:
                state.isDatePickerPresented = true
                
            case .closeDatePicker:
                state.isDatePickerPresented = false
                
            case let .yearInputChanged(text):
                state.yearInput = text.filter { $0.isNumber }
 
            case let .monthInputChanged(text):
                state.monthInput = text.filter { $0.isNumber }
                
            case let .weekInputChanged(text):
                state.weekInput = text.filter { $0.isNumber }
                
            case .confirmDateSelection:
                guard let year = Int(state.yearInput),
                      let month = Int(state.monthInput),
                      let week = Int(state.weekInput),
                      year >= 2026,
                      month >= 1 && month <= 12,
                      week >= 1 && week <= 5 else {
                    return .none
                }
                state.isDatePickerPresented = false
            
            default:
                break
            }
            
            return .none
        }
    }
}

