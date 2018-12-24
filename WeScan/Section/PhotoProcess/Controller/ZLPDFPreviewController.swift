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
    private lazy var preview: QLPreviewController = {
        let preview = QLPreviewController()
        preview.delegate = self
        preview.dataSource = self
        preview.currentPreviewItemIndex = 1
        let spaceY: CGFloat = iPhoneX ? -30 : 0
        preview.view.frame = CGRect(x: 0, y: spaceY, width: kScreenWidth, height: kScreenHeight)
        return preview
    }()
    private let menuView = ZLPDFMenuView()
    
    init(pdfPath: String){
        super.init(nibName: nil, bundle: nil)
        self.pdfPath = pdfPath
        menuView.delegate = self
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
    func menuDidSelected(_ index: Int) {
        switch index {
        case 0:
            sharePDF()
        case 1:
            editPDF()
        case 2:
            renamePDF()
        case 3:
            deletePDF()
        default:
            break
        }
    }
    private func sharePDF() {
        let text = "test"
        let shareUrl = URL(fileURLWithPath: pdfPath!)
        let items: [Any] = [text, shareUrl]
        let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(activityVC, animated: true, completion: nil)
    }
    private func editPDF() {
        let vc = ZLPhotoEditorController.init(nibName: "ZLPhotoEditorController", bundle: Bundle(for: ZLPhotoEditorController.self))
        vc.isNeedLoadPDF = true
        navigationController?.pushViewController(vc, animated: true)
    }
    private func deletePDF() {
        showAlter(title: "Do you want to delete this file?", message: "", confirm: "Delete", cancel: "Cancel", confirmComp: { (_) in
            
        }) { (_) in }
    }
    private func renamePDF() {
        let fileName = pdfPath?.components(separatedBy: "/").last?.components(separatedBy: ".").first
        let alter = UIAlertController(style: .actionSheet)
        alter.addScanRenameViewController(fileName ?? "")
        alter.show(vc: self.navigationController)
    }
}
