//
//  ViewController.swift
//  Photo Editor
//
//  Created by Mohamed Hamed on 4/23/17.
//  Copyright © 2017 Mohamed Hamed. All rights reserved.
//

import UIKit

public protocol PhotoEditorDelegate {
    /**
     - Parameter image: edited Image
     */
    func doneEditing(image: UIImage)
    /**
     StickersViewController did Disappear
     */
    func canceledEditing()
}

enum PhotoEditorMode {
    case normal
    case freeDrawing
    case shapeDrawing
    case shapePositioning
    case labelInput
    case labelPositioning
}

public final class PhotoEditorViewController: UIViewController {

    /** holding the 2 imageViews original image and drawing & stickers */
    @IBOutlet weak var canvasView: UIView!
    //To hold the image
    @IBOutlet var imageView: UIImageView!
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    //To hold the drawings and stickers
    @IBOutlet weak var canvasImageView: UIImageView!

    @IBOutlet weak var topToolbar: UIView!
    @IBOutlet weak var bottomToolbar: UIView!

    @IBOutlet weak var topGradient: UIView!
    @IBOutlet weak var bottomGradient: UIView!

    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var undoButton: UIButton!
    @IBOutlet weak var deleteView: UIView!
    @IBOutlet weak var colorsCollectionView: UICollectionView!
    @IBOutlet weak var shapeCollectionView: UICollectionView!
    @IBOutlet weak var colorPickerView: UIView!
    @IBOutlet weak var shapePickerView: UIView!
    @IBOutlet weak var shapeToolsPickerView: UIView!
    @IBOutlet weak var colorPickerViewBottomConstraint: NSLayoutConstraint!

    //Controls
    @IBOutlet weak var cropButton: UIButton!
    @IBOutlet weak var drawButton: UIButton!
    @IBOutlet weak var shapesButton: UIButton!
    @IBOutlet weak var textButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!

    public var image: UIImage?
    /**
     Array of Stickers -UIImage- that the user will choose from
     */
    public var stickers: [UIImage] = []
    /**
     Array of Colors that will show while drawing or typing
     */
    public var colors: [UIColor] = []
    public var shapes: [PhotoEditorShape] = []
    var shapeLayers: [UIImageView] = []

    public var photoEditorDelegate: PhotoEditorDelegate?
    var colorsCollectionViewDelegate: ColorsCollectionViewDelegate!
    var shapeCollectionViewDelegate: ShapeCollectionViewDelegate!

    // list of controls to be hidden
    public var hiddenControls: [PhotoEditorControl] = []

    var drawColor: UIColor = UIColor.black
    var textColor: UIColor = UIColor.white
    var selectedShape: PhotoEditorShape?
    var initialImage: UIImage?
    var firstPoint: CGPoint!
    var lastPoint: CGPoint!
    var lastPanPoint: CGPoint?
    var lastTextViewTransCenter: CGPoint?
    var swiped = false
    var lastTextViewTransform: CGAffineTransform?
    var lastTextViewFont: UIFont?
    var activeTextView: UITextView?
    var imageViewToPan: UIImageView?

    var mode: PhotoEditorMode = .normal {
        didSet {
            switch mode {
            case .normal:
                view.endEditing(true)
                doneButton.isHidden = true
                undoButton.isHidden = true
                colorPickerView.isHidden = true
                shapePickerView.isHidden = true
                canvasImageView.isUserInteractionEnabled = true
                hideToolbar(hide: false)
                deleteView.isHidden = true

            case .freeDrawing:
                canvasImageView.isUserInteractionEnabled = false
                doneButton.isHidden = false
                undoButton.isHidden = true
                colorPickerView.isHidden = false
                shapePickerView.isHidden = true
                hideToolbar(hide: true)
                deleteView.isHidden = true

            case .labelInput:
                doneButton.isHidden = false
                undoButton.isHidden = true
                colorPickerView.isHidden = false
                shapePickerView.isHidden = true
                hideToolbar(hide: true)
                deleteView.isHidden = true

            case .labelPositioning:
                view.endEditing(true)
                canvasImageView.isUserInteractionEnabled = true
                doneButton.isHidden = true
                undoButton.isHidden = true
                colorPickerView.isHidden = true
                shapePickerView.isHidden = true
                hideToolbar(hide: false)
                deleteView.isHidden = false

            case .shapeDrawing:
                canvasImageView.isUserInteractionEnabled = false
                doneButton.isHidden = false
                undoButton.isHidden = false
                shapePickerView.isHidden = false
                colorPickerView.isHidden = false
                hideToolbar(hide: true)
                deleteView.isHidden = true
                
            case .shapePositioning:
                canvasImageView.isUserInteractionEnabled = true
                shapeCollectionView.deselectAllItems(animated: true)
                selectedShape = nil
                doneButton.isHidden = true
                undoButton.isHidden = true
                shapePickerView.isHidden = true
                colorPickerView.isHidden = true
                hideToolbar(hide: false)
                deleteView.isHidden = false
            }
        }
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        self.setImageView(image: image!)

        deleteView.layer.cornerRadius = deleteView.bounds.height / 2
        deleteView.layer.borderWidth = 2.0
        deleteView.layer.borderColor = UIColor.white.cgColor
        deleteView.clipsToBounds = true

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardDidShow),
                                               name: UIResponder.keyboardDidShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillChangeFrame(_:)),
                                               name: UIResponder.keyboardWillChangeFrameNotification,
                                               object: nil)

        configureColorCollectionView()
        configureShapeCollectionView()

        hideControls()
    }

    func configureColorCollectionView() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 30, height: 30)
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        colorsCollectionView.collectionViewLayout = layout
        colorsCollectionViewDelegate = ColorsCollectionViewDelegate()
        colorsCollectionViewDelegate.colorDelegate = self
        if !colors.isEmpty {
            colorsCollectionViewDelegate.colors = colors
        }
        colorsCollectionView.delegate = colorsCollectionViewDelegate
        colorsCollectionView.dataSource = colorsCollectionViewDelegate

        colorsCollectionView.register(
            UINib(nibName: "ColorCollectionViewCell", bundle: Bundle(for: ColorCollectionViewCell.self)),
            forCellWithReuseIdentifier: "ColorCollectionViewCell")
    }

    func configureShapeCollectionView() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 50, height: 50)
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 4

        shapeCollectionView.collectionViewLayout = layout
        shapeCollectionViewDelegate = ShapeCollectionViewDelegate()
        shapeCollectionViewDelegate.shapeDelegate = self
        if !shapes.isEmpty {
            shapeCollectionViewDelegate.shapes = shapes
        }
        shapeCollectionView.delegate = shapeCollectionViewDelegate
        shapeCollectionView.dataSource = shapeCollectionViewDelegate

        shapeCollectionView.register(
            UINib(nibName: "ShapeCollectionViewCell", bundle: Bundle(for: ShapeCollectionViewCell.self)),
            forCellWithReuseIdentifier: "ShapeCollectionViewCell")
    }

    func setImageView(image: UIImage) {
        imageView.image = image
        let size = image.suitableSize(widthLimit: UIScreen.main.bounds.width)
        imageViewHeightConstraint.constant = (size?.height)!
    }

    func hideToolbar(hide: Bool) {
        topToolbar.isHidden = hide
        topGradient.isHidden = hide
        bottomToolbar.isHidden = hide
        bottomGradient.isHidden = hide
    }
}

extension PhotoEditorViewController: ColorDelegate {
    func didSelectColor(color: UIColor) {
        switch mode {
        case .freeDrawing, .shapeDrawing, .shapePositioning, .normal:
            self.drawColor = color
        case .labelInput, .labelPositioning:
            activeTextView?.textColor = color
            textColor = color
        }
    }
}
