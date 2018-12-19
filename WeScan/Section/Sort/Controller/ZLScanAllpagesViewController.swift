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
        let itemHeith = itemWidth * 1.3
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: itemWidth, height: itemHeith )
        layout.minimumInteritemSpacing = 0.0
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight), collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = COLORFROMHEX(0xd8d8d8)
        collectionView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        collectionView.register(ZLSortCollectionViewCell.self, forCellWithReuseIdentifier: ZLSortCollectionViewCell.ZLSortCollectionViewCellID)

        return collectionView
    }()
    
    init(_ models: [ZLPhotoModel]){
        super.init(nibName: nil, bundle: nil)
        self.models = models
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "All Pages"
        
        viewConfig()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let fromAnimation = AnimationType.from(direction: .bottom, offset: 50.0)
//        let zoomAnimation = AnimationType.zoom(scale: 0.8)
//        let rotateAnimation = AnimationType.rotate(angle: CGFloat.pi/6)

        sortCollectionView.reloadData()
        sortCollectionView.performBatchUpdates({
            UIView.animate(views: sortCollectionView.orderedVisibleCells,
                           animations: [fromAnimation], completion: {
            })
        }, completion: nil)
    }
    private func viewConfig(){
        view.addSubview(sortCollectionView)
        let rightBtn = UIButton ()
        rightBtn.setTitle("Edit", for: .normal)
        rightBtn.setTitleColor(globalColor, for: .normal)
        rightBtn.addTarget(self, action: #selector(rightBtnClick(_:)), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightBtn)
        bottomBtn.frame = CGRect(x: 0, y: kScreenHeight-100-kNavHeight, width: kScreenWidth, height: 100)
        bottomBtn.setTitle("Done", for: .normal)
        view.addSubview(bottomBtn)
    }
}
extension ZLScanAllpagesViewController: UICollectionViewDelegate, UICollectionViewDataSource, ZLScanSortViewControllerProtocol{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return models.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ZLSortCollectionViewCell.ZLSortCollectionViewCellID, for: indexPath) as! ZLSortCollectionViewCell
        cell.configImage(iconImage: models[indexPath.item].enhancedImage, style: .normal)
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
    override func backBtnClick() {
        navigationController?.popViewController(animated: true)
    }
    @objc func rightBtnClick(_ sender: UIButton){
        let sortVC = ZLScanSortViewController(models)
        sortVC.delegate = self
        navigationController?.pushViewController(sortVC, animated: true)
    }
    override func bottomBtnClick() {
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
