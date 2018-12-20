//
//  ZLPDFPreviewController.swift
//  WeScan
//
//  Created by Tyoung on 2018/12/17.
//  Copyright © 2018 WeTransfer. All rights reserved.
//

import UIKit
import QuickLook

class ZLPDFPreviewController: ZLScannerBasicViewController, QLPreviewControllerDelegate,QLPreviewControllerDataSource{
    
    private var pdfPath: String?
    private lazy var preview: QLPreviewController = {
        let preview = QLPreviewController()
        preview.delegate = self
        preview.dataSource = self
        preview.currentPreviewItemIndex = 1
        preview.view.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight)
        return preview
    }()
    private let menuView = ZLPDFMenuView()
    
    init(pdfPath: String){
        super.init(nibName: nil, bundle: nil)
        self.pdfPath = pdfPath
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        viewConfigs()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    private func viewConfigs() {
        title = pdfPath?.components(separatedBy: "/").last
        addChild(preview)
        view.addSubview(preview.view)
        preview.didMove(toParent: self)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rBtn)
    }
    // MARK: Delegate
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return URL.init(fileURLWithPath: pdfPath!) as QLPreviewItem
    }
    override func backBtnClick() {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    override func rBtnClick() {
        menuView.showMenuView()
    }
}
