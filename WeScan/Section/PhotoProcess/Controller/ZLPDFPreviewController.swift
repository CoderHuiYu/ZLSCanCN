//
//  ZLPDFPreviewController.swift
//  WeScan
//
//  Created by Tyoung on 2018/12/17.
//  Copyright © 2018 WeTransfer. All rights reserved.
//

import UIKit
import QuickLook

class ZLPDFPreviewController: ZLScannerBasicViewController, QLPreviewControllerDelegate,QLPreviewControllerDataSource, ZLPDFMenuViewProtocol{
    
    private var pdfPath: String?
    private let menuView = ZLPDFMenuView()
    private lazy var previewController: QLPreviewController = {
        let previewController = QLPreviewController()
        previewController.delegate = self
        previewController.dataSource = self
        previewController.currentPreviewItemIndex = 1
        let spaceY: CGFloat = iPhoneX ? -30 : 0
        previewController.view.frame = CGRect(x: 0, y: spaceY, width: kScreenWidth, height: kScreenHeight)
        return previewController
    }()
    init(pdfPath: String) {
        super.init(nibName: nil, bundle: nil)
        self.pdfPath = pdfPath
        menuView.delegate = self
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        viewConfig()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    private func viewConfig() {
        title = pdfPath?.components(separatedBy: "/").last
        addChild(previewController)
        view.addSubview(previewController.view)
        previewController.didMove(toParent: self)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightNavButton)
    }
    // MARK: Delegate
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return URL.init(fileURLWithPath: pdfPath!) as QLPreviewItem
    }
    // MARK: Action
    override func backBtnClicked() {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    override func rightNavButtonClicked() {
        menuView.showMenuView()
    }
    func menuDidSelected(_ index: Int) {
        switch index {
        case 0:
            editPDF()
        case 1:
            renamePDF()
        case 2:
            deletePDF()
        default:
            break
        }
    }
    private func editPDF() {
        let vc = ZLPhotoEditorController.init(nibName: "ZLPhotoEditorController", bundle: Bundle(for: ZLPhotoEditorController.self))
        vc.isNeedLoadPDF = true
        navigationController?.pushViewController(vc, animated: true)
    }
    private func deletePDF() {
        showAlter(title: "Do you want to delete this file?", message: "", confirm: "Delete", cancel: "Cancel", confirmComp: { (_) in
            //confirm delete PDF file
        }) { (_) in }
    }
    private func renamePDF() {
        let fileName = pdfPath?.components(separatedBy: "/").last?.components(separatedBy: ".").first
        let alter = UIAlertController(style: .actionSheet)
        alter.addScanRenameViewController(fileName ?? "")
        alter.show(vc: self.navigationController)
    }
}
