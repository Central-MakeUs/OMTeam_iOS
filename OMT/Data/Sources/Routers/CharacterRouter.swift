//
//  CharacterRouter.swift
//  OMT
//
//  Created by 이인호 on 2/4/26.
//

import Foundation
import Alamofire

enum CharacterRouter: TargetType {
    
    case fetchCharacter
}

extension CharacterRouter {
    var method: Alamofire.HTTPMethod {
        switch self {
        case .fetchCharacter:
            return .get
        }
    }
    
    var path: String {
        switch self {
        case .fetchCharacter:
            return "/api/character"
        }
    }
    
    var optionalHeaders: Alamofire.HTTPHeaders? {
        return nil
    }
    
    var headers: HTTPHeaders {
        return .default
    }
    
    var parameters: Parameters? {
        return nil
    }
    
    var body: Data? {
        var encoder = JSONEncoder()
        
        switch self {
        case .fetchCharacter:
            return nil
        }
    }
    
    var encodingType: EncodingType {
        switch self {
        case .fetchCharacter:
            return .json
        }
    }
}
