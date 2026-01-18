//
//  TargetType.swift
//  OMT
//
//  Created by 이인호 on 1/18/26.
//

import Foundation
import Alamofire

public enum EncodingType {
    case url
    case json
    case multipartForm
}

public protocol TargetType {
    var method: HTTPMethod { get }
    var baseURL: String { get }
    var path: String { get }
    var optionalHeaders: HTTPHeaders? { get } // secretHeader 말고도 추가적인 헤더가 필요시
    var headers: HTTPHeaders { get } // 다 합쳐진 헤더
    var parameters: Parameters? { get }
    var body: Data? { get }
}

extension TargetType {
    var baseURL: String {
        return Bundle.main.infoDictionary?["BASE_URL"] as? String ?? ""
    }
    
    func asURLRequest() throws -> URLRequest {
        let url = try baseURLToURL()
        var urlRequest = try URLRequest(url: url.appending(path: path), method: method, headers: headers)
        
        do {
            urlRequest = try URLEncoding.queryString.encode(urlRequest, with: parameters)
            return urlRequest
        } catch {
            throw AFError.invalidURL(url: url)
        }
    }
    
    
    private func baseURLToURL() throws(AFError) -> URL {
        let url = try! baseURL.asURL()
        return url
    }
}


