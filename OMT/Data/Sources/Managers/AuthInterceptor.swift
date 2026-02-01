//
//  AuthInterceptor.swift
//  OMT
//
//  Created by 이인호 on 2/1/26.
//

import Foundation
import Alamofire

class AuthInterceptor: RequestInterceptor {
    
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, any Error>) -> Void) {
        var urlRequest = urlRequest
        
        if let token = KeychainManager.shared.accessToken {
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        completion(.success(urlRequest))
    }
    
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        guard let response = request.task?.response as? HTTPURLResponse,
              (response.statusCode == 401 || response.statusCode == 403) else {
            completion(.doNotRetryWithError(error))
            return
        }
        
        if request.retryCount >= 2 {
            completion(.doNotRetryWithError(error))
            return
        }
        
        Task {
            do {
                let isSuccess = try await refreshAccessToken()
                
                if isSuccess {
                    completion(.retry)
                } else {
                    completion(.doNotRetryWithError(error))
                }
            } catch {
                completion(.doNotRetryWithError(error))
            }
        }
    }
    
    private func refreshAccessToken() async throws -> Bool {
        guard let refreshToken = KeychainManager.shared.refreshToken else {
            return false
        }
        
        let router = AuthRouter.refreshToken(RefreshRequestDTO(refreshToken: refreshToken))
        let request = try router.asURLRequest()
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            return false
        }
        
        let tokenResponse = try JSONDecoder().decode(LoginResponseDTO.self, from: data)
        
        if tokenResponse.success, let tokenData = tokenResponse.data {
            KeychainManager.shared.save(
                accessToken: tokenData.accessToken,
                refreshToken: tokenData.refreshToken
            )
            return true
        }
        
        return false
    }
}
