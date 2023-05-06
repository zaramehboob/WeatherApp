//
//  ImageView+Extensions.swift
//  WeatherApp
//
//  Created by Zara on 9/9/21.
//

import Foundation
import UIKit
import SDWebImage

extension UIImageView {
    
    func downloadImage(url: URL?) {
        guard let imageUrl = url else {return}
        self.sd_setImage(with: imageUrl) { image, error, cache, url in
            guard image != nil else {return}
            self.image = image
        }
    }
}
