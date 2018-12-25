//
//  ZLScanShareFlowLayout.swift
//  WeScan
//
//  Created by Tyoung on 2018/12/21.
//  Copyright © 2018 WeTransfer. All rights reserved.
//

import UIKit

class ZLScanShareFlowLayout: UICollectionViewFlowLayout {
    var maxInteritemSpacing : CGFloat{
        didSet{
            self.minimumInteritemSpacing = maxInteritemSpacing
        }
    }
    var sumCellWidth : CGFloat = 0.0
    
    override init() {
        self.maxInteritemSpacing = 15
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        guard let attributes = super.layoutAttributesForElements(in: rect) else {
            return nil
        }
        var attributes_t = [UICollectionViewLayoutAttributes]()
        for index in 0..<attributes.count{
            
            let currentAttr = attributes[index]
            let previousAttr = index == 0 ? nil : attributes[index-1]
            let nextAttr = index + 1 == attributes.count ?
                nil : attributes[index+1]
            
            attributes_t.append(currentAttr)
            sumCellWidth += currentAttr.frame.size.width
            
            let previousY :CGFloat = previousAttr == nil ? 0 : previousAttr!.frame.maxY
            let currentY :CGFloat = currentAttr.frame.maxY
            let nextY:CGFloat = nextAttr == nil ? 0 : nextAttr!.frame.maxY
            
            if currentY != previousY && currentY != nextY{
                self.setCellFrame(with: attributes_t)
                attributes_t.removeAll()
                sumCellWidth = 0.0
            }else if currentY != nextY{
                self.setCellFrame(with: attributes_t)
                attributes_t.removeAll()
                sumCellWidth = 0.0
            }
        }
        return attributes
    }
    func setCellFrame(with layoutAttributes : [UICollectionViewLayoutAttributes]) {
        var nowWidth : CGFloat = sectionInset.left
        for attributes in layoutAttributes{
            var nowFrame = attributes.frame
            nowFrame.origin.x = nowWidth
            attributes.frame = nowFrame
            nowWidth += nowFrame.size.width + maxInteritemSpacing
        }
    
    }
}
