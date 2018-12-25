//
//  ZLScanningPromptView.swift
//  WeScan
//
//  Created by Tyoung on 2018/12/17.
//  Copyright © 2018 WeTransfer. All rights reserved.
//

import UIKit

class ZLScanningPromptView: UIView {

    lazy var scanningNoticeLabel: UILabel = {
        let scanningNoticeLabel = UILabel()
        scanningNoticeLabel.font = UIFont.systemFont(ofSize: 16)
        scanningNoticeLabel.textColor = UIColor.white
        scanningNoticeLabel.textAlignment = .center
        scanningNoticeLabel.sizeToFit()
        return scanningNoticeLabel
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(white: 0.4, alpha: 0.5)
        layer.cornerRadius = 15
        addSubview(scanningNoticeLabel)
        scanningNoticeLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([scanningNoticeLabel.topAnchor.constraint(equalTo: topAnchor),
                                     scanningNoticeLabel.leftAnchor.constraint(equalTo: leftAnchor),
                                     scanningNoticeLabel.rightAnchor.constraint(equalTo: rightAnchor),
                                     scanningNoticeLabel.bottomAnchor.constraint(equalTo: bottomAnchor)])
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
