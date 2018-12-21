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
    @IBOutlet weak var collectionView: UICollectionView!
    
    fileprivate lazy var rightButton: UIButton = {
        let rightBtn = UIButton ()
        rightBtn.setTitle("All Photos", for: .normal)
        rightBtn.setTitleColor(globalColor, for: .normal)
        rightBtn.addTarget(self, action: #selector(rightButtonAction(_:)), for: .touchUpInside)
        return rightBtn
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightButton)
        setupUI()
        if isNeedLoadPDF {
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
            vc.deleteModelCallBack = { [weak self] in
                self?.photoModels.remove(at: indexPath.row)
                self?.collectionView.reloadData()
            }
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
}
// MARK: - Event
extension ZLPhotoEditorController {
    // nav leftbutton action
    override func backBtnClick() {
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
