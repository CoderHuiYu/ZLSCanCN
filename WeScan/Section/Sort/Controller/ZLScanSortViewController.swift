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
        let itemHeight = itemWidth * 1.3
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: itemWidth, height: itemHeight )
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
        NotificationCenter.default.addObserver(self, selector: #selector(changeTitle(_:)), name: NSNotification.Name(rawValue:"ZLScanDeleteItem"), object: nil)
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

    private func creatCollectionView() {
        title = "Sort"
        view.backgroundColor = .white
        
        collectionView.photoModels = models
        view.addSubview(collectionView)
        let rightBtn = UIButton ()
        rightBtn.titleLabel?.font = basicFont
        rightBtn.setTitle("Delete", for: .normal)
        rightBtn.setTitleColor(globalColor, for: .normal)
        rightBtn.addTarget(self, action: #selector(deleteBtnClicked(_:)), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightBtn)
        view.addSubview(bottomView(title: "Save"))
    }
    override func backBtnClicked() {
        navigationController?.popViewController(animated: true)
    }
    @objc func deleteBtnClicked(_ sender: UIButton) {
        if collectionView.deleteModels.count == 0 { return }
        showAlter(title: "Do you want to delete the selected pages ?", message: "", confirm: "Delete", cancel: "Cancel", confirmComp: { [weak self] (_) in
            guard let self = self else { return }
            for m in self.collectionView.deleteModels{
                self.collectionView.photoModels = self.collectionView.photoModels.filter({$0 != m})
            }
            self.collectionView.deleteModels.removeAll()
            self.collectionView.reloadData()
        }) { (_) in
            
        }
    }
    override func bottomBtnClicked() {
        if delegate != nil {
        delegate?.sortDidFinished(collectionView.photoModels)}
        navigationController?.popViewController(animated: true)
    }
    @objc func changeTitle(_ not: Notification){
        guard let selectedCount = not.object as? Int else { return }
        if selectedCount == 0 {
            title = "Sort"
        }else {
            title = "\(selectedCount) Photos Selected"
        }
    }
}

