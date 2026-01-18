//
//  APIResponse.swift
//  OMT
//
//  Created by 이인호 on 1/18/26.
//

import Foundation

struct APIResponse<T: Decodable>: Decodable {
    let success: Bool
    let data: T?
    let error: APIErrorDTO?
}
