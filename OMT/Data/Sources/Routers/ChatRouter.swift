//
//  ChatRouter.swift
//  OMT
//
//  Created by 이인호 on 2/5/26.
//

import Foundation
import Alamofire

enum ChatRouter: TargetType {
    case fetchChat(size: Int = 1000)
    case sendChat(MessageRequestDTO)
    case sendEmptyChat // 빈 요청으로 greeting message를 받기 위해 사용
}

extension ChatRouter {
    var method: Alamofire.HTTPMethod {
        switch self {
        case .sendChat, .sendEmptyChat:
            return .post
        case .fetchChat:
            return .get
        }
    }
    
    var path: String {
        switch self {
        case .sendChat, .sendEmptyChat:
            return "/api/chat/messages"
        case .fetchChat:
            return "/api/chat"
        }
    }
    
    var optionalHeaders: Alamofire.HTTPHeaders? {
        return nil
    }
    
    var headers: HTTPHeaders {
        return .default
    }
    
    var parameters: Parameters? {
        switch self {
        case .sendChat, .sendEmptyChat:
            return nil
        case .fetchChat(let size):
            return ["size": size]
        }
    }
    
    var body: Data? {
        let encoder = JSONEncoder()
        
        switch self {
        case .sendChat(let messageRequestDTO):
            return try? encoder.encode(messageRequestDTO)
        case .sendEmptyChat, .fetchChat:
            return nil
        }
    }
    
    var encodingType: EncodingType {
        switch self {
        case .sendChat, .sendEmptyChat:
            return .json
        case .fetchChat:
            return .url
        }
    }
}

