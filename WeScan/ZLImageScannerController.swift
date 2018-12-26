//
//  ZLImageScannerController.swift
//  WeScan
//
//  Created by Tyoung on 2018/12/17.
//  Copyright © 2018 WeTransfer. All rights reserved.
//

import UIKit

public final class ZLImageScannerController: UINavigationController {
    private var handleCallBack: ((NSData)->())?
    internal let blackFlashView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    public required init(withOriginalPdfPath pdfPath: String?, handle: @escaping (_ pdfData: NSData)->()) {
        // accept data notification
        if let path = pdfPath {
            let vc = ZLPDFPreviewController(pdfPath: path)
            super.init(rootViewController: vc)
        }else{
            let scannerViewController = ZLScannerViewController()
            super.init(rootViewController: scannerViewController)
            navigationBar.tintColor = .black
            navigationBar.isTranslucent = false
            self.view.addSubview(blackFlashView)
            setupConstraints()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(receivedPDFData(_:)), name: NSNotification.Name.init(kZLSavePDFSuccessNotificationName), object: nil)
        handleCallBack = handle
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    private func setupConstraints() {
        let blackFlashViewConstraints = [
            blackFlashView.topAnchor.constraint(equalTo: view.topAnchor),
            blackFlashView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            view.bottomAnchor.constraint(equalTo: blackFlashView.bottomAnchor),
            view.trailingAnchor.constraint(equalTo: blackFlashView.trailingAnchor)
        ]
        
        NSLayoutConstraint.activate(blackFlashViewConstraints)
    }
    
    override public var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    private func flashToBlack() {
        view.bringSubviewToFront(blackFlashView)
        blackFlashView.isHidden = false
        let flashDuration = DispatchTime.now() + 0.05
        DispatchQueue.main.asyncAfter(deadline: flashDuration) {
            self.blackFlashView.isHidden = true
        }
    }
    
    @objc private func receivedPDFData(_ info: Notification) {
        guard let data = info.object as? NSData else {
            return
        }
        if let callBack = handleCallBack {
            callBack(data)
        }
    }
}
/// Data structure containing information about a scan.
public struct ZLImageScannerResults {
    
    /// The original image taken by the user, prior to the cropping applied by WeScan.
    public var originalImage: UIImage
    
    /// The deskewed and cropped orignal image using the detected rectangle, without any filters.
    public var scannedImage: UIImage
    
    /// The enhanced image, passed through an Adaptive Thresholding function. This image will always be grayscale and may not always be available.
    public var enhancedImage: UIImage?
    
    /// Whether the user wants to use the enhanced image or not. The `enhancedImage`, for use with OCR or similar uses, may still be available even if it has not been selected by the user.
    public var doesUserPreferEnhancedImage: Bool
    
    /// The detected rectangle which was used to generate the `scannedImage`.
    public var detectedRectangle: ZLQuadrilateral
    
}
