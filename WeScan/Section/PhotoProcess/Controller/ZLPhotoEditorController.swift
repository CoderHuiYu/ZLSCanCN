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
class ZLPhotoEditorController: ZLScannerBasicViewController,EmitterAnimate,Convertable {
    var photoModels = [ZLPhotoModel]()
    var currentIndex: IndexPath?
    
    var pdfpath: String?
    var isNeedLoadPDF: Bool = false
    
    var updataCallBack: (()->())?
    
    @IBOutlet weak var toolBarView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var toolBarViewBottomCons: NSLayoutConstraint!
    @IBOutlet weak var collectionViewBottomCons: NSLayoutConstraint!
    
    fileprivate lazy var editingView: ZLPhotoEditingView = {
        let editingView = Bundle.init(for: self.classForCoder).loadNibNamed("ZLPhotoEditingView", owner: nil, options: nil)?.first as! ZLPhotoEditingView
        editingView.frame = view.bounds
        editingView.delegate = self
        return editingView
    }()
    fileprivate lazy var addImageBtn: UIButton = {
        let addImageBtn = UIButton()
        addImageBtn.frame = CGRect(x: kScreenWidth - 34, y: kNavHeight , width: 24, height: 24)
        let image = UIImage(named: "jiahao", in: Bundle.init(for: self.classForCoder), compatibleWith: nil)
        addImageBtn.setImage(image, for: .normal)
        addImageBtn.addTarget(self, action: #selector(addImageBtnClick), for: .touchUpInside)
        addImageBtn.isHidden = true
        return addImageBtn
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupUI()
        if isNeedLoadPDF {
            addImageBtn.isHidden = false
            loadPDF {(models) in
                self.photoModels = models
                self.collectionView.reloadData()
                self.title = "\(1)/\(models.count)"
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
}
// MARK: - UI
extension ZLPhotoEditorController {
    
    fileprivate func setupUI() {
      
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
        view.addSubview(editingView)
        view.addSubview(addImageBtn)
        guard let currentIndex = currentIndex else {
            return
        }
        
        if currentIndex.row > 0 {
            collectionView.layoutIfNeeded()
            collectionView.scrollToItem(at: currentIndex, at: UICollectionView.ScrollPosition.centeredHorizontally, animated: true)
        }
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
    fileprivate func updateEditView(_ index: IndexPath, model: ZLPhotoModel) {
        
        self.photoModels[index.row] = model
        self.collectionView.reloadData()
        
        if let callBack = self.updataCallBack { callBack() }
        
        self.collectionView.layoutIfNeeded()
        guard let cell = self.collectionView.cellForItem(at: index) else { return }
        let photoCell = cell as! ZLPhotoCell
        self.editingView.update(photoCell.imageView)
        self.editingView.isEnhanced = model.isEnhanced
    }
}
// MARK: - DataSource And Delegate
extension ZLPhotoEditorController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoModels.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: .kCollectionCellIdentifier, for: indexPath) as! ZLPhotoCell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: .kCollectionCellIdentifier, for: indexPath) as! ZLPhotoCell
        cell.cellType = .edit
        cell.photoModel = photoModels[indexPath.row]
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) else { return }
        let center = collectionView.convert(cell.center, to: view)
        if center.x == view.center.x {
            let photoCell = cell as! ZLPhotoCell
            currentIndex = indexPath
            let model = photoModels[indexPath.row]
            editingView.isEnhanced = model.isEnhanced
            editingView.show(photoCell.imageView)
            let visibleCells = collectionView.visibleCells
            visibleCells.forEach { (theCell) in
                if theCell != cell {
                    theCell.isHidden = true
                } else {
                    theCell.isHidden = false
                }
            }
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
}
// MARK: - Event
extension ZLPhotoEditorController {
    // nav leftbutton action
    @IBAction fileprivate func leftButtonAction(_ sender: Any) {
        if isNeedLoadPDF {
            showAlter(title: "The image will be deleted", message: "Are you sure?", confirm: "OK", cancel: "Cancel", confirmComp: { (_) in
                ZLPhotoModel.removeAllModel { (_) in
                    self.dismiss(animated: true, completion: nil)
                }
            }) { (_) in }
        }else{
            navigationController?.popViewController(animated: true)
        }
    }
    // nav rightbutton action
    @IBAction fileprivate func rightButtonAction(_ sender: Any) {
        let allPagesVC = ZLScanAllpagesViewController(photoModels)
        allPagesVC.updateEditCallBack = { [weak self] photoModels in
            guard let strongSelf = self else { return }
            strongSelf.photoModels = photoModels
            strongSelf.collectionView.reloadData()
        }
        navigationController?.pushViewController(allPagesVC, animated: true)
    }
    
    @IBAction func saveToPhotoLibrary(_ sender: Any) {
        
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
    fileprivate func editToolBarItemAction(_ index: Int) {
        editToolBarAction(index)
    }
}
extension ZLPhotoEditorController{
    @IBAction func sendButtonAction(_ sender: Any) {
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
    @objc func addImageBtnClick(){
        let scannerViewController = ZLScannerViewController()
        scannerViewController.dismissCallBackIndex = { index in
            ZLPhotoModel.getAllModel(handle: { (isSuccess, models) in
                if isSuccess {
                    if let models = models {
                        self.photoModels = models
                        self.collectionView.reloadData()
                        self.view.layoutIfNeeded()
                        if let index = index {
                            // click item call back
                            self.title = "\(index + 1)/\(models.count)"
                            self.collectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: UICollectionView.ScrollPosition.centeredHorizontally, animated: true)
                        } else {
                            // click cancle call back
                            if let text = self.title {
                                let str = text.components(separatedBy: "/").first ?? "1"
                                self.title = "\(str)/\(models.count)"
                            } else {
                                self.title = "\(1)/\(models.count)"
                            }
                        }
                    }
                }
            })
        }
        scannerViewController.isFromEdit = true
        present(scannerViewController, animated: true, completion: nil)
    }
}
// MARK: - edit photo
extension ZLPhotoEditorController {
    fileprivate func editToolBarAction(_ index: Int) {
        guard let indexP = currentIndex else { return }
        // index
        switch index {
        case 0: // delete
            deleteModelAtIndexPath(indexPath: indexP)
            break
        case 1: // image rotate
            rotateCellAtIndexPath(indexPath: indexP)
            break
        case 2: // cut
            cutImageAtIndexPath(indexPath: indexP)
            break
        case 3: // filter
            filterImageAtIndexPath(indexPath: indexP)
            break
        default:
            break
        }
    }
    
    func deleteModelAtIndexPath(indexPath: IndexPath){
        photoModels[indexPath.row].remove { (isSuccess) in
            if isSuccess {
                photoModels.remove(at: indexPath.row)
                collectionView.reloadData()
                if let callBack = updataCallBack {
                    callBack()
                }
                editingView.hide()
            }
        }
    }
    
    func rotateCellAtIndexPath(indexPath: IndexPath){
        let lastModel = photoModels[indexPath.item]
        let originalImage = UIImage(contentsOfFile: kZLScanPhotoFileDataPath + "/\(lastModel.originalImagePath)") ?? lastModel.scannedImage
        let scannedImage = lastModel.scannedImage
        let enhancedImage = lastModel.enhancedImage
        
        let orientaiton = UIImage.Orientation.right
        
        let newOriginalImage = originalImage.rotateImage(orientaiton)
        let newScannedImage = scannedImage.rotateImage(orientaiton)
        let newEnhancedImage = enhancedImage.rotateImage(orientaiton)
        
        let newRect = lastModel.detectedRectangle.rotateRect()
        
        lastModel.replace(newOriginalImage, newScannedImage, newEnhancedImage, lastModel.isEnhanced, newRect) { [weak self] (isSuccess, model) in
            if isSuccess {
                
                guard let model = model else { return }
                guard let weakSelf = self else { return }
                
                weakSelf.photoModels[indexPath.item] = model
                weakSelf.collectionView.reloadData()
                
                if let callBack = weakSelf.updataCallBack {
                    callBack()
                }
                weakSelf.collectionView.layoutIfNeeded()
                guard let cell = weakSelf.collectionView.cellForItem(at: indexPath) else { return }
                let photoCell = cell as! ZLPhotoCell
                weakSelf.editingView.update(photoCell.imageView)
            }
        }
    }
    
    func cutImageAtIndexPath(indexPath: IndexPath){
        let lastModel = photoModels[indexPath.item]
        guard let imageToEdit =  UIImage(contentsOfFile: kZLScanPhotoFileDataPath + "/\(lastModel.originalImagePath)") else { return }
        
        let editVC = ZLEditScanViewController(image: imageToEdit.applyingPortraitOrientation(), quad: lastModel.detectedRectangle)
        editVC.editCompletion = { [weak self] (result, rect) in
            lastModel.replace(result.originalImage, result.scannedImage, result.scannedImage, lastModel.isEnhanced, rect, handle: { (isSuccess, model) in
                if isSuccess {
                    guard let model = model else { return }
                    guard let weakSelf = self else { return }
                    weakSelf.updateEditView(indexPath, model: model)
                }
            })
        }
        let navigationController = UINavigationController(rootViewController: editVC)
        present(navigationController, animated: true)
    }
    
    func filterImageAtIndexPath(indexPath: IndexPath){
        let lastModel = photoModels[indexPath.item]
        let originalImage = UIImage(contentsOfFile: kZLScanPhotoFileDataPath + "/\(lastModel.originalImagePath)") ?? lastModel.scannedImage
        let isEnhanced = lastModel.isEnhanced
        
        if isEnhanced {
            // need review - this pic don't changed
            lastModel.replace(originalImage, lastModel.scannedImage, lastModel.scannedImage, false, lastModel.detectedRectangle, handle: { (isSuccess, model) in
                if isSuccess {
                    guard let model = model else { return }
                    self.updateEditView(indexPath, model: model)
                }
                self.stopEmitter()
            })
        } else {
            let enhancedImage = lastModel.enhancedImage.colorControImage() ?? lastModel.scannedImage
            lastModel.replace(originalImage, lastModel.scannedImage, enhancedImage, true, lastModel.detectedRectangle, handle: { (isSuccess, model) in
                if isSuccess {
                    guard let model = model else { return }
                    self.updateEditView(indexPath, model: model)
                }
                self.stopEmitter()
            })
        }
    }
}
// MARK: - Protocol
extension ZLPhotoEditorController: ZLPhotoEditingViewDelegate{
    func editingViewHideBack(){
        let visibleCells = self.collectionView.visibleCells
        visibleCells.forEach { (theCell) in theCell.isHidden = false }
    }
    func toolBarItemAction(index: Int){
        editToolBarItemAction(index)
    }
}
extension ZLPhotoEditorController: ZLScanSortViewControllerProtocol{
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
