//
//  AlertType.swift
//  OMT
//
//  Created by wayblemac02 on 2/10/26.
//

import Foundation

enum AlertType: Equatable {
    case logout
    case withdraw
    case withdrawComplete

    var title: String {
        switch self {
        case .logout:
            return "로그아웃 하시겠어요?"
        case .withdraw:
            return "정말 계정을 탈퇴하시겠어요?"
        case .withdrawComplete:
            return "회원탈퇴가 완료되었어요."
        }
    }

    var message: String {
        switch self {
        case .logout:
            return "잠시 쉬어가시나요?\n언제든 다시 돌아와 주세요."
        case .withdraw:
            return "탈퇴하면 모든 기록이 삭제되고,\n계정 정보도 함께 파기돼요."
        case .withdrawComplete:
            return "OMT와 다시 시작하고 싶을 때\n또 만나요!"
        }
    }

    var confirmButtonTitle: String {
        switch self {
        case .logout:
            return "로그아웃"
        case .withdraw:
            return "탈퇴하기"
        case .withdrawComplete:
            return "우리 다음에 또 봐요!"
        }
    }

    var showCancelButton: Bool {
        switch self {
        case .logout, .withdraw:
            return true
        case .withdrawComplete:
            return false
        }
    }

    var isDestructive: Bool {
        switch self {
        case .logout, .withdraw:
            return true
        case .withdrawComplete:
            return false
        }
    }
}
