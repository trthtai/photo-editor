//
//  CGPoint+Math.swift
//  Photo Editor framework
//
//  Created by Vladimir Tyrin on 23/12/2018.
//

import Foundation

extension CGPoint {
    func angle(to comparisonPoint: CGPoint) -> CGFloat {
        let originX = comparisonPoint.x - self.x
        let originY = comparisonPoint.y - self.y

        return CGFloat(atan2f(Float(originY), Float(originX)))
    }
}

extension CGFloat {
    var degrees: CGFloat {
        return self * CGFloat(180.0 / Double.pi)
    }
}
