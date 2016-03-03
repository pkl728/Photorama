//
//  ImageStore.swift
//  HomePwn3r
//
//  Created by Patrick Lind on 2/18/16.
//  Copyright © 2016 Pickle Software. All rights reserved.
//

import UIKit

class ImageStore: NSObject {
    
    let cache = NSCache()
    
    func setImage(image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: key)
        
        let imageURL = imageURLForKey(key)
        
        if let data = UIImagePNGRepresentation(image) {
            data.writeToURL(imageURL, atomically: true)
        }
    }
    
    func imageForKey(key: String) -> UIImage? {
        if let existingImage = cache.objectForKey(key) as? UIImage {
            return existingImage
        }
        
        let imageURL = imageURLForKey(key)
        guard let imageFromDisk = UIImage(contentsOfFile: imageURL.path!) else {
            return nil
        }
        
        cache.setObject(imageFromDisk, forKey: key)
        return imageFromDisk
    }
    
    func imageURLForKey(key: String) -> NSURL {
        let documentsDirectories =  NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        let documentDirectory = documentsDirectories.first!
        
        return documentDirectory.URLByAppendingPathComponent(key)
    }
    
    func deleteImageForKey(key: String) {
        cache.removeObjectForKey(key)
        
        let imageURL = imageURLForKey(key)
        do {
            try NSFileManager.defaultManager().removeItemAtURL(imageURL)
        }
        catch let deleteError {
            print("Error removing the image from disk: \(deleteError)")
        }
    }
}
