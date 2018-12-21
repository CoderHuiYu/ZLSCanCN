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
    
    @IBOutlet weak var retakeButton: UIButton!
    @IBOutlet weak var rotateButton: UIButton!
    @IBOutlet weak var cropButton: UIButton!
    @IBOutlet weak var enhanceButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
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
    
    lazy var rightButton: UIButton = {
        let button = UIButton()
        button.setTitle("Save", for: .normal)
        button.setTitleColor(globalColor, for: .normal)
        button.addTarget(self, action: #selector(saveAction), for: .touchUpInside)
        return button
    }()
    
    func setupUI() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightButton)
        imageView.image = model?.enhancedImage
    }
   
}

// MARK: - Event
extension ZLPhotoEditingController {
    override func backBtnClick() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func saveAction() {
        if let callBack = saveModelCallBack, let m = model {
            callBack(m)
            navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func itemButtonAction(_ sender: UIButton) {
        // update UI
        switch sender.tag {
        case 0: // retake
            retake()
            navigationController?.popViewController(animated: true)
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
        let editVC = ZLEditScanViewController(image: model.originalImage.applyingPortraitOrientation(), quad: model.detectedRectangle)
        editVC.editCompletion = { [weak self] (result, rect) in
            model.replace(result.originalImage, result.scannedImage, result.scannedImage, model.isEnhanced, rect, handle: { (isSuccess, model) in
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
