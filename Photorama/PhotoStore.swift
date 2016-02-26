//
//  PhotoStore.swift
//  Photorama
//
//  Created by Patrick Lind on 2/23/16.
//  Copyright © 2016 Pickle Software. All rights reserved.
//

import Foundation

class PhotoStore {
    
    let session: NSURLSession = {
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        return NSURLSession(configuration: config)
    } ()
    
    func fetchRecentPhotos(completion completion: (PhotosResult) -> Void) {
        
        let url = FlickerAPI.recentPhotosURL()
        let request = NSURLRequest(URL: url)
        let task = session.dataTaskWithRequest(request) {
            (data, response, error) -> Void in
            
            let result = self.processRecentPhotosRequest(data: data, error: error)
            completion(result)
        }
        task.resume()
    }
    
    func processRecentPhotosRequest(data data: NSData?, error: NSError?) -> PhotosResult {
        
        guard let jsonData = data else {
            return .Failure(FlickrError.InvalidJSONData)
        }
        
        return FlickerAPI.photosFromJSONData(jsonData)
    }
}
