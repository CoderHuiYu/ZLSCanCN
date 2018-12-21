//
//  ZLScanRenameViewController.swift
//  WeScan
//
//  Created by Tyoung on 2018/12/21.
//  Copyright © 2018 WeTransfer. All rights reserved.
//

import UIKit
private let scanRenameVCHeight: CGFloat = 500

extension UIAlertController {
    func addScanRenameViewController() {
        let shareVC = ZLScanRenameViewController()
        set(vc: shareVC, height: scanRenameVCHeight)
    }
}

class ZLScanRenameViewController: UIViewController {
    
    private lazy var toolView: UIView = {
        let toolView = UIView()
        toolView.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: 50)
        toolView.backgroundColor = .lightGray
        return toolView
    }()
    private lazy var cancelBtn: UIButton = {
        let cancelBtn = UIButton()
        cancelBtn.frame = CGRect(x: 0, y: 0, width: 50, height: 80)
        cancelBtn.setTitle("Cancel", for: .normal)
        cancelBtn.setTitleColor(globalColor, for: .normal)
        cancelBtn.addTarget(self, action: #selector(cancelBtnClick), for: .touchUpInside)
        return cancelBtn
    }()
    private lazy var saveBtn: UIButton = {
        let saveBtn = UIButton()
        saveBtn.frame = CGRect(x: toolView.frame.size.width-50, y: 0, width: 50, height: 80)
        saveBtn.setTitle("Save", for: .normal)
        saveBtn.setTitleColor(globalColor, for: .normal)
        saveBtn.addTarget(self, action: #selector(saveBtnClick), for: .touchUpInside)
        return saveBtn
    }()
    private lazy var renameTitle: UILabel = {
        let renameTitle = UILabel()
        renameTitle.frame = CGRect(x: 0, y: 0, width: 70, height: 50)
        renameTitle.center = toolView.center
        renameTitle.text = "Rename"
        renameTitle.textColor = .black
        renameTitle.font = UIFont.boldSystemFont(ofSize: 16)
        return renameTitle
    }()
    private lazy var textFiled: UITextField = {
        let textFiled = UITextField()
        textFiled.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: 50)
        textFiled.center = view.center
        textFiled.placeholder = "please"
        textFiled.textColor = globalColor
        return textFiled
    }()

    init() {
        super.init(nibName: nil, bundle: nil)
        preferredContentSize.height = scanRenameVCHeight
        view.addSubview(toolView)
        toolView.addSubview(cancelBtn)
        toolView.addSubview(saveBtn)
        toolView.addSubview(renameTitle)
        view.addSubview(textFiled)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @objc func cancelBtnClick(){
        
    }
    @objc func saveBtnClick() {
        
    }
}
