//
//  UpdateAvailableTimeRequestDTO.swift
//  OMT
//
//  Created by 이인호 on 2/10/26.
//

import Foundation

struct UpdateAvailableTimeRequestDTO: Encodable {
    let availableStartTime: String
    let availableEndTime: String
}
