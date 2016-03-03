//
//  PhotoInfoViewController.swift
//  Photorama
//
//  Created by Patrick Lind on 3/2/16.
//  Copyright © 2016 Pickle Software. All rights reserved.
//

import UIKit

class PhotoInfoViewController: UIViewController {
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var timesViewed: UILabel!
    
    var photo: Photo! {
        didSet {
            navigationItem.title = photo.title
        }
    }
    
    var store: PhotoStore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let timesViewed = Float(photo.timesViewed) + 1
        photo.setValue(timesViewed, forKey: "timesViewed")
        
        store.fetchImageForPhoto(photo) { (result) -> Void in
            
            switch result {
            case let .Success(image):
                NSOperationQueue.mainQueue().addOperationWithBlock() {
                    self.imageView.image = image
                    self.timesViewed.text = String(self.photo.timesViewed)
                }
            case let .Failure(error):
                print("Error fetching image for photo: \(error)")
            }
        }
    }
}
