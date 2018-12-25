//
//  ZLSortAllpagesCollectionViewCell.swift
//  WeScan
//
//  Created by Tyoung on 2018/12/18.
//  Copyright © 2018 WeTransfer. All rights reserved.
//

import UIKit

class ZLSortAllpagesCollectionViewCell: UICollectionViewCell {
    static let ZLSortAllpagesCollectionViewCellID = "ZLSortAllpagesCollectionViewCellID"
    
    enum SortStyle {
        case normal
        case editing
    }
    
    private lazy var iconimageView: UIImageView = {
        let iconimageView = UIImageView()
        iconimageView.contentMode = .scaleAspectFill
        iconimageView.isUserInteractionEnabled = true
        iconimageView.clipsToBounds = true
        return iconimageView
    }()
    private lazy var numberBtn: UIButton = {
        let numberBtn = UIButton()
        numberBtn.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        numberBtn.layer.cornerRadius = 15.0
        numberBtn.setTitle("1", for: .normal)
        numberBtn.backgroundColor = .orange
        return numberBtn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func setupView() {
        contentView.backgroundColor = UIColor.clear
        contentView.addSubview(iconimageView)
    }
    func configImage(iconImage: UIImage, style: SortStyle){
        let itemWidth = frame.width - 20
        let size = iconImage.size
        var heigh = itemWidth * size.height / size.width
        if heigh > frame.height - 20  {
            heigh = frame.height - 20
        }
        
        let gap = (frame.height - heigh)/2
        iconimageView.frame = CGRect(x: 10, y: gap, width: itemWidth, height:heigh)
        iconimageView.image = iconImage
        
        switch style {
        case .editing:
            iconimageView.addSubview(numberBtn)
            break
        default:
            break
        }
    }
}
