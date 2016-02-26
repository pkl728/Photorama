//
//  PhotosViewController.swift
//  Photorama
//
//  Created by Patrick Lind on 2/23/16.
//  Copyright © 2016 Pickle Software. All rights reserved.
//

import UIKit

class PhotosViewController: UIViewController {
    
    @IBOutlet var imageView: UIImageView!
    var store: PhotoStore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        store.fetchRecentPhotos() {
            (photosResult) -> Void in
            
            switch photosResult {
            case let .Success(photos):
                print("Successfully found \(photos.count) recent photos.")
            case let .Failure(error):
                print("Error Fetching recent photos: \(error)")
            }
        }
    }
    
}
