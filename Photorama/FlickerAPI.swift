//
//  FlickerAPI.swift
//  Photorama
//
//  Created by Patrick Lind on 2/23/16.
//  Copyright © 2016 Pickle Software. All rights reserved.
//

import Foundation
import Freddy

enum Method: String {
    case RecentPhotos = "flickr.photos.getRecent"
}

enum PhotosResult {
    case Success([Photo])
    case Failure(ErrorType)
}

enum FlickrError: ErrorType {
    case InvalidJSONData
}

struct FlickerAPI {
    
    private static let baseURLString = "https://api.flickr.com/services/rest"
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
    
    private static func photoFromJSONObject(json: JSON) -> Photo? {
        
        var photo: Photo? = nil
        do {
            photo = try Photo(json: json)
        }
        catch {
            print("Problem creating Photo")
        }
        
        return photo
    }
    
    static func recentPhotosURL() -> NSURL {
        return flickerURL(method: .RecentPhotos, parameters: ["extras": "url_h, date_taken"])
    }
    
    static func photosFromJSONData(data: NSData) -> PhotosResult {
        do {
            let jsonObject = try JSONParser.createJSONFromData(data)
            
            if jsonObject == nil {
                return .Failure(FlickrError.InvalidJSONData)
            }
            
            guard let photosArray: [Photo] = try jsonObject.array("photos", "photo").map(Photo.init) else {
                return .Failure(FlickrError.InvalidJSONData)
            }
            
            return .Success(photosArray)
        }
        catch let error {
            return .Failure(error)
        }
    }
}