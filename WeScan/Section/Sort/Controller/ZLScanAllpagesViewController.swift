//
//  ZLScanAllpagesViewController.swift
//  WeScan
//
//  Created by Tyoung on 2018/12/18.
//  Copyright © 2018 WeTransfer. All rights reserved.
//

import UIKit

class ZLScanAllpagesViewController: ZLScannerBasicViewController, Convertable{
    var updateEditCallBack: (([ZLPhotoModel])->())?
    private var models = [ZLPhotoModel]()
    
    private lazy var sortCollectionView: UICollectionView = {
        let itemWidth = (kScreenWidth) / 3
        let itemHeight = itemWidth * 1.3
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
        layout.minimumInteritemSpacing = 0.0
        
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight), collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = RGBColor(r: 247, g: 247, b: 247)
        collectionView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        collectionView.register(ZLSortCollectionViewCell.self, forCellWithReuseIdentifier: ZLSortCollectionViewCell.ZLSortCollectionViewCellID)
        return collectionView
    }()
    
    init(_ models: [ZLPhotoModel]) {
        super.init(nibName: nil, bundle: nil)
        self.models = models
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "All Pages"
        viewConfigs()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let fromAnimation = AnimationType.from(direction: .bottom, offset: 50.0)
        sortCollectionView.reloadData()
        sortCollectionView.performBatchUpdates({
            UIView.animate(views: sortCollectionView.orderedVisibleCells,
                           animations: [fromAnimation], completion: {
            })
        }, completion: nil)
    }
    private func viewConfigs() {
        view.addSubview(sortCollectionView)
        let rightBtn = UIButton ()
        rightBtn.titleLabel?.font = basicFont
        rightBtn.setTitle("Edit", for: .normal)
        rightBtn.setTitleColor(globalColor, for: .normal)
        rightBtn.addTarget(self, action: #selector(rightBtnClick(_:)), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightBtn)
        view.addSubview(bottomView(title: "Done"))
    }
}
extension ZLScanAllpagesViewController: UICollectionViewDelegate, UICollectionViewDataSource, ZLScanSortViewControllerProtocol{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return models.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ZLSortCollectionViewCell.ZLSortCollectionViewCellID, for: indexPath) as! ZLSortCollectionViewCell
        cell.imageConfig(iconImage: models[indexPath.item].enhancedImage, style: .normal)
        return cell
    }
    func sortDidFinished(_ photoModels: [ZLPhotoModel]) {
        ZLPhotoModel.sortAllModel(photoModels) { [weak self] (isSuccess) in
            if isSuccess {
                self?.models = photoModels
                self?.sortCollectionView.reloadData()
                
                if let callBack = self?.updateEditCallBack {
                    callBack(photoModels)
                }
            }
        }
    }
}
extension ZLScanAllpagesViewController{
    override func backBtnClicked() {
        navigationController?.popViewController(animated: true)
    }
    @objc func rightBtnClick(_ sender: UIButton) {
        let sortVC = ZLScanSortViewController(models)
        sortVC.delegate = self
        navigationController?.pushViewController(sortVC, animated: true)
    }
    override func bottomBtnClicked() {
        //convertToPDF
        let  pdfpath = convertPDF(models, fileName: "temporary.pdf")
        ZLPhotoModel.removeAllModel { (isSuccess) in
            if isSuccess {
                if let callBack = self.dismissCallBack {
                    callBack(pdfpath ?? "")
                }
                navigationController?.dismiss(animated: true, completion: nil)
    
            }
        }
    }
}
