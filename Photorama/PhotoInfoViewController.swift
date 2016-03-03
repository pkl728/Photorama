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
    @IBOutlet var favoriteLabel: UILabel!
    
    @IBAction func favoritePicture(sender: AnyObject) {
        if photo.favorite {
            photo.favorite = false
            favoriteLabel.hidden = true
        }
        else {
            photo.favorite = true
            favoriteLabel.hidden = false
        }
    }
    
    var photo: Photo! {
        didSet {
            navigationItem.title = photo.title
        }
    }
    
    var store: PhotoStore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        favoriteLabel.hidden = !photo.favorite
        
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowTags" {
            let navController = segue.destinationViewController as! UINavigationController
            let tagController = navController.topViewController as! TagsViewController
            
            tagController.store = store
            tagController.photo = photo
        }
    }
}
