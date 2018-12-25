//
//  ShapeCollectionViewDelegate.swift
//  Photo Editor framework
//
//  Created by Vladimir Tyrin on 22/12/2018.
//

import Foundation
import UIKit

class ShapeCollectionViewDelegate: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    var shapeDelegate: ShapeDelegate?

    /// Shapes can be customized before init of view controller
    var shapes: [PhotoEditorShape] = [
        .line,
        .rectangle,
        .circle,
        .ellipsis,
        .arrow,
    ]

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return shapes.count
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        shapeDelegate?.didSelectShape(shape: shapes[indexPath.item])
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ShapeCollectionViewCell", for: indexPath) as! ShapeCollectionViewCell
        cell.shapeImageView.image = shapes[indexPath.item].icon
        return cell
    }
}
