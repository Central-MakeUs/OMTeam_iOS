//
//  AlertType.swift
//  OMT
//
//  Created by 이인호 on 2/10/26.
//

import Foundation

enum AlertType: Equatable {
    case logout
    case withdraw
    case withdrawComplete
    case privacyConsentDeclined

    var title: String {
        switch self {
        case .logout:
            return "로그아웃 하시겠어요?"
        case .withdraw:
            return "정말 계정을 탈퇴하시겠어요?"
        case .withdrawComplete:
            return "회원탈퇴가 완료되었어요."
        case .privacyConsentDeclined:
            return "안내"
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
        case .privacyConsentDeclined:
            return "OMT는 맞춤형 서비스를 제공하기 위해\n위 정보가 꼭 필요해요.\n동의하지 않으시면 서비스 이용이\n어렵습니다 😢"
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
        case .privacyConsentDeclined:
            return "처음으로 돌아가기"
        }
    }

    var showCancelButton: Bool {
        switch self {
        case .logout, .withdraw, .privacyConsentDeclined:
            return true
        case .withdrawComplete:
            return false
        }
    }

    var isDestructive: Bool {
        switch self {
        case .logout, .withdraw, .privacyConsentDeclined:
            return true
        case .withdrawComplete:
            return false
        }
    }
}
