//
//  UIView+CAGradientLayer.swift
//  WeScan
//
//  Created by Tyoung on 2018/12/21.
//  Copyright © 2018 WeTransfer. All rights reserved.
//

import UIKit

extension UIView {
    func getGradientColor(){
        let gradient = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = [COLORFROMHEX(0x006ea6).cgColor,COLORFROMHEX(0x18acf8).cgColor]
        gradient.locations = [0, 1]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 0)
        gradient.type = .axial
    
        let gv = UIView()
        gv.frame = self.bounds
        gv.isUserInteractionEnabled = false
        gv.layer.addSublayer(gradient)
        addSubview(gv)
        sendSubviewToBack(gv)
    }

}
