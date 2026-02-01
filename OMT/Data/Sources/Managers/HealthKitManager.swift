//
//  HealthKitManager.swift
//  OMT
//
//  Created by 이인호 on 1/21/26.
//

import Foundation
import HealthKit

enum HealthKitError: Error, LocalizedError {
    case dataTypeNotAvailable
    case authorizationFailed
    
    var errorDescription: String? {
        switch self {
        case .dataTypeNotAvailable:
            return "건강 데이터 타입을 사용할 수 없습니다."
        case .authorizationFailed:
            return "HealthKit 권한이 거부되었습니다."
        }
    }
}

final class HealthKitManager {
    static let shared = HealthKitManager()
    private let healthStore = HKHealthStore()
    
    private init() {}
    
    var isHealthKitAvailable: Bool {
        return HKHealthStore.isHealthDataAvailable()
    }
    
    func requestAuthorization() async throws {
        guard let stepCount = HKQuantityType.quantityType(forIdentifier: .stepCount),
              let distanceWalkingRunning = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning),
              let activeEnergyBurned = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else {
            throw HealthKitError.dataTypeNotAvailable
        }
        
        let typesToRead: Set<HKObjectType> = [
            stepCount,
            distanceWalkingRunning,
            activeEnergyBurned
        ]
        
        try await healthStore.requestAuthorization(toShare: [], read: typesToRead)
    }
    
    // MARK: - 오늘 걸음 수
    func getTodaySteps() async throws -> Double {
        try await getTodayStatistics(for: .stepCount, unit: .count())
    }
    
    // MARK: - 오늘 이동 거리
    func getTodayDistance() async throws -> Double {
        try await getTodayStatistics(for: .distanceWalkingRunning, unit: .meterUnit(with: .kilo))
    }
    
    // MARK: - 오늘 소모 칼로리
    func getTodayCalories() async throws -> Double {
        try await getTodayStatistics(for: .activeEnergyBurned, unit: .kilocalorie())
    }
    
    // 통계 조회 공통함수
    private func getTodayStatistics(for identifier: HKQuantityTypeIdentifier, unit: HKUnit) async throws -> Double {
        guard let quantityType = HKQuantityType.quantityType(forIdentifier: identifier) else {
            throw HealthKitError.dataTypeNotAvailable
        }
        
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        
        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: now,
            options: .strictStartDate
        )
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: quantityType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, result, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                let value = result?.sumQuantity()?.doubleValue(for: unit) ?? 0
                continuation.resume(returning: value)
            }
            
            healthStore.execute(query)
        }
    }
    
    func testHealthKit() async {
        do {
            try await requestAuthorization()
            
            let steps = try await getTodaySteps()
            let distance = try await getTodayDistance()
            let calories = try await getTodayCalories()
            
            print("📊 오늘 걸음 수: \(Int(steps))걸음")
            print("📍 오늘 이동 거리: \(String(format: "%.2f", distance))km")
            print("🔥 오늘 소모 칼로리: \(Int(calories))kcal")
        } catch {
            print("HealthKit 에러: \(error.localizedDescription)")
        }
    }
}

