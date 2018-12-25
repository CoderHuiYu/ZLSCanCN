//
//  ZLPhotoWaterFallView.swift
//  WaterFallCollection
//
//  Created by apple on 2018/11/29.
//  Copyright © 2018 apple. All rights reserved.
//

import UIKit


private let kToolBarViewHeight: CGFloat = 64

protocol ZLPhotoWaterFallViewProtocol: NSObjectProtocol {
    func selectedItem(_ models: [ZLPhotoModel], index: Int)
    func itemBeginDrag(_ status: DragStatus)
}
class ZLPhotoWaterFallView: UIView {
    weak var delegate: ZLPhotoWaterFallViewProtocol?
    // backColor
    var backViewColor: UIColor? {
        didSet {
            guard let color = backViewColor else {
                return
            }
            collectionView.backgroundColor = color
        }
    }
    
    var completeButtonIsHidden: Bool = false {
        didSet {
            if photoModels.count <= 0 {
                completeButton.isHidden = true
                return
            }
            completeButton.isHidden = completeButtonIsHidden
        }
    }
    
    var photoCount: Int {
        return photoModels.count
    }
    
    var collectionHeight: CGFloat {
        return collectionView.frame.size.height
    }
    
    fileprivate var photoModels = [ZLPhotoModel]()
    
    // tool bar UI
    fileprivate lazy var toolBarView: UIView = {
        let toolBarView = UIView(frame: CGRect(x: 0, y: 0, width: bounds.width, height: kToolBarViewHeight))
        toolBarView.backgroundColor = UIColor.clear
        return toolBarView
    }()
    
    lazy var completeButton: UIButton = {
        let width: CGFloat = 88
        let height: CGFloat = 32
        let completeButton = UIButton(frame: CGRect(x: kScreenWidth - width - 6, y: 0, width: width, height: height))
        completeButton.backgroundColor = UIColor.white
        completeButton.layer.cornerRadius = 4
        completeButton.layer.masksToBounds = true
        completeButton.setTitle("Done", for: .normal)
        completeButton.isHidden = true
        completeButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        completeButton.setTitleColor(UIColor.black, for: .normal)
        completeButton.addTarget(self, action: #selector(completeButtonAction), for: .touchUpInside)
        return completeButton
    }()
    
    fileprivate lazy var shadowImageView: UIImageView = {
        let shadowImageView = UIImageView(frame: CGRect(x: self.collectionView.frame.origin.x + 15, y: self.collectionView.frame.origin.y + 10, width: self.collectionView.frame.size.width - 15 * 2, height: self.collectionView.frame.size .height - 10 * 2))
        shadowImageView.image = UIImage(named: "zl_cattips", in: Bundle.init(for: self.classForCoder), compatibleWith: nil)
        shadowImageView.contentMode = .scaleAspectFit
        return shadowImageView
    }()
    
    fileprivate lazy var collectionView: UICollectionView = {
        let layout = ZLPhotoWaterFallLayout()
        layout.minimumLineSpacing = 5
        layout.scrollDirection = .horizontal
        layout.dataSource = self
        let height: CGFloat = bounds.height - kToolBarViewHeight
        let insetHeght: CGFloat = iPhoneX ? -17 : 0
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: toolBarView.frame.maxY, width: bounds.width, height: height), collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.clipsToBounds = false
        collectionView.contentInset = UIEdgeInsets(top: insetHeght, left: 0, bottom: 0, right: 0)
        collectionView.register(UINib(nibName: "ZLPhotoCell", bundle: Bundle(for: type(of: self))), forCellWithReuseIdentifier: ZLPhotoWaterFallView.kCellIdentifier)
        return collectionView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        getData()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func getData() {
        ZLPhotoModel.getAllModel(handle: { (isSuccess, models) in
            if isSuccess {
                guard let models = models else { return }
                photoModels = models
                updateCompletionButton(count: photoModels.count)
                collectionView.reloadData()
            }
        })
    }
}

// MARK: - UI
extension ZLPhotoWaterFallView {
    fileprivate func setupUI() {
        addSubview(toolBarView)
        toolBarView.addSubview(completeButton)
        addSubview(collectionView)
        addSubview(shadowImageView)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
            UIView.animate(withDuration: 0.25, animations: {
                self.shadowImageView.alpha = 0.1
            }, completion: { _ in
                self.shadowImageView.isHidden = true
            })
        }
    }
    
    fileprivate func updateCompletionButton(count: Int) {
        if count > 0 {
            completeButton.setTitle("Done (\(count))", for: .normal)
            completeButton.isHidden = false
        } else {
            completeButton.setTitle("Done", for: .normal)
            completeButton.isHidden = true
        }
    }
    
    fileprivate func scrollToBottom() {
        let contentOffset = collectionView.contentSize.width - collectionView.bounds.width
        if contentOffset > 0 {
            collectionView.setContentOffset(CGPoint(x: contentOffset, y: 0), animated: true)
        }
    }
}

// MARK: - DataSouce And Delegate
extension ZLPhotoWaterFallView: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ZLPhotoWaterFallView.kCellIdentifier, for: indexPath) as! ZLPhotoCell
        cell.cellType = .normal
        cell.photoModel = photoModels[indexPath.row]
        cell.itemDidRemove = { [weak self] (item) in
            self?.removeItem(item)
        }
        cell.itemBeginDrag = { [weak self] status in
            self?.delegate?.itemBeginDrag(status)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if photoModels.count == 0 {
            ZLScanToast.showText("NO Image!!!")
        }
        if photoModels.count > 0 {
            guard let delegate = delegate else { return }
            delegate.selectedItem(photoModels, index: indexPath.row)
        }
    }
}


// MARK: - Layout
extension ZLPhotoWaterFallView: ZLPhotoWaterFallLayoutDataSource {
    func waterFallLayout(_ layout: ZLPhotoWaterFallLayout, indexPath: IndexPath) -> CGSize {
        let model = photoModels[indexPath.row]
        return CGSize(width: getItemWidth(model.imageSize), height: collectionView.bounds.height - (iPhoneX ? 34 : 0))
    }
    
    fileprivate func getItemWidth(_ imageSize: CGSize) -> CGFloat {
        if imageSize.height == 0 {
            return 0
        }
        return imageSize.width * collectionView.bounds.height / imageSize.height
    }
}

// MARK: - Data Operation
extension ZLPhotoWaterFallView {
    func addPhoto(_ originalImage: UIImage, _ scannedImage: UIImage, _ enhancedImage: UIImage, _ isEnhanced: Bool, _ detectedRectangle: ZLQuadrilateral) {
        ZLPhotoManager.saveImage(originalImage, scannedImage, enhancedImage) { (oriPath, scanPath, enhanPath) in
            if let oritempPath = oriPath, let scantempPath = scanPath, let enhantempPath = enhanPath  {
                let photoModel = ZLPhotoModel.init(oritempPath, scantempPath, enhantempPath, isEnhanced, ZLPhotoManager.getRectDict(detectedRectangle))
                photoModel.save(handle: { [weak self] (isSuccess) in
                    if isSuccess {
                        guard let weakSelf = self else { return }
                        weakSelf.photoModels.append(photoModel)
                        weakSelf.updateCompletionButton(count: weakSelf.photoModels.count)
                        weakSelf.collectionView.reloadData()
                        weakSelf.collectionView.layoutIfNeeded()
                        // scroll to bottom
                        weakSelf.scrollToBottom()
                    }
                })
            }
        }
    }
    
    fileprivate func removeItem(_ cell: ZLPhotoCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        photoModels[indexPath.row].remove { (isSuccess) in
            if isSuccess {
                photoModels.remove(at: indexPath.row)
                updateCompletionButton(count: photoModels.count)
                collectionView.reloadData()
            }
        }
    }
}


// MARK: - Event
extension ZLPhotoWaterFallView {
    // ccompletion
    @objc fileprivate func completeButtonAction() {
        delegate?.selectedItem(photoModels, index: 0)
    }
}

class ZLCustomButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        self.titleLabel?.textAlignment = .center
    }
    
    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder)
        self.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        self.titleLabel?.textAlignment = .center
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let imageView = self.imageView, let titleLabel = self.titleLabel else {
            return
        }
        self.imageView?.frame = CGRect(x: (frame.size.width - imageView.frame.size.width) * 0.5, y: 20, width: imageView.frame.size.width, height: imageView.frame.size.height)
        self.titleLabel?.frame = CGRect(x: 0, y: frame.size.height - titleLabel.frame.size.height - 20, width: frame.size.width, height: titleLabel.frame.size.height)
    }
}

extension ZLPhotoWaterFallView {
    static let kCellIdentifier = "ZLPhotoCellIdentifier"
}
