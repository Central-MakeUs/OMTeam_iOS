//
//  NetworkManager.swift
//  OMT
//
//  Created by 이인호 on 1/18/26.
//

import Foundation
import Alamofire
import ComposableArchitecture

struct NetworkManager: Sendable {
    
    func requestNetwork<T: Decodable, R: TargetType>(dto: T.Type, router: R) async throws -> T {
        let request = try router.asURLRequest()
        
        // MARK: 요청담당
        let response = await getRequest(dto: dto, router: router, request: request)
        
        let result = try await getResponse(dto: dto, router: router, response: response)
        
        return result
    }
    
    private func getRequest<
        T: Decodable,
        R: TargetType
    >(
        dto: T.Type,
        router: R,
        request: URLRequest,
        ifRefreshMode: Bool = false
    ) async -> DataResponse<
        T,
        AFError
    > {
        
        let requestResponse = await AF.request(request)
            .validate(statusCode: 200..<300)
            .serializingDecodable(T.self)
            .response
    
        return requestResponse
    }
    
    private func getResponse<T:Decodable>(
         dto: T.Type,
         router: TargetType,
         response: DataResponse<T, AFError>,
         ifRefreshMode: Bool = false
     ) async throws(AFError) -> T
     {
         print(response.response ?? "")
         
         switch response.result {
         case let .success(data):
             return data
         case let .failure(AFError):
             throw AFError
         }
     }
}

extension NetworkManager: DependencyKey {
    static let liveValue: NetworkManager = NetworkManager()
}

extension DependencyValues {
    var networkManager: NetworkManager {
        get { self[NetworkManager.self] }
        set { self[NetworkManager.self] = newValue }
    }
}
