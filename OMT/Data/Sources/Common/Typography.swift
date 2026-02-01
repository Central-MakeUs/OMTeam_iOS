//
//  Typography.swift
//  OMT
//
//  Created by 이인호 on 1/21/26.
//

import SwiftUI

enum Typography {
    // MARK: - Paperlogy (Main) - Headline
      case h1, h2_1, h2_2, h3, h4
    
    // MARK: - Paperlogy - Body
    case b1, b2
    
    // MARK: - Paperlogy - Button
    case btn1_enabled, btn1_disabled
    case btn2_enabled, btn2_disabled
    case btn3_enabled, btn3_disabled
    
    // MARK: - Pretendard (Sub) - Body
    case sub_b1
    case sub_b2_1, sub_b2_2, sub_b2_3, sub_b2_4
    case sub_b3_1, sub_b3_2
    case sub_b4_1, sub_b4_2, sub_b4_3
    
    // MARK: - Pretendard (Sub) - Button
    case sub_btn1_enabled, sub_btn1_disabled
    case sub_btn2_enabled, sub_btn2_disabled
    case sub_btn3_enabled, sub_btn3_disabled
    
    var font: Font {
        switch self {
        case .h1: return .paperlogySemiBold(size: 24)
        case .h2_1: return .paperlogySemiBold(size: 22)
        case .h2_2: return .paperlogyMedium(size: 22)
        case .h3: return .paperlogySemiBold(size: 20)
        case .h4: return .paperlogySemiBold(size: 18)
            
        case .b1: return .paperlogyMedium(size: 16)
        case .b2: return .paperlogyBold(size: 14)
            
        case .btn1_enabled: return .paperlogySemiBold(size: 20)
        case .btn1_disabled: return .paperlogyMedium(size: 20)
        case .btn2_enabled: return .paperlogySemiBold(size: 18)
        case .btn2_disabled: return .paperlogyMedium(size: 18)
        case .btn3_enabled: return .paperlogySemiBold(size: 16)
        case .btn3_disabled: return .paperlogyRegular(size: 16)
            
        case .sub_b1: return .pretendardRegular(size: 18)
        case .sub_b2_1, .sub_b2_2, .sub_b2_4: return .pretendardMedium(size: 16)
        case .sub_b2_3: return .pretendardSemiBold(size: 16)
        case .sub_b3_1: return .pretendardMedium(size: 14)
        case .sub_b3_2: return .pretendardRegular(size: 14)
        case .sub_b4_1: return .pretendardSemiBold(size: 12)
        case .sub_b4_2, .sub_b4_3: return .pretendardMedium(size: 12)
            
        case .sub_btn1_enabled: return .pretendardSemiBold(size: 18)
        case .sub_btn1_disabled: return .pretendardMedium(size: 18)
        case .sub_btn2_enabled: return .pretendardSemiBold(size: 16)
        case .sub_btn2_disabled: return .pretendardMedium(size: 16)
        case .sub_btn3_enabled: return .pretendardSemiBold(size: 14)
        case .sub_btn3_disabled: return .pretendardRegular(size: 14)
        }
    }
    
    var lineSpacing: CGFloat {
        switch self {
        case .h2_1: return 11
        case .sub_b2_2: return 6.4
        case .sub_b2_3: return 8
        case .sub_b2_4: return 9.6
        case .sub_b3_2: return 5.6
        case .sub_b4_3: return 3.6
        default: return 0
        }
    }
    
    var letterSpacing: CGFloat {
        switch self {
        case .sub_b1,
            .sub_b2_1, .sub_b2_2, .sub_b2_3, .sub_b2_4,
            .sub_b3_1, .sub_b3_2,
            .sub_b4_1, .sub_b4_2, .sub_b4_3,
            .sub_btn1_enabled, .sub_btn1_disabled,
            .sub_btn2_enabled, .sub_btn2_disabled,
            .sub_btn3_enabled, .sub_btn3_disabled:
            return -0.4
        default:
            return 0
        }
    }
}

