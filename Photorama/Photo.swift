//
//  Photo.swift
//  Photorama
//
//  Created by Patrick Lind on 2/23/16.
//  Copyright © 2016 Pickle Software. All rights reserved.
//

import UIKit
import Freddy

public class Photo: JSONDecodable {
    
    var title: String
    var remoteURL: NSURL?
    var photoID: String
    var dateTaken: NSDate?
    
    var image: UIImage?
    
    private let dateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()
    
    init(title: String, photoID: String, remoteURL: NSURL, dateTaken: NSDate) {
        self.title = title
        self.photoID = photoID
        self.remoteURL = remoteURL
        self.dateTaken = dateTaken
    }
    
    required public init(json value: JSON) throws {
        self.title = ""
        self.photoID = ""
        remoteURL = nil
        dateTaken = nil
        image = nil
        
        self.title = try value.string("title")
        self.photoID = try value.string("id")
        let dateString = try value.string("datetaken")
        self.dateTaken = dateFormatter.dateFromString(dateString)
        do {
            let url_h = try value.string("url_h")
            self.remoteURL = NSURL(string: url_h)
        }
        catch {
            remoteURL = nil
        }
    }
}

extension Photo: Equatable {}

public func == (lhs: Photo, rhs: Photo) -> Bool {
    return lhs.photoID == rhs.photoID
}