//
//  LoginResponseDTO.swift
//  OMT
//
//  Created by 이인호 on 1/18/26.
//

import Foundation

typealias LoginResponseDTO = APIResponse<LoginTokenDTO>

struct LoginTokenDTO: Decodable {
    let accessToken: String
    let refreshToken: String
    let expiresIn: Int
    let onboardingCompleted: Bool
}
