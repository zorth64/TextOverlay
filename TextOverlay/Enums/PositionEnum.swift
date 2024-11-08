//
//  PositionEnum.swift
//  TextOverlay
//
//  Created by zorth64 on 12/10/24.
//

enum HorizontalPosition: CaseIterable {
    case left
    case right
    case center
    
    static func withLabel(_ label: String) -> HorizontalPosition {
        if let result = self.allCases.first(where: { "\($0)" == label }) {
            return result
        } else {
            return .center
        }
    }
}

enum VerticalPosition: CaseIterable {
    case top
    case bottom
    case center
    
    static func withLabel(_ label: String) -> VerticalPosition {
        if let result = self.allCases.first(where: { "\($0)" == label }) {
            return result
        } else {
            return .center
        }
    }
}

enum IconPosition: CaseIterable {
    case left
    case right
    
    static func withLabel(_ label: String) -> IconPosition {
        if let result = self.allCases.first(where: { "\($0)" == label }) {
            return result
        } else {
            return .left
        }
    }
}
