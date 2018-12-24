//
//  PhotoEditor+Controls.swift
//  Pods
//
//  Created by Mohamed Hamed on 6/16/17.
//
//

import Foundation
import UIKit

// MARK: - Control
public enum PhotoEditorControl {
    case crop
    case draw
    case text
    case save
    case share
    case clear
}

extension PhotoEditorViewController {
    @IBAction func cancelButtonDidTouchInside(_ sender: Any) {
        photoEditorDelegate?.canceledEditing()
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func cropButtonDidTouchInside(_ sender: UIButton) {
        let controller = CropViewController()
        controller.delegate = self
        controller.image = image
        let navController = UINavigationController(rootViewController: controller)
        present(navController, animated: true, completion: nil)
    }

    @IBAction func drawButtonDidTouchInside(_ sender: Any) {
        mode = .freeDrawing
    }

    @IBAction func shapesButtonDidTouchInside(_ sender: Any) {
        mode = .shapeDrawing
    }

    @IBAction func undoButtonDidTouchInside(_ sender: Any) {
        shapeLayers.last?.removeFromSuperview()
    }

    @IBAction func textButtonDidTouchInside(_ sender: Any) {
        mode = .labelInput
        let textView = UITextView(frame: CGRect(x: 0, y: canvasImageView.center.y,
                                                width: UIScreen.main.bounds.width, height: 30))

        textView.textAlignment = .center
        textView.font = UIFont(name: "Helvetica", size: 30)
        textView.textColor = textColor
        textView.layer.shadowColor = UIColor.black.cgColor
        textView.layer.shadowOffset = CGSize(width: 1.0, height: 0.0)
        textView.layer.shadowOpacity = 0.2
        textView.layer.shadowRadius = 1.0
        textView.layer.backgroundColor = UIColor.clear.cgColor
        textView.autocorrectionType = .no
        textView.isScrollEnabled = false
        textView.delegate = self
        self.canvasImageView.addSubview(textView)
        addGestures(view: textView)
        textView.becomeFirstResponder()
    }

    @IBAction func doneButtonDidTouchInside(_ sender: Any) {
        mode = .normal
    }

    // MARK: Bottom Toolbar

    @IBAction func saveButtonDidTouchInside(_ sender: AnyObject) {
        UIImageWriteToSavedPhotosAlbum(canvasView.toImage(), self, #selector(PhotoEditorViewController.image(_:withPotentialError:contextInfo:)), nil)
    }

    @IBAction func shareButtonDidTouchInside(_ sender: UIButton) {
        let activity = UIActivityViewController(activityItems: [canvasView.toImage()], applicationActivities: nil)
        present(activity, animated: true, completion: nil)

    }

    @IBAction func clearButtonDidTouchInside(_ sender: AnyObject) {
        //clear drawing
        canvasImageView.image = nil
        //clear stickers and textviews
        for subview in canvasImageView.subviews {
            subview.removeFromSuperview()
        }
    }

    @IBAction func continueButtonDidTouchInside(_ sender: Any) {
        let img = self.canvasView.toImage()
        photoEditorDelegate?.doneEditing(image: img)
        self.dismiss(animated: true, completion: nil)
    }

    //MAKR: helper methods

    @objc
    func image(_ image: UIImage, withPotentialError error: NSErrorPointer, contextInfo: UnsafeRawPointer) {
        let alert = UIAlertController(
            title: NSLocalizedString("Image Saved", bundle: Bundle(for: PhotoEditorViewController.self), comment: "Alert title"),
            message: NSLocalizedString("Image successfully saved to Photos library", bundle: Bundle(for: PhotoEditorViewController.self), comment: "Alert message"),
            preferredStyle: UIAlertController.Style.alert
        )
        alert.addAction(UIAlertAction(
            title: NSLocalizedString("OK", bundle: Bundle(for: PhotoEditorViewController.self), comment: "Alert action button title"),
            style: UIAlertAction.Style.default,
            handler: nil)
        )
        self.present(alert, animated: true, completion: nil)
    }

    func hideControls() {
        for control in hiddenControls {
            button(for: control).isHidden = true
        }
    }

    func button(for control: PhotoEditorControl) -> UIButton {
        switch control {

        case .clear:
            return clearButton
        case .crop:
            return cropButton
        case .draw:
            return drawButton
        case .save:
            return saveButton
        case .share:
            return shareButton
        case .text:
            return textButton
        }
    }
}
