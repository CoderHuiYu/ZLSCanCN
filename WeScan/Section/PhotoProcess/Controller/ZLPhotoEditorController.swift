//
//  ZLPhotoEditorController.swift
//  WeScan
//
//  Created by apple on 2018/11/30.
//  Copyright © 2018 WeTransfer. All rights reserved.
//

import UIKit
import CoreGraphics
import Photos

private let kCollectionBottomConsValue: CGFloat = 130
class ZLPhotoEditorController: ZLScannerBasicViewController, EmitterAnimate, Convertable {
    var photoModels = [ZLPhotoModel]()
    var currentIndex: IndexPath?
    
    var pdfpath: String?
    var isNeedLoadPDF: Bool = false
    
    var updataCallBack: (()->())?
    
    @IBOutlet weak var toolBarView: UIView!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var toolBarViewPDF: UIView!
    @IBOutlet weak var keepScanButton: UIButton!
    @IBOutlet weak var doneButton1: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private lazy var rightButton: UIButton = {
        let rightBtn = UIButton ()
        rightBtn.titleLabel?.font = basicFont
        rightBtn.setTitle("All Photos", for: .normal)
        rightBtn.setTitleColor(globalColor, for: .normal)
        rightBtn.addTarget(self, action: #selector(rightButtonAction(_:)), for: .touchUpInside)
        return rightBtn
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(itemDidRemove), name: NSNotification.Name.init(kZLDeleteItemNotificationName), object: nil)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightButton)
        setupUI()
        if isNeedLoadPDF {
            loadPDF {(models) in
                self.photoModels = models
                self.collectionView.reloadData()
                self.title = "\(1)/\(models.count)"
            }
            toolBarViewPDF.isHidden = false
            toolBarView.isHidden = true
        } else {
            toolBarViewPDF.isHidden = true
            toolBarView.isHidden = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
// MARK: - UI
extension ZLPhotoEditorController {
    fileprivate func setupUI() {
        keepScanButton.layer.borderColor = COLORFROMHEX(0x787878).cgColor
        keepScanButton.layer.cornerRadius = 4
        keepScanButton.layer.borderWidth = 2
        keepScanButton.layer.masksToBounds = true
        doneButton.layer.cornerRadius = 4
        doneButton.layer.masksToBounds = true
        doneButton.getGradientColor()
        doneButton1.layer.cornerRadius = 4
        doneButton1.layer.masksToBounds = true
        doneButton1.getGradientColor()
        
        view.backgroundColor = UIColor.white
        if let currentIndex = currentIndex {
            title = "\(currentIndex.row + 1)/\(photoModels.count)"
        }
        view.clipsToBounds = true
        let layout = ZLPhotoWaterFallLayout()
        layout.isNeedScrollToMiddle = true
        layout.minimumLineSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 0, left: 40, bottom: 0, right: 40)
        layout.dataSource = self
        collectionView.register(UINib(nibName: "ZLPhotoCell", bundle: Bundle(for: type(of: self))), forCellWithReuseIdentifier: .kCollectionCellIdentifier)
        collectionView.collectionViewLayout = layout
        collectionView.decelerationRate = .fast
        
        guard let currentIndex = currentIndex else {
            return
        }
        
        if currentIndex.row > 0 {
            collectionView.layoutIfNeeded()
            collectionView.scrollToItem(at: currentIndex, at: UICollectionView.ScrollPosition.centeredHorizontally, animated: true)
        }
    }
    
    func scrollToIndex(index: Int) {
        currentIndex = IndexPath(item: index, section: 0)
        if index > 0 {
            collectionView.layoutIfNeeded()
            collectionView.scrollToItem(at: currentIndex!, at: UICollectionView.ScrollPosition.centeredHorizontally, animated: true)
        }
    }
    
    @objc fileprivate func itemDidRemove(_ notification: Notification) {
        guard let index = notification.object as? Int else {
            return
        }
        photoModels.remove(at: index)
        collectionView.reloadData()
        collectionView.layoutIfNeeded()
        updateTitle()
        
        if let callBack = self.updataCallBack {
            callBack()
        }
    }
}

// MARK: - DataSource And Delegate
extension ZLPhotoEditorController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: .kCollectionCellIdentifier, for: indexPath) as! ZLPhotoCell
        cell.cellType = .edit
        cell.photoModel = photoModels[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) else { return }
        let center = collectionView.convert(cell.center, to: view)
        if center.x == view.center.x {
            currentIndex = indexPath
            let model = photoModels[indexPath.row]
            let vc = ZLPhotoEditingController.init(nibName: "ZLPhotoEditingController", bundle: Bundle(for: self.classForCoder))
            vc.model = model
            vc.index = indexPath.row
            vc.saveModelCallBack = { [weak self] (model) in
                self?.replaceModel(model)
            }
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offSet = scrollView.contentOffset.x
        let itemWidth = (collectionView.bounds.width - 80 + 10)
        let index = Int((offSet + itemWidth * 0.5) / itemWidth)
        title = "\(index + 1)/\(photoModels.count)"
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updateTitle()
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        updateTitle()
    }
    
    fileprivate func updateTitle() {
        let cells = collectionView.visibleCells
        let centerCells = cells.filter({
            let cellCenter = collectionView.convert($0.center, to: view)
            return cellCenter.x == view.center.x
        })
        
        guard let centerCell = centerCells.first else { return }
        guard let indexPath = collectionView.indexPath(for: centerCell) else { return }
        title = "\(indexPath.row + 1)/\(photoModels.count)"
    }
}
// MARK: - Event
extension ZLPhotoEditorController {
    @IBAction func doneAction(_ sender: Any) {
        // completion
        print("completion")
    }
    
    @IBAction func keepScanAction(_ sender: Any) {
        let vc = ZLScannerViewController()
        vc.fromController = self
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // nav leftbutton action
    override func backBtnClicked() {
        if isNeedLoadPDF {
            showAlter(title: "The image will be deleted", message: "Are you sure?", confirm: "OK", cancel: "Cancel", confirmComp: { (_) in
                ZLPhotoModel.removeAllModel { [weak self] (_) in
                    guard let self = self else { return }
                    self.navigationController?.popViewController(animated: true)
                }
            }) { (_) in }
        }else{
            navigationController?.popViewController(animated: true)
        }
    }
    
    // nav rightbutton action
    @objc fileprivate func rightButtonAction(_ sender: Any) {
        let allPagesVC = ZLScanAllpagesViewController(photoModels)
        allPagesVC.updateEditCallBack = { [weak self] photoModels in
            guard let strongSelf = self else { return }
            strongSelf.photoModels = photoModels
            strongSelf.collectionView.reloadData()
        }
        navigationController?.pushViewController(allPagesVC, animated: true)
    }
    
    func saveToPhotoLibrary(_ sender: Any) {
        let selectedModels = photoModels.filter({return $0.isSelected == true})
        selectedModels.forEach { (model) in
            let image = UIImage.init(contentsOfFile: kZLScanPhotoFileDataPath + "/\(model.enhancedImagePath)")
            UIImageWriteToSavedPhotosAlbum(image!, self, #selector(image(image:didFinishSavingWithError:contextInfo:)), nil)
        }
    }
    
    fileprivate func removeItem(_ cell: ZLPhotoCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        photoModels[indexPath.row].remove { (isSuccess) in
            if isSuccess {
                photoModels.remove(at: indexPath.row)
                collectionView.reloadData()
            }
        }
    }
}
extension ZLPhotoEditorController{
    func sendButtonAction(_ sender: Any) {
        pdfpath = convertPDF(photoModels, fileName: "temporary.pdf")
        ZLPhotoModel.removeAllModel { (isSuccess) in
            if isSuccess {
                if let callBack = self.dismissCallBack {
                    callBack(pdfpath ?? "")
                }
                if isNeedLoadPDF {
                    self.dismiss(animated: true, completion: nil)
                } else {
                    navigationController?.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    @objc func image(image:UIImage,didFinishSavingWithError error:NSError?,contextInfo:AnyObject) {
        if error != nil {
            ZLScanToast.showText("save failed!")
        }else{
            ZLScanToast.showText("save success!")
        }
    }
}

// MARK: - edit photo
extension ZLPhotoEditorController {
    fileprivate func replaceModel(_ newModel: ZLPhotoModel) {
        guard let currentIndex = currentIndex else { return }
        let oldModel = photoModels[currentIndex.row]
        oldModel.replace(newModel.originalImage, newModel.scannedImage, newModel.enhancedImage, newModel.isEnhanced, newModel.detectedRectangle) { [weak self] (isSuccess, model) in
            if isSuccess {
                guard let model = model else { return }
                guard let weakSelf = self else { return }
                weakSelf.photoModels[currentIndex.row] = model
                weakSelf.collectionView.reloadData()
                
                if let callBack = weakSelf.updataCallBack {
                    callBack()
                }
                weakSelf.collectionView.layoutIfNeeded()
            }
        }
    }
}

extension ZLPhotoEditorController: ZLScanSortViewControllerProtocol {
    func sortDidFinished(_ photoModels: [ZLPhotoModel]) {
        ZLPhotoModel.sortAllModel(photoModels) { [weak self] (isSuccess) in
            if isSuccess {
                self?.photoModels = photoModels
                self?.collectionView.reloadData()
                
                if let callBack = self?.updataCallBack {
                    callBack()
                }
            }
        }
    }
}

extension ZLPhotoEditorController: ZLPhotoWaterFallLayoutDataSource {
    func waterFallLayout(_ layout: ZLPhotoWaterFallLayout, indexPath: IndexPath) -> CGSize {
        let model = photoModels[indexPath.row]
        let itemWidth = collectionView.bounds.size.width - 80
        let itemHeight = getItemHeight(model.imageSize, itemWidth)
        let maxHeight = collectionView.bounds.size.height
        return CGSize(width: itemWidth, height: itemHeight > maxHeight ? maxHeight : itemHeight)
    }
    fileprivate func getItemHeight(_ imageSize: CGSize, _ itemWidth: CGFloat) -> CGFloat {
        if imageSize.width <= 0 {
            return 0
        }
        return imageSize.height * itemWidth / imageSize.width
    }
}


fileprivate extension String {
    static let kCollectionCellIdentifier = "kCollectionCellIdentifier"
}
