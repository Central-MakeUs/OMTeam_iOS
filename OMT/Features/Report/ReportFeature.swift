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
        
        var topDifficulties: [String] = ["야근으로 인한 피로감", "바쁜 약속 일정"]
        
        var monthInput: String = ""
        var weekInput: String = ""
        
        var displayText: String {
            let calendar = Calendar.current
            let year = calendar.component(.year, from: currentDate)
            let month = calendar.component(.month, from: currentDate)
            let weekOfMonth = calendar.component(.weekOfMonth, from: currentDate)
            
            return "\(year)년 \(month)월 \(weekOfMonth)주"
        }
        
        var isConfirmButtonEnabled: Bool {
            !monthInput.isEmpty && !weekInput.isEmpty
        }
    }
    
    enum Action {
        case previousWeekTapped
        case nextWeekTapped
        case dateTapped
        case closeDatePicker
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
                
            case let .monthInputChanged(text):
                state.monthInput = text.filter { $0.isNumber }
                
            case let .weekInputChanged(text):
                state.weekInput = text.filter { $0.isNumber }
                
            case .confirmDateSelection:
                guard let month = Int(state.monthInput),
                      let week = Int(state.weekInput),
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

