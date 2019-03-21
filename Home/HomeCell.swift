//
//  HomeCell.swift
//  Reperio
//
//  Created by Asif Saeed on 4/26/18.
//  Copyright © 2018 True DVLPMNT. All rights reserved.
//

import UIKit
import TinyConstraints
import Cosmos
import MarqueeLabel

class HomeFeedCell: UICollectionViewCell {
  
  let cardView: UIView = {
    let cardView = UIView()
    cardView.backgroundColor = UIColor.white
    cardView.layer.cornerRadius = 10
    cardView.layer.masksToBounds = true
    return cardView
  }()
  
  let imageView: UIImageViewAligned = {
    let imageView = UIImageViewAligned()
    imageView.image = UIImage(named: "WalkPicture3")
    imageView.contentMode = .scaleAspectFill
    imageView.alignment = .center
    imageView.clipsToBounds = true
    return imageView
  }()
  
  var rating: CosmosView = {
    let rating = CosmosView()
    rating.settings.updateOnTouch = false
    rating.settings.fillMode = .precise
    rating.rating = 0
    return rating
  }()
  
  var restaurantInfoLabel: UILabel = {
    var restaurantInfoLabel = UILabel()
    restaurantInfoLabel.numberOfLines = 0
    restaurantInfoLabel.textColor = App.darkGreyFontColor
    restaurantInfoLabel.text = "Open Now • 0.3 miles from you • $$$"
    return restaurantInfoLabel
  }()
  
  var restaurantNameLabel: MarqueeLabel = {
    var restaurantNameLabel = MarqueeLabel()
    restaurantNameLabel.textColor = App.darkGreyFontColor
    restaurantNameLabel.text = "Graziano's Gourmet in Weston"
    return restaurantNameLabel
  }()
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.setupSubViews()
  }
  
  func setupSubViews() -> Void {
    let cellWidth = contentView.frame.width
    let cellHeight = contentView.frame.height
    
    contentView.backgroundColor = .clear
    contentView.layer.shadowOffset = CGSize(width: 0, height: 0)
    contentView.layer.shadowRadius = 10
    contentView.layer.shadowColor = UIColor.black.cgColor
    contentView.layer.shadowOpacity = 0.25
    
    self.contentView.addSubview(cardView)
    cardView.edges(to: contentView)
    
    cardView.addSubview(imageView)
    imageView.edges(to: cardView, insets: UIEdgeInsets(top: 0, left: 0, bottom: -(cellHeight * 0.275), right: 0))
    
    let infoFontSize = (cellHeight * 0.045).rounded()
    print(infoFontSize)
    cardView.addSubview(restaurantInfoLabel)
    restaurantInfoLabel.font = UIFont(name: "Montserrat-Italic", size: infoFontSize)
    restaurantInfoLabel.height(cellHeight * 0.055)
    restaurantInfoLabel.left(to: cardView, offset: (cellWidth * 0.0425))
    restaurantInfoLabel.width(cellWidth * 0.90)
    restaurantInfoLabel.bottom(to: cardView, offset: -(cellHeight * 0.0575))
    
    let nameFontSize = (cellHeight * 0.065).rounded()
    let restNameLabelHeight = cellHeight * 0.076
    let restNameLabelFont = UIFont(name: "Montserrat-Medium", size: nameFontSize)
    cardView.addSubview(restaurantNameLabel)
    restaurantNameLabel.font = restNameLabelFont
    restaurantNameLabel.height(restNameLabelHeight)
    restaurantNameLabel.left(to: cardView, offset: (cellWidth * 0.0425))
    restaurantNameLabel.width(cellWidth * 0.6)
    restaurantNameLabel.bottomToTop(of: restaurantInfoLabel, offset: -(cellHeight * 0.0275))
    let restNameTextWidth = restaurantNameLabel.text?.width(withConstrainedHeight: restNameLabelHeight, font: restNameLabelFont!)
    if restNameTextWidth! > (cellWidth * 0.6) {
      restaurantNameLabel.type = .continuous
      restaurantNameLabel.animationDelay = 2.0
      restaurantNameLabel.fadeLength = 10.0
      restaurantNameLabel.trailingBuffer = 20.0
    }
    
    let starRatingSize = (cellHeight * 0.065).rounded()
    cardView.addSubview(rating)
    rating.settings.starSize = Double(starRatingSize)
    rating.settings.starMargin = Double(starRatingSize * 0.1)
    rating.height(cellHeight * 0.076)
    rating.right(to: cardView, offset: -(cellWidth * 0.0425))
    rating.sizeToFit()
    rating.bottom(to: restaurantNameLabel)
  }
  
  func configure(index:Int){
    if(index > 0){
      imageView.image = UIImage(named: "WalkPicture1")
    }
  }
  
}
