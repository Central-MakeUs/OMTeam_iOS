//
//  AppleLoginRequestDTO.swift
//  OMT
//
//  Created by 이인호 on 1/18/26.
//

import Foundation

struct AppleLoginRequestDTO: Encodable {
    let authorizationCode: String
    let idToken: String
}
