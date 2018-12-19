//
//  ZLScanSortViewController.swift
//  WeScan
//
//  Created by Tyoung on 2018/12/17.
//  Copyright © 2018 WeTransfer. All rights reserved.
//

import UIKit

protocol ZLScanSortViewControllerProtocol: NSObjectProtocol{
    func sortDidFinished(_ photoModels: [ZLPhotoModel])
}

class ZLScanSortViewController: ZLScannerBasicViewController {
    weak var delegate: ZLScanSortViewControllerProtocol?

    private var models = [ZLPhotoModel]()
    private var collectionView: ZLSortCollectionView = {
        let itemWidth = (kScreenWidth) / 3
        let itemHeith = itemWidth * 1.3
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: itemWidth, height: itemHeith )
        layout.minimumInteritemSpacing = 0.0
        let collectionView = ZLSortCollectionView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight), collectionViewLayout: layout)
        collectionView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
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
        creatCollectionView()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let fromAnimation = AnimationType.from(direction: .right, offset: 50.0)
        
        collectionView.reloadData()
        collectionView.performBatchUpdates({
            UIView.animate(views: collectionView.orderedVisibleCells,
                           animations: [fromAnimation], completion: {
            })
        }, completion: nil)
    }

    private func creatCollectionView(){
        title = "Sort"
        view.backgroundColor = UIColor.white
        
        collectionView.photoModels = models
        view.addSubview(collectionView)
        bottomBtn.frame = CGRect(x: 0, y: kScreenHeight-100-kNavHeight, width: kScreenWidth, height: 100)
        bottomBtn.setTitle("Save", for: .normal)
        view.addSubview(bottomBtn)
        let rightBtn = UIButton ()
        rightBtn.setTitle("Delete", for: .normal)
        rightBtn.setTitleColor(globalColor, for: .normal)
        rightBtn.addTarget(self, action: #selector(deleteBtnClick(_:)), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightBtn)
    }
    override func backBtnClick() {
        navigationController?.popViewController(animated: true)
    }
    @objc func deleteBtnClick(_ sender: UIButton){
        if collectionView.deleteModels.count == 0 { return }
        showAlter(title: "", message: "Do you want to delete the selected pages ?", confirm: "Delete", cancel: "Cancel", confirmComp: { [weak self] (_) in
            guard let self = self else { return }
            for m in self.collectionView.deleteModels{
                self.collectionView.photoModels = self.collectionView.photoModels.filter({$0 != m})
            }
            self.collectionView.deleteModels.removeAll()
            self.collectionView.reloadData()
        }) { (_) in
            
        }
    }
    override func bottomBtnClick() {
        if delegate != nil {
        delegate?.sortDidFinished(collectionView.photoModels)}
        navigationController?.popViewController(animated: true)
    }
}

