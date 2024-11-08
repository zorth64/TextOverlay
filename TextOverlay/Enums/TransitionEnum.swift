//
//  TransitionEnum.swift
//  TextOverlay
//
//  Created by zorth64 on 12/10/24.
//

import SwiftUI

enum TransitionEnum: CaseIterable {
    case fromLeft
    case fromRight
    case fromTop
    case fromBottom
    case scale
    case fade
    case none
    
    static func withLabel(_ label: String) -> TransitionEnum {
        if let result = self.allCases.first(where: { "\($0)" == label }) {
            return result
        } else {
            return .fade
        }
    }
    
    var getTransition: AnyTransition {
        switch self {
            case .fromLeft: return AnyTransition.move(edge: .leading)
            case .fromRight: return AnyTransition.move(edge: .trailing)
            case .fromTop: return AnyTransition.move(edge: .top)
            case .fromBottom: return AnyTransition.move(edge: .bottom)
            case .scale: return AnyTransition.scale
            case .fade: return AnyTransition.opacity
            case .none: return AnyTransition.identity
        }
    }
}
