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
    private lazy var backButton: UIBarButtonItem = {
        let backButton = UIButton(frame: CGRect(origin: .zero, size: CGSize(width: 64, height: 32)))
        backButton.addTarget(self, action: #selector(backBtnClicked), for: .touchUpInside)
        backButton.setTitle("Back", for: .normal)
        backButton.setTitleColor(globalColor, for: .normal)
        backButton.titleLabel!.font = basicFont
        backButton.setImage(UIImage(named: "zl_nav_blue", in: Bundle.init(for: self.classForCoder), compatibleWith: nil), for: .normal)
        backButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        backButton.adjustsImageWhenHighlighted = false
        let backButtonWrapper = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 64, height: 32)))
        backButtonWrapper.addSubview(backButton)
        backButton.transform = CGAffineTransform(translationX: -12, y: 0)
        return UIBarButtonItem(customView: backButtonWrapper)
    }()
    lazy var rightNavButton: UIButton = {
        let rightNavButton = UIButton()
        rightNavButton.frame = CGRect(x: kScreenWidth-44, y: 0, width: 44, height: 44)
        rightNavButton.setImage(UIImage(named: "zl_pdf_more2", in: Bundle.init(for: self.classForCoder), compatibleWith: nil), for: .normal)
        rightNavButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 0)
        rightNavButton.addTarget(self, action: #selector(rightNavButtonClicked), for: .touchUpInside)
        return rightNavButton
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
        let bottomSpace: CGFloat = iPhoneX ? 34 : 0
        bottomView.frame = CGRect(x: 0, y: kScreenHeight-80-kNavHeight-bottomSpace, width: kScreenWidth, height: 80)
        let bottomBtn = UIButton()
        bottomBtn.frame = CGRect(x: 15, y: 15, width: kScreenWidth-30 , height: 50)
        bottomBtn.setTitle(title, for: .normal)
        bottomBtn.setTitleColor(.white, for: .normal)
        bottomBtn.addTarget(self, action: #selector(bottomBtnClicked), for: .touchUpInside)
        bottomBtn.layer.cornerRadius = 5.0
        bottomBtn.layer.masksToBounds = true
        bottomBtn.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        bottomBtn.getGradientColor()
        bottomView.addSubview(bottomBtn)
        let lineView = UIView()
        lineView.backgroundColor = COLORFROMHEX(0xdddddd)
        lineView.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: 0.5)
        bottomView.addSubview(lineView)
        return bottomView
    }
    private func addBackBtn() {
        navigationItem.leftBarButtonItem = backButton
    }
}
extension ZLScannerBasicViewController {
    @objc func backBtnClicked() {}
    @objc func bottomBtnClicked() {}
    @objc func rightNavButtonClicked() {}
    
    func showAlter(title: String, message: String, confirm: String, cancel: String,confirmComp:@escaping ((UIAlertAction)->()),cancelComp:@escaping ((UIAlertAction)->())) {
        let confirmAlt = UIAlertAction(title: confirm, style: .default, handler: confirmComp)
        let cancelAlt  = UIAlertAction(title: cancel, style: .default, handler: cancelComp)
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(confirmAlt)
        alert.addAction(cancelAlt)
        present(alert, animated: true, completion: nil)
    }
    
    func showAlterO(title: String ,confirmComp: @escaping ((UIAlertAction)->())) {
        let confirAlt = UIAlertAction(title: "OK", style: .cancel, handler: confirmComp)
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        alert.addAction(confirAlt)
        present(alert, animated: true, completion: nil)
    }
}
