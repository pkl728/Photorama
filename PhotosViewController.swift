//
//  PhotosViewController.swift
//  Photorama
//
//  Created by Patrick Lind on 2/23/16.
//  Copyright © 2016 Pickle Software. All rights reserved.
//

import UIKit

class PhotosViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var segmentedControl: UISegmentedControl!
    
    @IBAction func indexChanged(sender: UISegmentedControl) {
        
        let segControl = sender as UISegmentedControl
        switch segControl.selectedSegmentIndex
        {
        case 0:
            retrieveAllPhotos()
        case 1:
            retrieveFavoritePhotos()
        default:
            break
        }
    }
    
    var store: PhotoStore!
    let photoDataSource = PhotoDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = photoDataSource
        collectionView.delegate = self
        
        store.fetchRecentPhotos() {
            (photosResult) -> Void in
            
            let sortByDateTaken = NSSortDescriptor(key: "dateTaken", ascending: true)
            let allPhotos = try! self.store.fetchMainQueuePhotos(predicate: nil, sortDescriptors: [sortByDateTaken])
            
            NSOperationQueue.mainQueue().addOperationWithBlock() {
                self.photoDataSource.photos = allPhotos
                self.collectionView.reloadSections(NSIndexSet(index: 0))
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "ShowPhoto" {
            if let selectedIndexPath = collectionView.indexPathsForSelectedItems()?.first {
                
                let photo = photoDataSource.photos[selectedIndexPath.row]
                
                let destinationVC = segue.destinationViewController as! PhotoInfoViewController
                destinationVC.photo = photo
                destinationVC.store = store
            }
        }
    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        collectionView.performBatchUpdates(nil, completion: nil)
    }
    
    func retrieveAllPhotos() {
        let sortByDateTaken = NSSortDescriptor(key: "dateTaken", ascending: true)
        let photos = try! store.fetchMainQueuePhotos(predicate: nil, sortDescriptors: [sortByDateTaken])
        
        NSOperationQueue.mainQueue().addOperationWithBlock() {
            self.photoDataSource.photos = photos
            self.collectionView.reloadSections(NSIndexSet (index: 0))
        }
    }

    func retrieveFavoritePhotos() {
        let favPredicate = NSPredicate(format: "favorite == true")
        let sortByDateTaken = NSSortDescriptor(key: "dateTaken", ascending: true)
        let photos = try! store.fetchMainQueuePhotos(predicate: favPredicate, sortDescriptors: [sortByDateTaken])

        NSOperationQueue.mainQueue().addOperationWithBlock() {
            self.photoDataSource.photos = photos
            self.collectionView.reloadSections(NSIndexSet (index: 0))
        }
    }
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
     
        let photo = photoDataSource.photos[indexPath.row]
        
        store.fetchImageForPhoto(photo) { (result) -> Void in
         
            NSOperationQueue.mainQueue().addOperationWithBlock() {
                
                let photoIndex = self.photoDataSource.photos.indexOf(photo)!
                let photoIndexPath = NSIndexPath(forRow: photoIndex, inSection: 0)
                
                if let cell = self.collectionView.cellForItemAtIndexPath(photoIndexPath) as? PhotoCollectionViewCell {
                    cell.updateWithImage(photo.image)
                }
            }
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        return CGSize(width: collectionView.frame.width / 4 - 8, height: collectionView.frame.width / 4 - 8)
    }
}
