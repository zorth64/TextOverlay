//
//  String+Extension.swift
//  TextOverlay
//
//  Created by zorth64 on 06/11/24.
//

import Foundation

extension String {
    public func isValidHexColorCode() -> Bool {
        let hexPattern = "^#?([0-9a-fA-F]{3}){1,2}$"
        let regex = try? NSRegularExpression(pattern: hexPattern, options: .caseInsensitive)
        let range = NSRange(location: 0, length: self.utf16.count)
        
        return regex?.firstMatch(in: self, options: [], range: range) != nil
    }
}
