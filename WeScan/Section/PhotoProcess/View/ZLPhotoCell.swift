//
//  ZLPhotoCell.swift
//  WaterFallCollection
//
//  Created by apple on 2018/11/29.
//  Copyright © 2018 apple. All rights reserved.
//

import UIKit

private let kPhotoCellAnimateDuration: TimeInterval = 0.3

enum ZLPhotoCellType {
    case normal
    case edit
}

enum DragStatus {
    case begin(_ cell: ZLPhotoCell)
    case changed(_ cell: ZLPhotoCell, _ offset: CGFloat)
    case end(_ cell: ZLPhotoCell)
}

class ZLPhotoCell: UICollectionViewCell {
    var itemDidRemove:((_ cell: ZLPhotoCell)->())?
    var itemBeginDrag:((_ status: DragStatus)->())?
    
    var photoModel: ZLPhotoModel? {
        didSet {
            guard let model = photoModel else { return }
            imageView.image = model.enhancedImage
            updateToOriginalLayout(false)
        }
    }
    
    var cellType: ZLPhotoCellType = .normal {
        didSet {
            switch cellType {
            case .edit:
                editImageView.isHidden = false
                panGesture.isEnabled = false
                break
            case .normal:
                editImageView.isHidden = true
                panGesture.isEnabled = true
                break
            }
        }
    }
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var editImageView: UIImageView!
    @IBOutlet weak var imageViewBottomCons: NSLayoutConstraint!
    
    fileprivate lazy var panGesture: UIPanGestureRecognizer = {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureAction(_:)))
        panGesture.delegate = self
        return panGesture
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        updateToOriginalLayout(false)
        // add panGesture
        addGestureRecognizer(panGesture)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}

// MARK: - Gesture
extension ZLPhotoCell: UIGestureRecognizerDelegate {
    @objc fileprivate func panGestureAction(_ ges: UIPanGestureRecognizer) {
        // drag begin
        if ges.state == .began {
            if let dragCallBack = itemBeginDrag {
                dragCallBack(.begin(self))
            }
        }
        // drag changed
        let offSetPoint = ges.translation(in: self)
        if offSetPoint.y > 0 {
            updateToOriginalLayout(false,true)
            return
        }
        updateLayout(-offSetPoint.y)
        if let dragCallBack = itemBeginDrag {
            dragCallBack(.changed(self, -offSetPoint.y))
        }
        // drag end
        if ges.state == .ended {
            if -offSetPoint.y > kDeleteShadowViewMaxBottomSpace {
                removeItem()
            } else {
                updateToOriginalLayout(true,true)
            }
        }
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let pan = gestureRecognizer as? UIPanGestureRecognizer else { return false }
        let offSetPoint = pan.translation(in: self)
        if (offSetPoint.x != 0 && offSetPoint.y != 0) || offSetPoint.y == 0 || offSetPoint.y > 0 {
            return false
        } else {
            return true
        }
    }
}

// MARK: - updateUI
extension ZLPhotoCell {
    fileprivate func updateLayout(_ offSet: CGFloat) {
        imageViewBottomCons.constant = offSet
    }
    
    fileprivate func updateToOriginalLayout(_ animated: Bool,_ isNeedCallBack: Bool = false) {
        if animated {
            imageViewBottomCons.constant = 0
            UIView.animate(withDuration: kPhotoCellAnimateDuration, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 10, options: .curveEaseOut, animations: {
                self.layoutIfNeeded()
            }, completion: { _ in
                if isNeedCallBack {
                    if let dragCallBack = self.itemBeginDrag {
                        dragCallBack(.end(self))
                    }
                }
            })
        } else {
            imageViewBottomCons.constant = 0
            if isNeedCallBack {
                if let dragCallBack = itemBeginDrag {
                    dragCallBack(.end(self))
                }
            }
        }
    }
    
    fileprivate func removeItem() {
        imageViewBottomCons.constant = UIScreen.main.bounds.size.height
        UIView.animate(withDuration: kPhotoCellAnimateDuration - 0.15, animations: {
            self.layoutIfNeeded()
        }) { (_) in
            // remove item call back
            if let removeCallBack = self.itemDidRemove, let dragCallBack = self.itemBeginDrag {
                removeCallBack(self)
                dragCallBack(.end(self))
            }
        }
    }
}
