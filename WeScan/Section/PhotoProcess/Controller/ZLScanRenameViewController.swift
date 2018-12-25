//
//  ZLScanRenameViewController.swift
//  WeScan
//
//  Created by Tyoung on 2018/12/21.
//  Copyright © 2018 WeTransfer. All rights reserved.
//

import UIKit
private let scanRenameVCHeight: CGFloat = 400

extension UIAlertController {
    func addScanRenameViewController(_ fileName: String) {
        let shareVC = ZLScanRenameViewController(text: fileName)
        set(vc: shareVC, height: scanRenameVCHeight)
    }
}

class ZLScanRenameViewController: UIViewController {
    
    private lazy var toolView: UIView = {
        let toolView = UIView()
        toolView.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: 50)
        toolView.backgroundColor = UIColor(red: 250, green: 250, blue: 250, alpha: 1)
        return toolView
    }()
    private lazy var cancelBtn: UIButton = {
        let cancelBtn = UIButton()
        cancelBtn.frame = CGRect(x: 0, y: 0, width: 80, height: 50)
        cancelBtn.setTitle("Cancel", for: .normal)
        cancelBtn.setTitleColor(globalColor, for: .normal)
        cancelBtn.addTarget(self, action: #selector(cancelBtnClick), for: .touchUpInside)
        return cancelBtn
    }()
    private lazy var saveBtn: UIButton = {
        let saveBtn = UIButton()
        saveBtn.frame = CGRect(x: toolView.frame.size.width-85, y: 0, width: 80, height: 50)
        saveBtn.setTitle("Save", for: .normal)
        saveBtn.setTitleColor(globalColor, for: .normal)
        saveBtn.addTarget(self, action: #selector(saveBtnClick), for: .touchUpInside)
        return saveBtn
    }()
    private lazy var renameTitle: UILabel = {
        let renameTitle = UILabel()
        renameTitle.frame = CGRect(x: 0, y: 0, width: 80, height: 50)
        renameTitle.center = toolView.center
        renameTitle.text = "Rename"
        renameTitle.textColor = .black
        renameTitle.font = UIFont.boldSystemFont(ofSize: 16)
        return renameTitle
    }()
    private lazy var textField: UITextField = {
        let textField = UITextField()
        let width = getTexWidth(textStr: text, font: UIFont.boldSystemFont(ofSize: 32), height: 38)
        textField.frame = CGRect(x: (kScreenWidth-width)/2, y: 150, width: width, height: 38)
        textField.text = text
        textField.textColor = .black
        textField.font = UIFont.boldSystemFont(ofSize: 32)
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        return textField
    }()
    private var text: String = ""
    init(text: String) {
        super.init(nibName: nil, bundle: nil)
        self.text = text
        preferredContentSize.height = scanRenameVCHeight
        view.addSubview(toolView)
        toolView.addSubview(cancelBtn)
        toolView.addSubview(saveBtn)
        toolView.addSubview(renameTitle)
        view.addSubview(textField)
        textField.becomeFirstResponder()
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }
    @objc func cancelBtnClick() {
        dismiss(animated: true, completion: nil)
    }
    @objc func saveBtnClick() {
        dismiss(animated: true, completion: nil)
    }
    @objc func textFieldDidChange(_ textFied: UITextField){
        let width = getTexWidth(textStr: textFied.text!, font: UIFont.boldSystemFont(ofSize: 38), height: 50)
        textFied.frame = CGRect(x: (kScreenWidth-width)/2, y: 150, width: width, height: 38)
        if width == kScreenWidth {
            textFied.frame = CGRect(x: 0, y: 80, width: width, height: 38)
        }
    }
    private func getTexWidth(textStr:String,font:UIFont,height:CGFloat) -> CGFloat {
        let normalText: NSString = textStr as NSString
        let size =  CGSize(width: 1000, height: height) // CGSizeMake(1000, height)
        let dic = NSDictionary(object: font, forKey: NSAttributedString.Key.font as NSCopying)
        let stringSize = normalText.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: dic as? [NSAttributedString.Key : Any], context:nil).size
        return stringSize.width
    }
}
