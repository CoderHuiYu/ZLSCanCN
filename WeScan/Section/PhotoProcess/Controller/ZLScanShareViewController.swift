//
//  ZLScanShareViewController.swift
//  WeScan
//
//  Created by Tyoung on 2018/12/20.
//  Copyright © 2018 WeTransfer. All rights reserved.
//

import UIKit

extension UIAlertController {
    
    func addScanShareViewController() {
        let shareVC = ZLScanShareViewController()
        set(vc: shareVC, height: 120)
    }
}

class ZLScanShareViewController: UIViewController {
    private lazy var collectionView: UICollectionView = {
        let itemWidth = 90
        let itemHeith = 90
        let layout = ZLScanShareFlowLayout()
        layout.itemSize = CGSize(width: itemWidth, height: itemHeith )
//        layout.minimumLineSpacing = 7.5
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width:view.frame.size.width, height: 120), collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.bounces = false
        collectionView.backgroundColor = COLORFROMHEX(0xd8d8d8)
        collectionView.contentInset = UIEdgeInsets(top: 15, left: 15, bottom: 0, right: 0)
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cellID")
        return collectionView
    }()
    init() {
        super.init(nibName: nil, bundle: nil)
        preferredContentSize.height = 120
        view.addSubview(collectionView)

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
extension ZLScanShareViewController: UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellID", for: indexPath)
        cell.backgroundColor = .orange
        return cell
    }
}
