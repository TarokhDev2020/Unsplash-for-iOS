//
//  FavoriteCell.swift
//  Unsplash
//
//  Created by Tarokh on 9/25/20.
//  Copyright © 2020 Tarokh. All rights reserved.
//

import UIKit
import CoreData
import Kingfisher

class FavoriteCell: UICollectionViewCell {
    
    // define some @IBOutlets
    @IBOutlet var favoriteImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    // define some functions
    func configureCell(favorite: NSManagedObject) {
        guard let url = URL(string: favorite.value(forKey: "imageURL") as! String) else {return}
        favoriteImageView.layer.cornerRadius = 5.0
        favoriteImageView.layer.masksToBounds = true
        favoriteImageView.kf.setImage(with: url)
    }
    

}
