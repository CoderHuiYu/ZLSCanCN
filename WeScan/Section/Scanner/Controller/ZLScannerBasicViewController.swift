//
//  ZLScannerBasicViewController.swift
//  WeScan
//
//  Created by Tyoung on 2018/12/17.
//  Copyright © 2018 WeTransfer. All rights reserved.
//

import UIKit

class ZLScannerBasicViewController: UIViewController {
    //compeleteHandle
    var dismissWithPDFPath: ((_ pdfPath: String)->())?
    var dismissCallBackIndex: ((_ index: Int?)->())?
    var dismissCallBack: ((String)->())?
    private lazy var backBtn: UIButton = {
        let backBtn = UIButton()
        backBtn.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        backBtn.setTitleColor(globalColor, for: .normal)
        backBtn.setTitle("Back", for: .normal)
        backBtn.addTarget(self, action: #selector(backBtnClick), for: .touchUpInside)
        return backBtn
    }()
    lazy var rBtn: UIButton = {
        let rBtn = UIButton()
        rBtn.frame = CGRect(x: kScreenWidth-44, y: 0, width: 44, height: 44)
        rBtn.setTitle("Edit", for: .normal)
        rBtn.setTitleColor(globalColor, for: .normal)
        rBtn.addTarget(self, action: #selector(rBtnClick), for: .touchUpInside)
        return rBtn
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        navigationController?.navigationBar.isTranslucent = false
        addBackBtn()
    }
    func bottomView(title: String) -> UIView {
        let bottomView = UIView()
        bottomView.backgroundColor = .white
        bottomView.frame = CGRect(x: 0, y: kScreenHeight-80-kNavHeight, width: kScreenWidth, height: 80)
        let bottomBtn = UIButton()
        bottomBtn.frame = CGRect(x: 15, y: 15, width: kScreenWidth-30 , height: 50)
        bottomBtn.setTitle(title, for: .normal)
        bottomBtn.setTitleColor(.white, for: .normal)
        bottomBtn.addTarget(self, action: #selector(bottomBtnClick), for: .touchUpInside)
        bottomBtn.layer.cornerRadius = 5.0
        bottomBtn.layer.masksToBounds = true
        bottomBtn.getGradientColor()
        bottomView.addSubview(bottomBtn)
        return bottomView
    }
    private func addBackBtn(){
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backBtn)
    }
}
extension ZLScannerBasicViewController {
    @objc func backBtnClick() {}
    @objc func bottomBtnClick() {}
    @objc func rBtnClick() {}
    
    func showAlter(title: String, message: String, confirm: String, cancel: String,confirmComp:@escaping ((UIAlertAction)->()),cancelComp:@escaping ((UIAlertAction)->())){
        let confirmAlt = UIAlertAction(title: confirm, style: .default, handler: confirmComp)
        let cancelAlt  = UIAlertAction(title: cancel, style: .default, handler: cancelComp)
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(confirmAlt)
        alert.addAction(cancelAlt)
        present(alert, animated: true, completion: nil)
    }
    
    func showAlterO(title: String ,confirmComp: @escaping ((UIAlertAction)->())){
        let confirAlt = UIAlertAction(title: "OK", style: .cancel, handler: confirmComp)
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        alert.addAction(confirAlt)
        present(alert, animated: true, completion: nil)
    }
}
