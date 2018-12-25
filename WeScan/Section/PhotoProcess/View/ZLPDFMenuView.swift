//
//  ZLPDFMenuView.swift
//  WeScan
//
//  Created by Tyoung on 2018/12/19.
//  Copyright © 2018 WeTransfer. All rights reserved.
//

import UIKit

protocol ZLPDFMenuViewProtocol: NSObjectProtocol {
    func menuDidSelected(_ index: Int)
}

class ZLPDFMenuView: UIView {
    private var imageArray = ["zilly-scan-edit","zilly-scan-rename","zilly-scan-delete"]
    private var titleArray = ["Edit","Rename","Delete"]
    
    weak var delegate: ZLPDFMenuViewProtocol?
    
    lazy var menuTableView: UITableView = {
        let menuTableView = UITableView(frame: CGRect(x: kScreenWidth-180, y: kNavHeight, width: 130, height: 126), style: .plain)
        menuTableView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        menuTableView.layer.anchorPoint = CGPoint(x: 1, y: 0)
        let spaceY: CGFloat = iPhoneX ? 90 : 70
        menuTableView.layer.position = CGPoint(x: 360, y: spaceY)
        menuTableView.showsVerticalScrollIndicator = false;
        menuTableView.bounces = false
        menuTableView.delegate = self
        menuTableView.dataSource = self
        menuTableView.backgroundColor = .white
        menuTableView.layer.borderColor = UIColor.lightGray.cgColor
        menuTableView.layer.borderWidth = 0.5
        menuTableView.layer.cornerRadius = 5.0
        menuTableView.rowHeight = 42
        menuTableView.separatorStyle = .none
        menuTableView.register(ZLPDFMenuViewCell.self, forCellReuseIdentifier: ZLPDFMenuViewCell.ZlPDFMenuViewCellID)
        return menuTableView
    }()
    private var selectIndex : Int?
    private var blackClick : UIButton?
    
    override init(frame: CGRect) {
        let mainFrame = CGRect(x:0,y: 0,width: kScreenWidth, height:kScreenHeight )
        super.init(frame: mainFrame)
        viewConfigs()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func viewConfigs() {
        selectIndex = 0
        blackClick = UIButton(frame:self.frame)
        blackClick!.addTarget(self, action:  #selector(ZLPDFMenuView.hideMenu), for: .touchUpInside)
        self.addSubview(blackClick!)
        backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
        self.addSubview(menuTableView)
    }
}
extension ZLPDFMenuView: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titleArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = ZLPDFMenuViewCell(style: .default, reuseIdentifier: ZLPDFMenuViewCell.ZlPDFMenuViewCellID)
        cell.modelConfig(UIImage(named: imageArray[indexPath.item], in: Bundle.init(for: self.classForCoder), compatibleWith: nil)!, text: titleArray[indexPath.item])
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 42
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectIndex = indexPath.row
        hideMenuView()
        delegate?.menuDidSelected(selectIndex!)
    }
    @objc func hideMenu() {
        hideMenuView()
    }
    func showMenuView() {
        menuTableView.reloadData()
        let window = UIApplication.shared.keyWindow
        window!.addSubview(self)
        UIView.animate(withDuration: 0.3, animations: {
            self.menuTableView.transform = CGAffineTransform(scaleX: 1, y: 1)
        }, completion: {
            finished in
            
        })
    }
    private func hideMenuView() {
        UIView.animate(withDuration: 0.3, animations: {
            self.menuTableView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        }, completion: {
            finished in
            self.removeFromSuperview()
        })
    }
}
