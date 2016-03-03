//
//  FlickerAPI.swift
//  Photorama
//
//  Created by Patrick Lind on 2/23/16.
//  Copyright © 2016 Pickle Software. All rights reserved.
//

import Foundation
import Freddy
import CoreData

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
    
    private static func photoFromJSONObject(json: JSON, inContext context: NSManagedObjectContext) -> Photo? {
        
        var photo: Photo!
        
        do {
            let photoID = try json.string("id"),
                title = try json.string("title"),
                photoURLString = try json.string("url_h"),
                url = NSURL(string: photoURLString),
                dateString = try json.string("datetaken"),
                dateTaken = dateFormatter.dateFromString(dateString)
            
            let fetchRequest = NSFetchRequest(entityName: "Photo")
            let predicate = NSPredicate(format: "photoID == \(photoID)")
            fetchRequest.predicate = predicate
            
            var fetchedPhotos: [Photo]!
            context.performBlockAndWait() {
                fetchedPhotos = try! context.executeFetchRequest(fetchRequest) as! [Photo]
            }
            if fetchedPhotos.count > 0 {
                return fetchedPhotos.first
            }
            
            context.performBlockAndWait() {
                photo = NSEntityDescription.insertNewObjectForEntityForName("Photo", inManagedObjectContext: context) as! Photo
                photo.title = title
                photo.photoID = photoID
                photo.remoteURL = url!
                photo.dateTaken = dateTaken!
            }
        }
        catch {
            print("Issue parsing JSON")
        }
        
        return photo
    }
    
    static func recentPhotosURL() -> NSURL {
        return flickerURL(method: .RecentPhotos, parameters: ["extras": "url_h, date_taken"])
    }
    
    static func photosFromJSONData(data: NSData, inContext context: NSManagedObjectContext) -> PhotosResult {
        do {
            let jsonObject = try JSONParser.createJSONFromData(data)
            
            if jsonObject == nil {
                return .Failure(FlickrError.InvalidJSONData)
            }
            
            guard let photosArray: [JSON] = try jsonObject.array("photos", "photo") else {
                return .Failure(FlickrError.InvalidJSONData)
            }
            
            var finalPhotos = [Photo]()
            
            for jsonPhoto in photosArray {
                if let photo = photoFromJSONObject(jsonPhoto, inContext: context) {
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