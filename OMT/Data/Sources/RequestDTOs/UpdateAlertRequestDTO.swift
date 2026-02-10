//
//  UpdateAlertRequestDTO.swift
//  OMT
//
//  Created by 이인호 on 2/10/26.
//

import Foundation

import Foundation

struct UpdateAlertRequestDTO: Encodable {
    let remindEnabled: Bool
    let checkinEnabled: Bool
    let reviewEnabled: Bool
}
