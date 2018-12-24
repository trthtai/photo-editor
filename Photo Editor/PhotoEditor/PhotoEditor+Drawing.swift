//
//  PhotoEditor+Drawing.swift
//  Photo Editor
//
//  Created by Mohamed Hamed on 6/16/17.
//
//

import UIKit

extension PhotoEditorViewController {

    override public func touchesBegan(_ touches: Set<UITouch>,
                                      with event: UIEvent?) {
        swiped = false
        initialImage = canvasImageView.image

        let shapeImageView = UIImageView(frame: imageView.frame)
        addGestures(view: shapeImageView)
        canvasImageView.addSubview(shapeImageView)
        shapeLayers.append(shapeImageView)

        if let touch = touches.first {
            firstPoint = touch.location(in: self.canvasImageView)
            lastPoint = firstPoint
        }
    }

    override public func touchesMoved(_ touches: Set<UITouch>,
                                      with event: UIEvent?) {
        swiped = true
        switch mode {
        case .freeDrawing:
            if let touch = touches.first {
                let currentPoint = touch.location(in: canvasImageView)
                drawLineFrom(lastPoint, toPoint: currentPoint)

                lastPoint = currentPoint
            }
        case .shapeDrawing:
            if let touch = touches.first {
                let currentPoint = touch.location(in: canvasImageView)
                if let shape = selectedShape {
                    shape.draw(in: shapeLayers.last!, from: firstPoint, via: lastPoint, to: currentPoint, using: drawColor, backingTo: initialImage)
                }

                lastPoint = currentPoint
            }

        default:
            break
        }
    }

    override public func touchesEnded(_ touches: Set<UITouch>,
                                      with event: UIEvent?) {
        if let lastLayer = shapeLayers.last {
            if lastLayer.image == nil {
                lastLayer.removeFromSuperview()
            }
        }

        switch mode {
        case .freeDrawing:
            if !swiped {
                // draw a single point
                drawLineFrom(lastPoint, toPoint: lastPoint)
            }
        case .shapeDrawing:
            if !swiped {
                if let shape = selectedShape {
                    shape.draw(in: canvasImageView, from: firstPoint, via: lastPoint, to: nil, using: drawColor, backingTo: initialImage)
                }
            }
            mode = .shapePositioning
        case .labelInput, .labelPositioning, .normal, .shapePositioning:
            break
        }
    }

    func drawLineFrom(_ fromPoint: CGPoint, toPoint: CGPoint) {
        // 1
        UIGraphicsBeginImageContext(canvasImageView.frame.size)
        if let context = UIGraphicsGetCurrentContext() {
            canvasImageView.image?.draw(in: CGRect(x: 0, y: 0, width: canvasImageView.frame.size.width, height: canvasImageView.frame.size.height))
            // 2
            context.move(to: CGPoint(x: fromPoint.x, y: fromPoint.y))
            context.addLine(to: CGPoint(x: toPoint.x, y: toPoint.y))
            // 3
            context.setLineCap(CGLineCap.round)
            context.setLineWidth(5.0)
            context.setStrokeColor(drawColor.cgColor)
            context.setBlendMode( CGBlendMode.normal)
            // 4
            context.strokePath()
            // 5
            canvasImageView.image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        UIGraphicsEndImageContext()
    }

}
