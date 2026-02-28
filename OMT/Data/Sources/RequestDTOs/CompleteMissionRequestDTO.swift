//
//  CompleteMissionRequestDTO.swift
//  OMT
//
//  Created by 이인호 on 2/7/26.
//

import Foundation

struct CompleteMissionRequestDTO: Encodable {
    let result: String
    let failureReason: String
}
