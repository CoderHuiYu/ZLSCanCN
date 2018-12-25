//
//  ZLScannerViewController.swift
//  WeScan
//
//  Created by Boris Emorine on 2/8/18.
//  Copyright © 2018 WeTransfer. All rights reserved.
//

import UIKit
import AVFoundation

private let photoCollectionViewWithBarHeight: CGFloat = 188.0
private let kOpenFlashCD: Double = 3
private let brightValueOpen: Double = -2
private let brightValueClose: Double = 3

let kDeleteShadowViewMaxBottomSpace: CGFloat = 100

/// An enum used to know if the flashlight was toggled successfully.
enum ZLScanFlashResult {
    case successful
    case notSuccessful
}

class ZLScannerViewController: ZLScannerBasicViewController {
    var isFromEdit = false
    weak var fromController: UIViewController?
    var captureImageCallBack: ((_ result: ZLImageScannerResults)->Void)?
    private var captureSessionManager: CaptureSessionManager?
    private let videoPreviewlayer = AVCaptureVideoPreviewLayer()
    private let quadView = ZLQuadrilateralView()
    private var flashEnabled = false
    private var banTriggerFlash = false
    private var disappear: Bool = false
    private var isTouchShutter: Bool = false
    private var isAutoCapture: Bool = true {
        didSet {
            quadView.removeQuadrilateral()
//            promptView.isHidden = !isAutoCapture
            captureSessionManager?.autoCapture = isAutoCapture
        }
    }
    
    private lazy var autoCaptureButton: UIButton = {
        let button = UIButton()
        button.setTitle("Manual", for: .normal)
        button.setTitle("Auto", for: .selected)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.addTarget(self, action: #selector(autoCaptureAction(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var autoCaptureAlertLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 13)
        label.layer.cornerRadius = 4
        label.layer.masksToBounds = true
        return label
    }()
    
    private lazy var autoFlashButton: UIButton = {
        let image = UIImage(named: "zilly-scan-flashOn", in: Bundle(for: ZLScannerViewController.self), compatibleWith: nil)
        let imageS = UIImage(named: "zilly-scan-flashOff", in: Bundle(for: ZLScannerViewController.self), compatibleWith: nil)
        let button = UIButton()
        button.setImage(image, for: .normal)
        button.setImage(imageS, for: .selected)
        button.addTarget(self, action: #selector(flashActionToggle(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var shutterButton: ZLScanShutterButton = {
        let button = ZLScanShutterButton()
        button.addTarget(self, action: #selector(captureImage(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var promptView: ZLScanningPromptView = {
        let promptView = ZLScanningPromptView(frame: .zero)
        return promptView
    }()
    
    private lazy var previewImageView: UIImageView  = {
        let previewImageView = UIImageView()
        previewImageView.contentMode = .scaleAspectFill
        return previewImageView
    }()
    
    private lazy var deleteShadowView: ZLScannerViewController.DeleteShadowView = {
        let view = ZLScannerViewController.DeleteShadowView()
        view.isHidden = true
        return view
    }()
    
    private lazy var photoCollectionView: ZLPhotoWaterFallView = {
        let photoCollectionView = ZLPhotoWaterFallView(frame: CGRect(x: 0, y: view.frame.height - kNavHeight - photoCollectionViewWithBarHeight - kBottomGap, width: view.frame.width, height: photoCollectionViewWithBarHeight + kBottomGap))
        photoCollectionView.backViewColor = UIColor.black
        photoCollectionView.delegate = self
        return photoCollectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Scanning"
        NotificationCenter.default.addObserver(self, selector: #selector(appTerminateAction), name: UIApplication.willTerminateNotification, object: nil)
        setupViews()
        setupConstraints()
        captureSessionManager = CaptureSessionManager(videoPreviewLayer: videoPreviewlayer)
        captureSessionManager?.autoCapture = isAutoCapture
        captureSessionManager?.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        disappear = false
        ZLScanCaptureSession.current.isEditing = false
        ZLScanCaptureSession.current.isPreviewing = false
        quadView.removeQuadrilateral()
        captureSessionManager?.start()
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if isFromEdit {
            videoPreviewlayer.frame = view.layer.bounds
            quadView.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: view.layer.bounds.height - kBottomGap)
        } else {
            videoPreviewlayer.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: view.layer.bounds.height - photoCollectionView.collectionHeight - kBottomGap)
            quadView.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: view.layer.bounds.height - photoCollectionView.collectionHeight - kBottomGap)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        disappear = true
        UIApplication.shared.isIdleTimerDisabled = false
        closeFlash()
        captureSessionManager?.stop()
    }
    
    @objc private func appTerminateAction() {
        // app is killed
        ZLPhotoModel.removeAllModel { (isSuccess) in
            if isSuccess {
                print("remove success")
            }
        }
    }
    
    deinit {
        ZLPhotoModel.removeAllModel { (_) in
        }
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupViews() {
        view.layer.addSublayer(videoPreviewlayer)
        quadView.translatesAutoresizingMaskIntoConstraints = false
        quadView.editable = false
        
        view.addSubview(quadView)
        view.addSubview(autoFlashButton)
        view.addSubview(autoCaptureButton)
        view.addSubview(autoCaptureAlertLabel)
        view.addSubview(promptView)
        view.addSubview(previewImageView)
        view.addSubview(deleteShadowView)
        view.addSubview(photoCollectionView)
        view.addSubview(shutterButton)
        
        updateAutoCaptureAlertLabel(on: true)
    }
    private func setupConstraints() {
        shutterButton.translatesAutoresizingMaskIntoConstraints = false
        if isFromEdit {
            photoCollectionView.isHidden = true
            NSLayoutConstraint.activate([shutterButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -24),
                                         shutterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                                         shutterButton.widthAnchor.constraint(equalToConstant: 60.0),
                                         shutterButton.heightAnchor.constraint(equalToConstant: 60.0)])
        } else {
            NSLayoutConstraint.activate([shutterButton.bottomAnchor.constraint(equalTo: photoCollectionView.topAnchor, constant: 64 - 24),
                                         shutterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                                         shutterButton.widthAnchor.constraint(equalToConstant: 60.0),
                                         shutterButton.heightAnchor.constraint(equalToConstant: 60.0)])
        }
        
        promptView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([promptView.heightAnchor.constraint(equalToConstant: 30),
                                     promptView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 70),
                                     promptView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -70),
                                     promptView.bottomAnchor.constraint(equalTo: shutterButton.topAnchor, constant: -20)])
        
        autoFlashButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([autoFlashButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
                                     autoFlashButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20.0)])
        
        autoCaptureButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([autoCaptureButton.topAnchor.constraint(equalTo: autoFlashButton.topAnchor, constant: 0),
                                     autoCaptureButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20)])
        
        autoCaptureAlertLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([autoCaptureAlertLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                                     autoCaptureAlertLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
                                     autoCaptureAlertLabel.widthAnchor.constraint(equalToConstant: 130),
                                     autoCaptureAlertLabel.heightAnchor.constraint(equalToConstant: 22)])
        
        deleteShadowView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([deleteShadowView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
                                     deleteShadowView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0),
                                     deleteShadowView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0),
                                     deleteShadowView.bottomAnchor.constraint(equalTo: photoCollectionView.topAnchor, constant: 64)])
    }
    
    func updateAutoCaptureAlertLabel(on: Bool) {
        autoCaptureButton.isUserInteractionEnabled = false
        autoCaptureAlertLabel.alpha = 1.0
        autoCaptureAlertLabel.isHidden = false
        autoCaptureAlertLabel.backgroundColor = on ? globalColor : .white
        autoCaptureAlertLabel.text = on ? "Auto Shutter On" : "Auto Shutter Off"
        autoCaptureAlertLabel.textColor = on ? .white : .black
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
            UIView.animate(withDuration: 0.25, animations: {
                self.autoCaptureAlertLabel.alpha = 0.1
            }, completion: { (_) in
                self.autoCaptureAlertLabel.isHidden = true
                self.autoCaptureButton.isUserInteractionEnabled = true
            })
        }
    }
}
extension ZLScannerViewController: ZLScanRectangleDetectionDelegateProtocol {
    func startCapturingLoading(for captureSessionManager: CaptureSessionManager, currentAutoScanPassCounts: Int) {
        guard isAutoCapture else { return }
        quadView.capturingRoudedProgressView.setProgress(progress:CGFloat((currentAutoScanPassCounts - ZLScanRectangleFeaturesFunnel().startShootLoadingThreshold))/CGFloat(ZLScanRectangleFeaturesFunnel().autoScanThreshold - ZLScanRectangleFeaturesFunnel().startShootLoadingThreshold) , time: 0.0, animate: false)
    }
    
    func captureSessionManager(_ captureSessionManager: CaptureSessionManager, didFailWithError error: Error) {
        promptView.isHidden = !isAutoCapture
        quadView.capturingRoudedProgressView.setProgress(progress: 0.0, time: 0, animate: false)
    }
    
    func didStartCapturingPicture(for captureSessionManager: CaptureSessionManager) {
        promptView.isHidden = true
    }
    
    func captureSessionManager(_ captureSessionManager: CaptureSessionManager, didCapturePicture picture: UIImage, withQuad quad: ZLQuadrilateral?) {
        shutterButton.isUserInteractionEnabled = false
        promptView.isHidden = true
        
        DispatchQueue.global().async {
            let image = picture.applyingPortraitOrientation()
            var q = quad ?? ZLScannerViewController.defaultQuad(forImage: image)
            if let quad = quad {
                q = quad
            } else {
                q = ZLQuadrilateral(topLeft: CGPoint(x: 0, y: 0), topRight: CGPoint(x: image.size.width, y: 0), bottomRight: CGPoint(x: image.size.width, y: image.size.height), bottomLeft: CGPoint(x: 0, y: image.size.height))
            }
            guard let ciImage = CIImage(image: image) else { return }
            var cartesianScaledQuad = q.toCartesian(withHeight: image.size.height)
            cartesianScaledQuad.reorganize()
            
            let filteredImage = ciImage.applyingFilter("CIPerspectiveCorrection", parameters: ciImage.getFilterDict(cartesianScaledQuad))
            var uiImage: UIImage!
            if let cgImage = CIContext(options: nil).createCGImage(filteredImage, from: filteredImage.extent) {
                uiImage = UIImage(cgImage: cgImage)
            } else {
                uiImage = UIImage(ciImage: filteredImage, scale: 1.0, orientation: .up)
            }
            
            DispatchQueue.main.async {
                if self.isFromEdit {
                    if let callBack = self.captureImageCallBack {
                        guard let enhancedImage = uiImage.colorControImage() else { return }
                        let result = ZLImageScannerResults.init(originalImage: image, scannedImage: uiImage, enhancedImage: enhancedImage, doesUserPreferEnhancedImage: true, detectedRectangle: q)
                        callBack(result)
                        self.navigationController?.popViewController(animated: true)
                    }
                    return
                }
                
                if self.isTouchShutter {
                    let editVC = ZLEditScanViewController(image: image, quad: q)
                    editVC.editCompletion = { [weak self] (result) in
                        guard let enhancedImage = result.scannedImage.colorControImage() else { return }
                        self?.photoCollectionView.addPhoto(image, result.scannedImage, enhancedImage, true, result.detectedRectangle)
                    }
                    self.navigationController?.pushViewController(editVC, animated: true)
                    self.isTouchShutter = false
                    self.shutterButton.isUserInteractionEnabled = true
                    return
                }
                
                self.previewImageView.image = uiImage
                if uiImage.size.width == 0 || uiImage.size.height == 0 { return }
                self.previewImageView.frame = self.quadView.getQuardRect();
                guard let enhancedImage = uiImage.colorControImage() else { return }
                self.previewImageView.image = enhancedImage
                self.photoCollectionView.addPhoto(image, uiImage, enhancedImage, true, q)
                self.shutterButton.isUserInteractionEnabled = true
                self.previewAnimate { captureSessionManager.start() }
            }
        }
    }
    
    func captureSessionManager(_ captureSessionManager: CaptureSessionManager, didDetectQuad quad: ZLQuadrilateral?, _ imageSize: CGSize) {
        guard let quad = quad else {
            quadView.removeQuadrilateral()
            quadView.capturingRoudedProgressView.setProgress(progress: 0.0, time: 0, animate: false)
            return
        }
        promptView.isHidden = !isAutoCapture
        quadView.drawQuadrilateral(quad: getQuadrilateral(quad, imageSize: imageSize), animated: true)
    }
    
    func startShowingScanningNotice(noRectangle: Int) {
        guard isAutoCapture else { return }
        promptView.isHidden = false
        if noRectangle < 200 {
            promptView.scanningNoticeLabel.text = "Position the document in view."
        }else {
            promptView.scanningNoticeLabel.text = "Move camera closer."
        }
    }
    
    func captureSessionManager(_ captureSessionManager: CaptureSessionManager, brightValueDidChange brightValue: Double) {
        if banTriggerFlash == true { return }
        if brightValue < brightValueOpen { openFlash() }
        if brightValue > brightValueClose { closeFlash() }
    }
    
    func previewAnimate(_ complete:@escaping (()->())) {
        UIView.animate(withDuration: 0.5, animations: {
            self.previewImageView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            self.previewImageView.center = self.view.center
        }) { (_) in
            UIView.animate(withDuration: 0.5, animations: {
                self.previewImageView.transform = CGAffineTransform(scaleX: 1, y: 1)
                self.quadView.removeQuadrilateral()
            }) { (_) in
                // continue to capture
                self.previewImageView.image = nil
                if self.disappear {
                    return
                }
                ZLScanCaptureSession.current.isEditing = false
                ZLScanCaptureSession.current.isPreviewing = false
                complete()
            }
        }
    }
}

extension ZLScannerViewController{
    @objc private func captureImage(_ sender: UIButton) {
        self.isTouchShutter = true
        captureSessionManager?.capturePhoto()
    }
    
    @discardableResult func toggleTorch(toOn: Bool) -> ZLScanFlashResult {
        guard let device = AVCaptureDevice.default(for: AVMediaType.video), device.hasTorch else { return .notSuccessful }
        guard (try? device.lockForConfiguration()) != nil else { return .notSuccessful }
        device.torchMode = toOn ? .on : .off
        device.unlockForConfiguration()
        return .successful
    }
    
    private func openFlash(_ isNeedCD: Bool = true) {
        guard UIImagePickerController.isFlashAvailable(for: .rear) else { return }
        DispatchQueue.main.async {
            if self.flashEnabled == false && self.toggleTorch(toOn: true) == .successful {
                self.flashEnabled = true
                self.autoFlashButton.isSelected = true
            }
        }
        banTriggerFlash = true
        if isNeedCD {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + kOpenFlashCD) {
                self.banTriggerFlash = false
            }
        }
    }
    
    private func closeFlash() {
        guard UIImagePickerController.isFlashAvailable(for: .rear) else { return }
        DispatchQueue.main.async {
            if self.flashEnabled == true {
                self.flashEnabled = false
                self.toggleTorch(toOn: false)
                self.autoFlashButton.isSelected = false
            }
        }
    }
    
    override func backBtnClicked() {
        self.captureSessionManager?.stop()
        if isFromEdit {
            self.navigationController?.popViewController(animated: true)
        } else {
            if let _ = fromController {
                self.navigationController?.popViewController(animated: true)
            } else {
                if photoCollectionView.photoCount > 0 {
                    showAlter(title: "The image will be deleted", message: "Are you sure?", confirm: "OK", cancel: "Cancel", confirmComp: { (_) in
                        ZLPhotoModel.removeAllModel { (_) in
                            self.dismiss(animated: true, completion: nil)
                        }
                    }) { (_) in
                        ZLScanCaptureSession.current.isEditing = false
                        self.quadView.removeQuadrilateral()
                        self.captureSessionManager?.start()
                    }
                } else {
                    dismiss(animated: true, completion: nil)
                }
            }
        }
    }
}
extension ZLScannerViewController: ZLPhotoWaterFallViewProtocol {
    func itemBeginDrag(_ status: DragStatus) {
        switch status {
        case .begin(_):
            deleteShadowView.alpha = 0.1
            deleteShadowView.isHidden = false
            deleteShadowView.process = 0
            self.quadView.removeQuadrilateral()
            DispatchQueue.global().async {
                self.captureSessionManager?.stop()
            }
            
            UIView.animate(withDuration: 0.25, animations: {
                self.deleteShadowView.alpha = 1.0
                self.shutterButton.alpha = 0.1
                self.autoFlashButton.alpha = 0.1
                self.autoCaptureButton.alpha = 0.1
                self.photoCollectionView.completeButton.alpha = 0.1
            }) { (_) in
                self.shutterButton.isHidden = true
                self.autoFlashButton.isHidden = true
                self.autoCaptureButton.isHidden = true
                self.photoCollectionView.completeButtonIsHidden = true
                
                self.promptView.isHidden = true
            }
            
            break
        case .changed(_, let offSet):
            deleteShadowView.process = offSet / kDeleteShadowViewMaxBottomSpace
            break
        case .end(_):
            UIView.animate(withDuration: 0.25, animations: {
                self.deleteShadowView.alpha = 0.1
                self.shutterButton.alpha = 1.0
                self.autoFlashButton.alpha = 1.0
                self.autoCaptureButton.alpha = 1.0
                self.photoCollectionView.completeButton.alpha = 1.0
            }) { (_) in
                self.deleteShadowView.isHidden = true
                self.deleteShadowView.process = 0
                self.shutterButton.isHidden = false
                self.autoFlashButton.isHidden = false
                self.autoCaptureButton.isHidden = false
                self.photoCollectionView.completeButtonIsHidden = false
                
                ZLScanCaptureSession.current.isEditing = false
                self.quadView.removeQuadrilateral()
                self.captureSessionManager?.start()
            }
            break
        }
    }
    
    @objc func flashActionToggle(_ button: UIButton) {
        if !button.isSelected { openFlash(false) } else { closeFlash() }
    }
    
    @objc func autoCaptureAction(_ button: UIButton) {
        button.isSelected = !button.isSelected
        if button.isSelected {
            isAutoCapture = false
            updateAutoCaptureAlertLabel(on: false)
        } else {
            isAutoCapture = true
            updateAutoCaptureAlertLabel(on: true)
        }
    }
    
    func selectedItem(_ models: [ZLPhotoModel], index: Int) {
        if let from = fromController as? ZLPhotoEditorController {
            from.scrollToIndex(index: index)
            navigationController?.popViewController(animated: true)
            return
        }
        let vc = ZLPhotoEditorController.init(nibName: "ZLPhotoEditorController", bundle: Bundle(for: self.classForCoder))
        vc.photoModels = models
        vc.currentIndex = IndexPath(item: index, section: 0)
        vc.updataCallBack = {
            self.photoCollectionView.getData()
        }
        vc.dismissCallBack = { (pdfPath) in
            if let callBack = self.dismissWithPDFPath { callBack(pdfPath) }
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func doneAction() {
        dismiss(animated: true, completion: nil)
    }
}
//MARK: GET Quadrilateral
extension ZLScannerViewController { 
    private static func defaultQuad(forImage image: UIImage) -> ZLQuadrilateral {
        let topLeft = CGPoint(x: image.size.width / 3.0, y: image.size.height / 3.0)
        let topRight = CGPoint(x: 2.0 * image.size.width / 3.0, y: image.size.height / 3.0)
        let bottomRight = CGPoint(x: 2.0 * image.size.width / 3.0, y: 2.0 * image.size.height / 3.0)
        let bottomLeft = CGPoint(x: image.size.width / 3.0, y: 2.0 * image.size.height / 3.0)
        let quad = ZLQuadrilateral(topLeft: topLeft, topRight: topRight, bottomRight: bottomRight, bottomLeft: bottomLeft)
        return quad
    }
    private func getQuadrilateral(_ quard: ZLQuadrilateral, imageSize: CGSize) -> ZLQuadrilateral{
        let portraitImageSize = CGSize(width: imageSize.height, height: imageSize.width)
        let scaleTransform = CGAffineTransform.scaleTransform(forSize: portraitImageSize, aspectFillInSize: quadView.bounds.size)
        let scaledImageSize = imageSize.applying(scaleTransform)
        let rotationTransform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2.0))
        let imageBounds = CGRect(origin: .zero, size: scaledImageSize).applying(rotationTransform)
        let translationTransform = CGAffineTransform.translateTransform(fromCenterOfRect: imageBounds, toCenterOfRect: quadView.bounds)
        let transforms = [scaleTransform, rotationTransform, translationTransform]
        let transformedQuad = quard.applyTransforms(transforms)
        return transformedQuad
    }
}

fileprivate extension ZLScannerViewController {
    class DeleteShadowView : UIView {
        var process: CGFloat = 0 {
            didSet {
                deleteImageView.alpha = process
                if process >= 1.0 {
                    let imageN = UIImage(named: "zl_deletebluebig", in: Bundle(for: ZLScannerViewController.self), compatibleWith: nil)
                    deleteImageView.image = imageN
                    lineView.backgroundColor = COLORFROMHEX(0x18ACF8)
                } else {
                    let imageN = UIImage(named: "zl_graydeletegbig", in: Bundle(for: ZLScannerViewController.self), compatibleWith: nil)
                    deleteImageView.image = imageN
                    lineView.backgroundColor = COLORFROMHEX(0x979797)
                }
            }
        }
        
        private lazy var lineView: UIView = {
            let view = UIView()
            view.backgroundColor = COLORFROMHEX(0x979797)
            return view
        }()
        
        private lazy var deleteImageView: UIImageView = {
            let view = UIImageView()
            let imageN = UIImage(named: "zl_graydeletegbig", in: Bundle(for: ZLScannerViewController.self), compatibleWith: nil)
            view.image = imageN
            return view
        }()
        
        init() {
            super.init(frame: CGRect.zero)
            backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
            addSubview(lineView)
            addSubview(deleteImageView)
            setupFrame()
        }
        
        private func setupFrame() {
            lineView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([lineView.heightAnchor.constraint(equalToConstant: 1),
                                         lineView.leftAnchor.constraint(equalTo: self.leftAnchor),
                                         lineView.rightAnchor.constraint(equalTo: self.rightAnchor),
                                         lineView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -kDeleteShadowViewMaxBottomSpace)])
            
            deleteImageView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([deleteImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 200),
                                         deleteImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
                                         deleteImageView.widthAnchor.constraint(equalToConstant: 100),
                                         deleteImageView.heightAnchor.constraint(equalToConstant: 100)])
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
