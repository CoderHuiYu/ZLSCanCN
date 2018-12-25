//
//  ZLSortCollectionViewCell.swift
//  WeScan
//
//  Created by Tyoung on 2018/12/17.
//  Copyright © 2018 WeTransfer. All rights reserved.
//

import UIKit

protocol ZLSortCollectionViewCellProtocol: NSObjectProtocol  {
    func deleteItem(_ currentCell: ZLSortCollectionViewCell)
}

class ZLSortCollectionViewCell: UICollectionViewCell {
    static let ZLSortCollectionViewCellID = "ZLSortCollectionViewCellID"
    weak var delegate: ZLSortCollectionViewCellProtocol?
    
    enum SortStyle {
        case normal
        case editing
    }
    
    lazy var iconImageView: UIImageView = {
        let iconImageView = UIImageView()
        iconImageView.contentMode = .scaleAspectFill
        iconImageView.isUserInteractionEnabled = false
        iconImageView.clipsToBounds = true
        return iconImageView
    }()
    lazy var coverView: UIView = {
        let coverView = UIView()
        coverView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6)
        coverView.isHidden = true
        return coverView
    }()
    private lazy var imaginaryLine: UIImageView = {
        let imaginaryLine = UIImageView()
        return imaginaryLine
    }()
    lazy var numberBtn: UIButton = {
        let numberBtn = UIButton()
        numberBtn.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        numberBtn.layer.cornerRadius = 20.0
        numberBtn.setTitle("2", for: .normal)
        numberBtn.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6)
        iconImageView.addSubview(numberBtn)
        return numberBtn
    }()
    var style: SortStyle = .normal {
        didSet{
            switch style {
            case .normal:
                
                break
            default:
                
                break
            }
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    private func setupView() {
        contentView.backgroundColor = UIColor.clear
        contentView.addSubview(imaginaryLine)
        contentView.addSubview(iconImageView)
        iconImageView.addSubview(coverView)
    }
    private func addImaginaryLine(_ frame: CGRect) {
        imaginaryLine.layer.sublayers?.removeAll()
        
        let border = CAShapeLayer()
        border.strokeColor = globalColor.cgColor
        border.fillColor = UIColor.clear.cgColor
        border.path = UIBezierPath(rect: CGRect(x: 1, y: 1, width: frame.size.width-2, height: frame.size.height-2)).cgPath
        border.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        border.lineWidth = 1
        border.lineCap = CAShapeLayerLineCap(rawValue: "square")
        border.lineDashPattern = [6,4]
        
        imaginaryLine.layer.addSublayer(border)
    }
    
    func imageConfig(iconImage: UIImage, style: SortStyle) {
        self.style = style
        let itemWidth = frame.width - 20
        let size = iconImage.size
        var height = itemWidth * size.height / size.width
        if height > frame.height - 20  {
            height = frame.height - 20
        }
        
        let gap = (frame.height - height)/2
        iconImageView.frame = CGRect(x: 10, y: gap, width: itemWidth, height:height)
        iconImageView.image = iconImage
        
        switch style {
        case .editing:
            imaginaryLine.frame = CGRect(x: 10, y: gap, width: itemWidth, height: height)
            addImaginaryLine(iconImageView.frame)
            numberBtn.frame = CGRect(x: itemWidth/2-20, y: height/2-20, width: 40, height: 40)
            numberBtn.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6)
            coverView.frame = iconImageView.bounds
            coverView.isHidden = true
            iconImageView.layer.borderColor = UIColor.clear.cgColor
            iconImageView.layer.borderWidth = 0
            break
        default:
            break
        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


