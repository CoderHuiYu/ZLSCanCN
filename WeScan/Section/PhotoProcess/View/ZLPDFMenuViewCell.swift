//
//  ZLPDFMenuViewCell.swift
//  WeScan
//
//  Created by Tyoung on 2018/12/24.
//  Copyright © 2018 WeTransfer. All rights reserved.
//

import UIKit

class ZLPDFMenuViewCell: UITableViewCell {
    static let ZlPDFMenuViewCellID = "ZLPDFMenuViewCellID"
    
    private lazy var iconImageView: UIImageView = {
        let iconImageView = UIImageView()
        iconImageView.frame = CGRect(x: 16, y: 10, width: 22, height: 22)
        iconImageView.contentMode = .scaleAspectFit
        return iconImageView
    }()
    private lazy var itemLabel: UILabel = {
        let itemLabel = UILabel()
        itemLabel.frame = CGRect(x: 54, y: 10, width: 100, height: 22)
        itemLabel.font = UIFont.systemFont(ofSize: 12)
        itemLabel.textColor = .black
        return itemLabel
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        viewConfigs()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func viewConfigs() {
        contentView.addSubview(iconImageView)
        contentView.addSubview(itemLabel)
    }
    func modelConfig(_ image: UIImage, text: String) {
        iconImageView.image = image
        itemLabel.text = text
    }
}
