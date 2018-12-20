//
//  PhotoEditor+Shapes.swift
//  Photo Editor
//

import Foundation

enum PhotoEditorShape {
    case line
    case curvedLine
    case circle
    case ellipsis
    case rectangle
    case arrow
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
        }
    }

    var shouldClearContextOnMove: Bool {
        switch self {
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
                    context.addLine(to: CGPoint(x: onePoint.x, y: lastPoint.y))
                    context.addLine(to: lastPoint)
                    context.addLine(to: CGPoint(x: lastPoint.x, y: onePoint.y))
                    context.addLine(to: onePoint)
                    context.setLineCap(CGLineCap.round)
                    context.setLineWidth(5.0)
                    context.setStrokeColor(drawColor.cgColor)
                    context.setBlendMode(CGBlendMode.normal)
                    context.strokePath()
                    break

                default:
                    break
                }


                imageView.image = UIGraphicsGetImageFromCurrentImageContext()

            }
            UIGraphicsEndImageContext()
        }
    }
}

extension PhotoEditorViewController {

}
