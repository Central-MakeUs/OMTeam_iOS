//
//  CharacterImage.swift
//  OMT
//
//  Created by 이인호 on 2/11/26.
//

import Foundation

enum CharacterImage {
    case basic
    case happy
    case excited
    case exercise
    case diet

    var imageName: String {
        switch self {
        case .basic: return "basic"
        case .happy: return "happy"
        case .excited: return "excited"
        case .exercise: return "exercise"
        case .diet: return "diet"
        }
    }

    var size: CGSize {
        switch self {
        case .basic: return CGSize(width: 150, height: 133)
        case .happy: return CGSize(width: 199, height: 140)
        case .excited: return CGSize(width: 196.5, height: 149.84)
        case .exercise: return CGSize(width: 177, height: 133)
        case .diet: return CGSize(width: 159, height: 133)
        }
    }
}
