//
//  ZLPhotoEditingController.swift
//  WeScan
//
//  Created by Mason on 2018/12/19.
//  Copyright © 2018年 WeTransfer. All rights reserved.
//

import UIKit

class ZLPhotoEditingController: ZLScannerBasicViewController {
    var itemActionCallBack:((_ index: Int)->Void)?
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
    
    lazy var rightButton: UIButton = {
        let button = UIButton()
        button.setTitle("Save", for: .normal)
        button.addTarget(self, action: #selector(saveAction), for: .touchUpInside)
        return button
    }()
    
    func setupUI() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightButton)
        imageView.image = model?.enhancedImage
    }
    
    

    override func backBtnClick() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func saveAction() {
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func itemButtonAction(_ sender: UIButton) {
        // update UI
        switch sender.tag {
        case 0:
            if let itemActionCallBack = itemActionCallBack {
                itemActionCallBack(sender.tag)
            }
            navigationController?.popViewController(animated: true)
            break
        case 1:
            
            break
        case 2:
            
            break
        case 3:
            
            break
        case 4:
            
            break
        default:
            break
        }
        
        if let itemActionCallBack = itemActionCallBack {
            itemActionCallBack(sender.tag)
        }
    }
    
}

extension ZLPhotoEditingController {
    
    
}
