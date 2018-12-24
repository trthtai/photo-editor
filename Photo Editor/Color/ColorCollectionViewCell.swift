//
//  ColorCollectionViewCell.swift
//  Photo Editor
//
//  Created by Mohamed Hamed on 5/1/17.
//  Copyright © 2017 Mohamed Hamed. All rights reserved.
//

import UIKit

protocol ColorDelegate {
    func didSelectColor(color: UIColor)
}

class ColorCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var colorView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        colorView.layer.cornerRadius = colorView.frame.width / 2
        colorView.clipsToBounds = true
        colorView.layer.borderWidth = 3.0
        colorView.layer.borderColor = UIColor.white.cgColor
    }

    override var isSelected: Bool {
        didSet {
            if isSelected {
                let previouTransform =  colorView.transform
                UIView.animate(withDuration: 0.2,
                               animations: {
                                self.colorView.transform = self.colorView.transform.scaledBy(x: 1.3, y: 1.3)
                },
                               completion: { _ in
                                UIView.animate(withDuration: 0.2) {
                                    self.colorView.transform  = previouTransform
                                }
                })

                colorView.layer.borderColor = tintColor.cgColor
            } else {
                colorView.layer.borderColor = UIColor.white.cgColor
            }
        }
    }
}
