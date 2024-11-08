//
//  PositionModel.swift
//  TextOverlay
//
//  Created by zorth64 on 12/10/24.
//

struct PositionModel {
    var vertical: VerticalPosition? = .center
    var horizontal: HorizontalPosition? = .center
    
    init(_ vertical: VerticalPosition? = .center, _ horizontal: HorizontalPosition? = .center) {
        self.vertical = vertical
        self.horizontal = horizontal
    }
}
