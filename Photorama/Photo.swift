//
//  Photo.swift
//  Photorama
//
//  Created by Patrick Lind on 3/2/16.
//  Copyright © 2016 Pickle Software. All rights reserved.
//

import UIKit
import CoreData

class Photo: NSManagedObject {

// Insert code here to add functionality to your managed object subclass

    var image: UIImage?
    
    private let dateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()
    
    override func awakeFromInsert() {
        title = ""
        photoID = ""
        remoteURL = NSURL()
        photoKey = NSUUID().UUIDString
        dateTaken = NSDate()
        timesViewed = 0
    }
}
