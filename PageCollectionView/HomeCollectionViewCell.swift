//
//  HomeCollectionViewCell.swift
//  PageCollectionView
//
//  Created by vcredit on 2018/5/19.
//  Copyright © 2018年 vcredit. All rights reserved.
//

import UIKit

class HomeCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var label: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func config(text: String) {
        
        backgroundColor = UIColor(red: CGFloat(Double(arc4random_uniform(255)) / 255.0), green: CGFloat(Double(arc4random_uniform(255)) / 255.0), blue: CGFloat(Double(arc4random_uniform(255)) / 255.0), alpha: 1)
        
        label.text = text
    }

}
