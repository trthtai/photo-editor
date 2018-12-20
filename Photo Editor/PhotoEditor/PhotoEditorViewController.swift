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
    @IBOutlet weak var deleteView: UIView!
    @IBOutlet weak var colorsCollectionView: UICollectionView!
    @IBOutlet weak var colorPickerView: UIView!
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

    public var photoEditorDelegate: PhotoEditorDelegate?
    var colorsCollectionViewDelegate: ColorsCollectionViewDelegate!

    // list of controls to be hidden
    public var hiddenControls: [PhotoEditorControl] = []

    var drawColor: UIColor = UIColor.black
    var textColor: UIColor = UIColor.white
    var shape: PhotoEditorShape? = .line
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
                colorPickerView.isHidden = true
                canvasImageView.isUserInteractionEnabled = true
                hideToolbar(hide: false)

            case .freeDrawing:
                canvasImageView.isUserInteractionEnabled = false
                doneButton.isHidden = false
                colorPickerView.isHidden = false
                hideToolbar(hide: true)

            case .labelInput:
                break
            case .labelPositioning:
                break
            case .shapeDrawing:
                canvasImageView.isUserInteractionEnabled = false
                doneButton.isHidden = false
                colorPickerView.isHidden = false
                hideToolbar(hide: true)
                break
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

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow),
                                               name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(_:)),
                                               name: UIResponder.keyboardWillChangeFrameNotification, object: nil)

        configureCollectionView()
        hideControls()
    }

    func configureCollectionView() {
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
        case .freeDrawing:
            self.drawColor = color
        case .labelInput, .labelPositioning:
            activeTextView?.textColor = color
            textColor = color
        default:
            break
        }
    }
}
