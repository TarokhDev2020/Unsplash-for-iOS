//
//  FavoriteViewController.swift
//  Unsplash
//
//  Created by Tarokh on 9/23/20.
//  Copyright © 2020 Tarokh. All rights reserved.
//

import UIKit
import CoreData
import JGProgressHUD
import CollectionViewWaterfallLayout
import DZNEmptyDataSet
import Lightbox
import Loaf

class FavoriteViewController: UIViewController {
    
    //MARK: - @IBOutlets
    @IBOutlet var favoriteCollectionView: UICollectionView!
    
    
    //MARK: - Variables
    private var favoriteItems = [NSManagedObject]()
    private var managedContext: NSManagedObjectContext?
    var hud: JGProgressHUD?
    var cellSizes = [CGSize]()
    var lightBoxController: LightboxController?
    
    //MARK: - Views
    override func viewDidLoad() {
        super.viewDidLoad()
        
        favoriteCollectionView.register(UINib(nibName: "FavoriteCell", bundle: nil), forCellWithReuseIdentifier: "favoriteCell")
        favoriteCollectionView.delegate = self
        favoriteCollectionView.dataSource = self
        favoriteCollectionView.emptyDataSetDelegate = self
        favoriteCollectionView.emptyDataSetSource = self
        setupWaterfallLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBarController?.title = "Favorite"
        tabBarController?.navigationController?.navigationBar.prefersLargeTitles = true
        tabBarController?.navigationItem.rightBarButtonItem = nil
        fetchFavoriteItems()
    }
    
    //MARK: - Functions
    private func fetchFavoriteItems() {
        favoriteItems = []
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Unsplash")
        do {
            let unsplash = try managedContext?.fetch(fetchRequest)
            for data in unsplash! {
                favoriteItems.append(data)
                DispatchQueue.main.async {
                    self.hud?.dismiss(animated: true)
                    self.favoriteCollectionView.reloadData()
                }
            }
        }
        catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    private func setupWaterfallLayout() {
        let waterfallLayout = CollectionViewWaterfallLayout()
        waterfallLayout.columnCount = 2
        waterfallLayout.headerHeight = 50
        waterfallLayout.footerHeight = 20
        waterfallLayout.minimumColumnSpacing = 5
        waterfallLayout.minimumInteritemSpacing = 5
        favoriteCollectionView.collectionViewLayout = waterfallLayout
    }
    
    private func delete(indexPath: IndexPath) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        
        context.delete(favoriteItems[indexPath.row] as NSManagedObject)
        favoriteItems.remove(at: indexPath.row)
        
        do {
            try context.save()
            self.favoriteCollectionView.deleteItems(at: [indexPath])
             Loaf("Your image successfully deleted!", state: .success, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show()
            DispatchQueue.main.async {
                self.favoriteCollectionView.reloadData()
            }
        }
        catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    private func previewImage(image: String) {
        lightBoxController = LightboxController(images: [LightboxImage(imageURL: URL(string: image)!)])
        lightBoxController!.dynamicBackground = true
    }
    
}

//MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension FavoriteViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return favoriteItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let favoriteCell = collectionView.dequeueReusableCell(withReuseIdentifier: "favoriteCell", for: indexPath) as! FavoriteCell
        let favorite = favoriteItems[indexPath.row]
        favoriteCell.configureCell(favorite: favorite)
        return favoriteCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = favoriteItems[indexPath.row]
        let alert = UIAlertController(title: "Notice", message: "Please choose your action!", preferredStyle: .actionSheet)
        let previewButton = UIAlertAction(title: "Preview", style: .default) { (previewAction) in
            self.previewImage(image: item.value(forKey: "imageURL") as! String)
            self.present(self.lightBoxController!, animated: true, completion: nil)
        }
        let deleteAction = UIAlertAction(title: "Delete", style: .default) { (deleteAction) in
            self.delete(indexPath: indexPath)
        }
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        cancelButton.setValue(UIColor.red, forKey: "titleTextColor")
        alert.addAction(previewButton)
        alert.addAction(deleteAction)
        alert.addAction(cancelButton)
        self.present(alert, animated: true, completion: nil)
    }
    
}

//MARK: - CollectionViewWaterFallLayoutDelegate
extension FavoriteViewController: CollectionViewWaterfallLayoutDelegate {
    
    func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let favorite = favoriteItems[indexPath.row]
        let favoriteWidth = favorite.value(forKey: "width") as! Int
        let favoriteHeight = favorite.value(forKey: "height") as! Int
        cellSizes.append(CGSize(width: favoriteWidth, height: favoriteHeight))
        //print(cellSizes)
        return cellSizes[indexPath.item]
    }
    
}

//MARK: - DZNEmptyDataSetDelegate, DZNEmptyDataSetSource
extension FavoriteViewController: DZNEmptyDataSetDelegate, DZNEmptyDataSetSource {
    
    func title(forEmptyDataSet scrollView: UIScrollView?) -> NSAttributedString? {
        let text = "Add some images to your favorite to see the list!"
        
        let attributes = [
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18.0),
            NSAttributedString.Key.foregroundColor: UIColor.darkGray
        ]
        
        return NSAttributedString(string: text, attributes: attributes)
    }
    
}

