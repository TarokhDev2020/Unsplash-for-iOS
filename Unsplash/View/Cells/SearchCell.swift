//
//  SearchCell.swift
//  Unsplash
//
//  Created by Tarokh on 9/24/20.
//  Copyright © 2020 Tarokh. All rights reserved.
//

import UIKit
import Kingfisher

class SearchCell: UICollectionViewCell {
    
    // define some @IBOutlets
    @IBOutlet var searchImageView: UIImageView!
    
    // define some functions
    func configureCell(result: SearchResult) {
        searchImageView.layer.cornerRadius = 5.0
        searchImageView.layer.masksToBounds = true
        if let url = URL(string: result.urls.thumb) {
            self.searchImageView.kf.setImage(with: url)
        }
    }
    
}
