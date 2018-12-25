//
//  ZLPhotoEditingController.swift
//  WeScan
//
//  Created by Mason on 2018/12/19.
//  Copyright © 2018年 WeTransfer. All rights reserved.
//

import UIKit

class ZLPhotoEditingController: ZLScannerBasicViewController {
    var deleteModelCallBack: (()->Void)?
    var saveModelCallBack: ((_ model: ZLPhotoModel)->Void)?
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var rotateButton: ZLCustomButton!
    @IBOutlet weak var cropButton: ZLCustomButton!
    @IBOutlet weak var enhanceButton: ZLCustomButton!
    @IBOutlet weak var deleteButton: ZLCustomButton!
    
    var model: ZLPhotoModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let model = model else { return }
        enhanceButton.isSelected = model.isEnhanced
    }
    
    lazy var leftButton: UIButton = {
        let button = UIButton()
        button.setTitle("Retake", for: .normal)
        button.setTitleColor(globalColor, for: .normal)
        button.titleLabel?.font = basicFont
        button.tag = 0
        button.addTarget(self, action: #selector(itemButtonAction(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var rightButton: UIButton = {
        let button = UIButton()
        button.setTitle("Save", for: .normal)
        button.setTitleColor(globalColor, for: .normal)
        button.titleLabel?.font = basicFont
        button.addTarget(self, action: #selector(saveAction), for: .touchUpInside)
        return button
    }()
    
    func setupUI() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: leftButton)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightButton)
        imageView.image = model?.enhancedImage
    }
}

// MARK: - Event
extension ZLPhotoEditingController {
    override func backBtnClicked() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func saveAction() {
        if let callBack = saveModelCallBack, let m = model {
            callBack(m)
            navigationController?.popViewController(animated: true)
        }
    }
    
    @objc @IBAction func itemButtonAction(_ sender: UIButton) {
        // update UI
        switch sender.tag {
        case 0: // retake
            retake()
            break
        case 1: // rotate
            rotate()
            break
        case 2: // crop
            crop()
            break
        case 3: // enhance
            enhance()
            break
        case 4: // delete
            delete()
            break
        default:
            break
        }
    }
}

// MARK: -
extension ZLPhotoEditingController {
    fileprivate func retake() {
        let vc = ZLScannerViewController()
        vc.isFromEdit = true
        vc.captureImageCallBack = { [weak self] (result) in
            self?.model?.originalImage = result.originalImage
            self?.model?.enhancedImage = result.enhancedImage ?? result.scannedImage
            self?.model?.scannedImage = result.scannedImage
            self?.model?.detectedRectangle = result.detectedRectangle
            self?.model?.isEnhanced = true
            self?.enhanceButton.isSelected = true
            self?.imageView.image = self?.model?.enhancedImage
        }
        ZLScanCaptureSession.current.isPreviewing = false
        ZLScanCaptureSession.current.isEditing = false
        ZLScanCaptureSession.current.autoScanEnabled = true
        ZLScanCaptureSession.current.editImageOrientation = .up
        navigationController?.pushViewController(vc, animated: true)
    }
    
    fileprivate func rotate() {
        guard let model = model else { return }
        let orientaiton = UIImage.Orientation.right
        self.model?.originalImage = model.originalImage.rotateImage(orientaiton)
        self.model?.scannedImage = model.scannedImage.rotateImage(orientaiton)
        self.model?.enhancedImage = model.enhancedImage.rotateImage(orientaiton)
        self.imageView.image = self.model?.enhancedImage
    }
    
    fileprivate func crop() {
        guard let model = model else { return }
        let editVC = ZLEditScanViewController(image: model.originalImage, quad: model.detectedRectangle)
        editVC.editCompletion = { [weak self] (result) in
            model.replace(result.originalImage, result.scannedImage, result.scannedImage, model.isEnhanced, result.detectedRectangle, handle: { (isSuccess, model) in
                if isSuccess {
                    guard let m = model else { return }
                    self?.imageView.image = m.enhancedImage
                }
            })
        }
        navigationController?.pushViewController(editVC, animated: true)
    }
    
    fileprivate func enhance() {
        guard let model = model else { return }
        if !model.isEnhanced {
            self.model?.enhancedImage = model.enhancedImage.colorControImage() ?? model.scannedImage
            self.model?.isEnhanced = true
            self.enhanceButton.isSelected = true
        } else {
            self.model?.enhancedImage = model.scannedImage
            self.model?.isEnhanced = false
            self.enhanceButton.isSelected = false
        }
        self.imageView.image = self.model?.enhancedImage
    }
    
    fileprivate func delete() {
        model?.remove(handle: { (isSuccess) in
            if isSuccess {
                if let callBack = deleteModelCallBack {
                    callBack()
                    navigationController?.popViewController(animated: true)
                }
            }
        })
    }
}
