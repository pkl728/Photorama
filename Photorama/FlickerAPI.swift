//
//  FlickerAPI.swift
//  Photorama
//
//  Created by Patrick Lind on 2/23/16.
//  Copyright © 2016 Pickle Software. All rights reserved.
//

import Foundation

enum Method: String {
    case RecentPhotos = "flicker.photos.getRecent"
}

enum PhotosResult {
    case Success([Photo])
    case Failure(ErrorType)
}

enum FlickrError: ErrorType {
    case InvalidJSONData
}

struct FlickerAPI {
    
    private static let baseURLString = "https://api.flicker.com/services/rest"
    private static let APIKey = "a6d819499131071f158fd740860a5a88"
    
    private static let dateFormatter: NSDateFormatter = {
       let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()
    
    private static func flickerURL(method method: Method, parameters: [String:String]?) -> NSURL {
        
        let components = NSURLComponents(string: baseURLString)!
        
        var queryItems = [NSURLQueryItem]()
        
        let baseParams = [
            "method": method.rawValue,
            "format": "json",
            "nojsoncallback": "1",
            "api_key": APIKey
        ]
        
        for (key, value) in baseParams {
            let item = NSURLQueryItem(name: key, value: value)
            queryItems.append(item)
        }
        
        if let additionalParams = parameters {
            for (key, value) in additionalParams {
                let item = NSURLQueryItem(name: key, value: value)
                queryItems.append(item)
            }
        }
        
        components.queryItems = queryItems
        
        return components.URL!
    }
    
    private static func photoFromJSONObject(json: [String : AnyObject]) -> Photo? {
        
        guard let photoID = json["id"] as? String,
                    title = json["title"] as? String,
                    dateString = json["datetaken"] as? String,
                    photoURLString = json["url_h"] as? String,
                    url = NSURL(string: photoURLString),
            dateTaken = dateFormatter.dateFromString(dateString) else {
                return nil
        }
        
        return Photo(title: title, photoID: photoID, remoteURL: url, dateTaken: dateTaken)
    }
    
    static func recentPhotosURL() -> NSURL {
        return flickerURL(method: .RecentPhotos, parameters: ["extras": "url_h, date_taken"])
    }
    
    static func photosFromJSONData(data: NSData) -> PhotosResult {
        do {
            let jsonObject: AnyObject = try NSJSONSerialization.JSONObjectWithData(data, options: [])
            
            guard let jsonDictionary = jsonObject as? [NSObject:AnyObject],
                photos = jsonDictionary["photos"] as? [String:AnyObject],
                photosArray = photos["photo"] as? [[String:AnyObject]] else {
                    
                    return .Failure(FlickrError.InvalidJSONData)
            }
            
            var finalPhotos = [Photo]()
            
            for photoJSON in photosArray {
                if let photo = photoFromJSONObject(photoJSON) {
                    finalPhotos.append(photo)
                }
            }
            
            if finalPhotos.count == 0 && photosArray.count > 0 {
                return .Failure(FlickrError.InvalidJSONData)
            }
            
            return .Success(finalPhotos)
        }
        catch let error {
            return .Failure(error)
        }
    }
}