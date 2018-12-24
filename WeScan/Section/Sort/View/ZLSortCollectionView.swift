//
//  SortCollectionView.swift
//  WeScan
//
//  Created by Tyoung on 2018/11/29.
//  Copyright © 2018 WeTransfer. All rights reserved.
//

import UIKit

class ZLSortCollectionView: UICollectionView{

    var photoModels = [ZLPhotoModel]()
    var deleteModels = [ZLPhotoModel]()

    private var cell: ZLSortCollectionViewCell?
    private var dragingIndexPath: IndexPath?
    private var targetIndexPath: IndexPath?
    private var playTimer: Timer?
    
    private var moveOffsetY: CGFloat = 0.0
    private var topGap: CGFloat = 20.0
    private var transY: CGFloat = 10.0
    private var selectedCount: Int = 0
    
    private lazy var dragCell : UIImageView = {
        let dragCell = UIImageView()
        dragCell.isHidden = true
        dragCell.contentMode = .scaleAspectFill
        dragCell.backgroundColor = UIColor.clear
        dragCell.layer.shadowColor = UIColor.black.cgColor
        dragCell.layer.shadowRadius = 7
        dragCell.layer.shadowOpacity = 0.3
        return dragCell
    }()
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        
        backgroundColor = COLORFROMHEX(0xf7f7f7)
        showsHorizontalScrollIndicator = false
        register(ZLSortCollectionViewCell.self, forCellWithReuseIdentifier: ZLSortCollectionViewCell.ZLSortCollectionViewCellID)
        delegate = self
        dataSource = self
        addSubview(dragCell)
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressMethod(_:)))
        longPress.delegate = self
        longPress.minimumPressDuration = 0.3
        addGestureRecognizer(longPress)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
//MARK: UIGestureRecognizerDelegate
extension ZLSortCollectionView : UIGestureRecognizerDelegate{
    @objc private func longPressMethod(_ press: UILongPressGestureRecognizer){
        let point = press.location(in: self)
        switch press.state {
        case .began :
            dragBegin(point)
        case .changed :
            dragChange(point)
        case .ended :
            dragEnd(point)
        default:
            print("")
        }
    }
    private func dragBegin(_ point: CGPoint){
        guard let indexPath = self.indexPathForItem(at: point) else {return}
        dragingIndexPath = indexPath
        targetIndexPath  = indexPath
        NotificationCenter.default.post(name: NSNotification.Name(rawValue:"ZLScanBeginDrag"), object: nil)
        let cell = self.cellForItem(at: dragingIndexPath! ) as! ZLSortCollectionViewCell
        cell.iconimageView.isHidden = true
        dragCell.frame = cell.iconimageView.frame
        dragCell.isHidden = false
        dragCell.center = point
        dragCell.image = photoModels[(dragingIndexPath?.row)!].enhancedImage
        dragCell.transform = CGAffineTransform.identity
        playTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(countPressTime), userInfo: nil, repeats: true)
    }
    private func dragChange(_ point: CGPoint){
        if dragingIndexPath == nil {return}
        dragCell.center = point
        let indexPath = self.indexPathForItem(at: point)
        if indexPath != nil { self.targetIndexPath = indexPath }
        
        if point.y <=  self.contentOffset.y + topGap {
            moveOffsetY = self.contentOffset.y - transY
            if moveOffsetY < -topGap {
                moveOffsetY = -topGap
            }
            UIView.animate(withDuration: 0.3) {
                self.contentOffset = CGPoint(x: self.contentOffset.x, y: self.moveOffsetY)
            }
        }
        if point.y - self.contentOffset.y + topGap > kScreenHeight - kNavHeight {
            moveOffsetY = self.contentOffset.y + transY
            UIView.animate(withDuration: 0.3) {
                if self.moveOffsetY > self.contentSize.height - kScreenHeight - kNavHeight{
                    self.moveOffsetY = self.contentSize.height - kScreenHeight + kNavHeight
                }
                self.contentOffset = CGPoint(x: self.contentOffset.x, y:self.moveOffsetY)
            }
        }
        if dragingIndexPath != nil && targetIndexPath != nil{
            rankImageMutableArr()
            self.moveItem(at: dragingIndexPath!, to: targetIndexPath!)
            //update cell's title text
            let currentCell = self.cellForItem(at: dragingIndexPath!) as! ZLSortCollectionViewCell
            let targetCell = self.cellForItem(at: targetIndexPath!) as! ZLSortCollectionViewCell
            let dif = targetIndexPath!.row - dragingIndexPath!.row
            if  dif >= 2{
                let midCell1 = self.cellForItem(at: IndexPath.init(row: (dragingIndexPath?.row)! + 1, section: (dragingIndexPath?.section)!)) as! ZLSortCollectionViewCell
                midCell1.numberBtn.setTitle(String((dragingIndexPath?.item)! + 2), for: .normal)
                let midCell2 = self.cellForItem(at: IndexPath.init(row: dragingIndexPath!.row + 2, section: self.dragingIndexPath!.section)) as! ZLSortCollectionViewCell
                midCell2.numberBtn.setTitle(String(dragingIndexPath!.item + 3), for: .normal)
            }
            if dif <= -2{
                let midCell1 = self.cellForItem(at: IndexPath.init(row: (targetIndexPath?.row)! + 1, section: (targetIndexPath?.section)!)) as! ZLSortCollectionViewCell
                midCell1.numberBtn.setTitle(String((targetIndexPath?.item)! + 2), for: .normal)
                let midCell2 = self.cellForItem(at: IndexPath.init(row: targetIndexPath!.row + 2, section: self.targetIndexPath!.section)) as! ZLSortCollectionViewCell
                midCell2.numberBtn.setTitle(String(targetIndexPath!.item + 3), for: .normal)
            }
            currentCell.numberBtn.setTitle(String(dragingIndexPath!.item + 1), for: .normal)
            targetCell.numberBtn.setTitle(String(targetIndexPath!.item + 1), for: .normal)
            dragingIndexPath = targetIndexPath
        }
    }
    private func dragEnd(_ point: CGPoint){
        guard let _ = dragingIndexPath else { return }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue:"ZLScanEndDrag"), object: nil)
        
        let cell = self.cellForItem(at: self.dragingIndexPath! as IndexPath) as! ZLSortCollectionViewCell
        dragCell.transform = CGAffineTransform.identity
        
        UIView.animate(withDuration: 0.3, animations: {
            self.dragCell.frame = CGRect(x: cell.frame.origin.x + 20, y: cell.frame.origin.y + cell.iconimageView.frame.origin.y, width: cell.iconimageView.frame.width, height: cell.iconimageView.frame.height)
        }) { (finished) in
            self.dragCell.isHidden = true
            cell.iconimageView.isHidden = false
            
        }
        cancelPress()
    }
    private func rankImageMutableArr(){
        //update Models
        let cell = photoModels[(dragingIndexPath?.row)!]
        photoModels.remove(at: (dragingIndexPath?.row)!)
        photoModels.insert(cell, at: (targetIndexPath?.row)!)
    }
    @objc private func countPressTime(){
        // dragging animate
        UIView.animate(withDuration: 0.7, animations: {
            self.dragCell.transform = CGAffineTransform(scaleX: 1.03, y: 1.03)
        }) { (isFinished) in
            UIView.animate(withDuration: 0.7, animations: {
                self.dragCell.transform = CGAffineTransform.identity
            }, completion: nil)
        }
    }
    // removeTimer
    private func cancelPress(){
        if (playTimer != nil) {
            playTimer?.invalidate()
            playTimer = nil
        }
    }
}
//MARK: CollectionViewDelegate
extension ZLSortCollectionView: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoModels.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ZLSortCollectionViewCell.ZLSortCollectionViewCellID, for: indexPath) as! ZLSortCollectionViewCell
        cell.configImage(iconImage: photoModels[indexPath.item].enhancedImage, style: .editing)
        cell.numberBtn.setTitle(String(indexPath.item + 1), for: .normal)
        cell.delegate = self
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! ZLSortCollectionViewCell
        var model = photoModels[indexPath.item]
        model.isSelected = !model.isSelected
        if model.isSelected {
            cell.numberBtn.backgroundColor = globalColor
            deleteModels.append(model)
            cell.coverView.isHidden = false
            cell.iconimageView.layer.borderColor = globalColor.cgColor
            cell.iconimageView.layer.borderWidth = 2
            selectedCount += 1
            NotificationCenter.default.post(name: NSNotification.Name(rawValue:"ZLScanDeleteItem"), object: selectedCount)

        }else{
            cell.numberBtn.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6)
            deleteModels = deleteModels.filter({$0.originalImagePath != model.originalImagePath})
            cell.coverView.isHidden = true
            cell.iconimageView.layer.borderColor = UIColor.clear.cgColor
            cell.iconimageView.layer.borderWidth = 0
            selectedCount -= 1
            NotificationCenter.default.post(name: NSNotification.Name(rawValue:"ZLScanDeleteItem"), object: selectedCount)
            
        }
        photoModels[indexPath.item] = model
    }
}
//MARK: ZLSortCollectionViewCellProtocol
extension ZLSortCollectionView: ZLSortCollectionViewCellProtocol{
    //removeImageFrom photoModels
    func deleteItem(_ currentCell: ZLSortCollectionViewCell) {
        let index = indexPath(for: currentCell)
        photoModels.remove(at: (index?.item)!)
        reloadData()
    }
}
