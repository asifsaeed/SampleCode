//
//  PreferencesCell.swift
//  Reperio
//
//  Created by Asif Saeed on 4/17/18.
//  Copyright © 2018 True DVLPMNT. All rights reserved.
//

import UIKit
import Foundation
import TinyConstraints

class PreferenceCell: UICollectionViewCell {
  
  var cellIsSelected = false
  
  lazy var preferenceImage: UIImageView = {
    let img = UIImageView()
    img.clipsToBounds = true
    img.contentMode = .scaleToFill
    img.layer.cornerRadius = 8
    img.layer.shadowOffset = CGSize(width: 0, height: 0)
    img.layer.shadowRadius = 10
    img.layer.shadowColor = UIColor.black.cgColor
    img.layer.shadowOpacity = 0.2
    img.alpha = 0.5
    return img
  }()
  
  let preferenceLabel: UILabel = {
    let lbl = UILabel()
    lbl.font = UIFont.init(name: "Montserrat-Medium", size: 15)!
    lbl.textColor = UIColor.white
    lbl.textAlignment = .center
    lbl.layer.shadowOffset = CGSize(width: 0, height: 0)
    lbl.layer.shadowRadius = 2.5
    lbl.layer.shadowColor = UIColor.black.cgColor
    lbl.layer.shadowOpacity = 1.0
    return lbl
  }()
  
  func unselect() {
    cellIsSelected = false
    preferenceImage.alpha = 0.5
    preferenceImage.layer.borderColor = UIColor.clear.cgColor
  }
  
  func select() {
    cellIsSelected = true
    preferenceImage.alpha = 1
    preferenceImage.layer.borderColor = UIColor.white.cgColor
    preferenceImage.layer.borderWidth = 2.0
  }
  
  func updateView(labelText: String, image: UIImage) {
    
    self.contentView.layer.cornerRadius = 8
    self.contentView.backgroundColor = .white
    
    let height = self.contentView.frame.height
    let width = self.contentView.frame.width
    
    if isSelected {
      select()
    } else {
      unselect()
    }
    preferenceImage.image = image
    self.contentView.addSubview(preferenceImage)
    preferenceImage.edgesToSuperview()
    preferenceImage.centerXToSuperview()
    preferenceImage.centerYToSuperview()
    
    preferenceLabel.text = labelText
    self.contentView.addSubview(preferenceLabel)
    preferenceLabel.height(18)
    preferenceLabel.width(width)
    preferenceLabel.bottomToSuperview(offset: -(height * 0.15))
    preferenceLabel.centerXToSuperview()
    
  }
  
}

