//
//  ShapeCollectionViewCell.swift
//  Photo Editor framework
//
//  Created by Vladimir Tyrin on 22/12/2018.
//

import Foundation
import UIKit

protocol ShapeDelegate {
    func didSelectShape(shape: PhotoEditorShape)
    var selectedShape: PhotoEditorShape? { get set }
}

class ShapeCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var shapeView: UIView!
    @IBOutlet weak var shapeImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        shapeView.clipsToBounds = true
        shapeView.layer.borderWidth = 3.0
        shapeView.layer.cornerRadius = shapeView.frame.width / 5
        shapeImageView.layer.cornerRadius = shapeView.frame.width / 5
        shapeImageView.backgroundColor = backgroundColor
    }

    override var isSelected: Bool {
        didSet {
            if isSelected {
                let previouTransform =  shapeView.transform
                UIView.animate(
                    withDuration: 0.2,
                    animations: {
                        self.shapeView.transform = self.shapeView.transform.scaledBy(x: 1.3, y: 1.3)
                    },
                    completion: { _ in
                        UIView.animate(withDuration: 0.2) {
                            self.shapeView.transform  = previouTransform
                        }
                    }
                )

                shapeImageView.backgroundColor = tintColor
            } else {
                shapeImageView.backgroundColor = backgroundColor
            }
        }
    }
}
