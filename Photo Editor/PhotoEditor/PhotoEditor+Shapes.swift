//
//  PhotoEditor+Shapes.swift
//  Photo Editor
//

import Foundation
import UIKit
import CoreGraphics

public enum PhotoEditorShape {
    case line
    case curvedLine
    case circle
    case ellipsis
    case rectangle
    case arrow
    case custom(icon: UIImage,
                drawingFunction: (
                    _ imageView: UIImageView,
                    _ context: CGContext,
                    _ onePoint: CGPoint,
                    _ lastPoint: CGPoint,
                    _ anotherPoint: CGPoint?,
                    _ drawColor: UIColor,
                    _ initialImage: UIImage?) -> Void,
                shouldClearContextOnMove: Bool
    )
}

extension PhotoEditorShape {
    var icon: UIImage? {
        switch self {
        case .line:
            return UIImage(named: "line-52",
                           in: Bundle(for: PhotoEditorViewController.self),
                           compatibleWith: nil)
        case .curvedLine:
            return UIImage(named: "polyline-52",
                           in: Bundle(for: PhotoEditorViewController.self),
                           compatibleWith: nil)
        case .circle:
            return UIImage(named: "circle-50",
                           in: Bundle(for: PhotoEditorViewController.self),
                           compatibleWith: nil)
        case .ellipsis:
            return UIImage(named: "oval-50",
                           in: Bundle(for: PhotoEditorViewController.self),
                           compatibleWith: nil)
        case .rectangle:
            return UIImage(named: "rectangular-60",
                           in: Bundle(for: PhotoEditorViewController.self),
                           compatibleWith: nil)
        case .arrow:
            return UIImage(named: "up-right-filled-50",
                           in: Bundle(for: PhotoEditorViewController.self),
                           compatibleWith: nil)
        case .custom(icon: let icon, drawingFunction: _, shouldClearContextOnMove: _):
            return icon
        }
    }

    var shouldClearContextOnMove: Bool {
        switch self {
        case .custom(icon: _, drawingFunction: _, shouldClearContextOnMove: let shouldClearContextOnMove):
            return shouldClearContextOnMove
        case .curvedLine:
            return false
        default:
            return true
        }
    }

    func draw(in imageView: UIImageView,
              from onePoint: CGPoint,
              via lastPoint: CGPoint,
              to anotherPoint: CGPoint?,
              using drawColor: UIColor,
              backingTo initialImage: UIImage?
        ) {
        DispatchQueue.main.async {
            if self.shouldClearContextOnMove {
                imageView.image = initialImage
            }
            
            UIGraphicsBeginImageContext(imageView.frame.size)
            if let context = UIGraphicsGetCurrentContext() {

                switch self {
                case .curvedLine:
                    imageView.image?.draw(in: CGRect(x: 0, y: 0, width: imageView.frame.size.width, height: imageView.frame.size.height))
                    context.move(to: lastPoint)
                    if let anotherPoint = anotherPoint {
                        context.addLine(to: anotherPoint)
                    }
                    context.setLineCap(CGLineCap.round)
                    context.setLineWidth(5.0)
                    context.setStrokeColor(drawColor.cgColor)
                    context.setBlendMode(CGBlendMode.normal)
                    context.strokePath()

                case .line:
                    initialImage?.draw(in: CGRect(x: 0, y: 0, width: imageView.frame.size.width, height: imageView.frame.size.height))
                    context.move(to: onePoint)
                    context.addLine(to: lastPoint)
                    context.setLineCap(CGLineCap.round)
                    context.setLineWidth(5.0)
                    context.setStrokeColor(drawColor.cgColor)
                    context.setBlendMode(CGBlendMode.normal)
                    context.strokePath()
                    break

                case .rectangle:
                    initialImage?.draw(in: CGRect(x: 0, y: 0, width: imageView.frame.size.width, height: imageView.frame.size.height))
                    context.move(to: onePoint)
                    context.addLines(between: [
                        onePoint,
                        CGPoint(x: onePoint.x, y: lastPoint.y),
                        lastPoint,
                        CGPoint(x: lastPoint.x, y: onePoint.y),
                        onePoint
                        ])
                    context.setLineCap(CGLineCap.round)
                    context.setLineWidth(5.0)
                    context.setStrokeColor(drawColor.cgColor)
                    context.setBlendMode(CGBlendMode.normal)
                    context.strokePath()
                    break

                case .ellipsis:
                    initialImage?.draw(in: CGRect(x: 0, y: 0, width: imageView.frame.size.width, height: imageView.frame.size.height))
                    context.setLineCap(CGLineCap.round)
                    context.setLineWidth(5.0)
                    context.setStrokeColor(drawColor.cgColor)
                    context.setBlendMode(CGBlendMode.normal)

                    let rectangle = CGRect(origin: onePoint,
                                           size: CGSize(width: lastPoint.x - onePoint.x,
                                                        height: lastPoint.y - onePoint.y))
                    context.addEllipse(in: rectangle)

                    context.strokePath()
                    break

                case .circle:
                    initialImage?.draw(in: CGRect(x: 0, y: 0, width: imageView.frame.size.width, height: imageView.frame.size.height))
                    context.setLineCap(CGLineCap.round)
                    context.setLineWidth(5.0)
                    context.setStrokeColor(drawColor.cgColor)
                    context.setBlendMode(CGBlendMode.normal)

                    let radius = (
                        (lastPoint.x - onePoint.x) * (lastPoint.x - onePoint.x) +
                        (lastPoint.y - onePoint.y) * (lastPoint.y - onePoint.y)
                        ).squareRoot()
                    context.addArc(center: onePoint, radius: radius, startAngle: 0.0, endAngle: 360.0, clockwise: false)

                    context.strokePath()
                    break

                case .arrow:
                    initialImage?.draw(in: CGRect(x: 0, y: 0, width: imageView.frame.size.width, height: imageView.frame.size.height))
                    context.move(to: lastPoint)
                    context.addLine(to: onePoint)

                    let length = (
                        (lastPoint.x - onePoint.x) * (lastPoint.x - onePoint.x) +
                            (lastPoint.y - onePoint.y) * (lastPoint.y - onePoint.y)
                        ).squareRoot()
                    let angle = lastPoint.angle(to: onePoint)

                    context.move(to: lastPoint)
                    context.addLine(to: CGPoint(
                        x: lastPoint.x + cos(angle + 0.35) * length / 4,
                        y: lastPoint.y + sin(angle + 0.35) * length / 4
                    ))

                    context.move(to: lastPoint)
                    context.addLine(to: CGPoint(
                        x: lastPoint.x + cos(angle - 0.35) * length / 4,
                        y: lastPoint.y + sin(angle - 0.35) * length / 4
                    ))

                    context.setLineCap(CGLineCap.round)
                    context.setLineWidth(5.0)
                    context.setStrokeColor(drawColor.cgColor)
                    context.setBlendMode(CGBlendMode.normal)
                    context.strokePath()
                    break

                case .custom(icon: _, drawingFunction: let drawingFunction, shouldClearContextOnMove: _):
                    drawingFunction(imageView, context, onePoint, lastPoint, anotherPoint, drawColor, initialImage)
                }


                imageView.image = UIGraphicsGetImageFromCurrentImageContext()

            }
            UIGraphicsEndImageContext()
        }
    }
}

extension PhotoEditorViewController: ShapeDelegate {
    func didSelectShape(shape: PhotoEditorShape) {
        self.selectedShape = shape
        self.mode = .shapeDrawing
    }
}
