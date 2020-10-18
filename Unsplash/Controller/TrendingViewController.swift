//
//  ViewController.swift
//  Unsplash
//
//  Created by Tarokh on 9/23/20.
//  Copyright © 2020 Tarokh. All rights reserved.
//

import UIKit
import JGProgressHUD
import CollectionViewWaterfallLayout
import Kingfisher
import Loaf
import Lightbox
import CoreData

class TrendingViewController: UIViewController, UINavigationControllerDelegate {
    
    //MARK: - @IBOutlets
    @IBOutlet var trendingCollectionView: UICollectionView!
    
    
    //MARK: - Variables
    var hud: JGProgressHUD?
    private let trendingViewModel = TrendingViewModel()
    var cellSizes = [CGSize]()
    var index = 1
    var isLoading = false
    var lightBoxController: LightboxController?
    
    
    //MARK: - Views
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        hud = JGProgressHUD(style: .dark)
        hud?.indicatorView = JGProgressHUDIndeterminateIndicatorView()
        hud?.show(in: view, animated: true)
        trendingCollectionView.register(UINib(nibName: "TrendingCell", bundle: nil), forCellWithReuseIdentifier: "trendingCell")
        trendingCollectionView.delegate = self
        trendingCollectionView.dataSource = self
        getTrendingImages(page: index)
        setupWaterfallLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBarController?.title = "Trending"
        tabBarController?.navigationController?.navigationBar.prefersLargeTitles = true
        tabBarController?.navigationItem.rightBarButtonItem = nil
    }
    
    //MARK: - Functions
    private func setupWaterfallLayout() {
        let waterfallLayout = CollectionViewWaterfallLayout()
        waterfallLayout.columnCount = 2
        waterfallLayout.headerHeight = 50
        waterfallLayout.footerHeight = 20
        waterfallLayout.minimumColumnSpacing = 5
        waterfallLayout.minimumInteritemSpacing = 5
        trendingCollectionView.collectionViewLayout = waterfallLayout
    }
    
    private func getTrendingImages(page: Int) {
        trendingViewModel.getTrendingImages(page: page) { (state) in
            print(state)
            switch state {
            case .success:
                //print("Success")
                DispatchQueue.global().async {
                    sleep(2)
                    DispatchQueue.main.async {
                        self.trendingCollectionView.reloadData()
                        self.hud?.dismiss(animated: true)
                    }
                }
            case .failure:
                print("Failed, Please try again!")
            }
        }
    }
    
    private func previewImage(image: String) {
        lightBoxController = LightboxController(images: [LightboxImage(imageURL: URL(string: image)!)])
        lightBoxController!.dynamicBackground = true
    }
    
    private func saveImage(image: String) {
        let imageString = image
        if let url = URL(string: imageString) {
            let data = try? Data(contentsOf: url)
            let savedImage = UIImage(data: data!)
            UIImageWriteToSavedPhotosAlbum(savedImage!, nil, nil, nil)
            Loaf("Image successfully saved to your photos!", state: .success, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show()
        }
    }
    
    private func save(imageURL: String, width: Int, height: Int) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "Unsplash", in: managedContext)
        let unsplash = NSManagedObject(entity: entity!, insertInto: managedContext)
        unsplash.setValue(imageURL, forKey: "imageURL")
        unsplash.setValue(width, forKey: "width")
        unsplash.setValue(height, forKey: "height")
        do {
            try managedContext.save()
            print("Data Saved Successfully!")
            Loaf("Your image successfully added to your favorite!", state: .success, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show()
        }
        catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
}

//MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension TrendingViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return trendingViewModel.trendingItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "trendingCell", for: indexPath) as! TrendingCell
        let trendingItem = trendingViewModel.trendingItems[indexPath.row]
        let trendingURL = URL(string: (trendingItem.urls?.thumb)!)
        //print("The url is: \(trendingURL!)")
        cell.trendingImageView.layer.cornerRadius = 5.0
        cell.trendingImageView.layer.masksToBounds = true
        cell.trendingImageView.kf.setImage(with: trendingURL!)
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if (offsetY > contentHeight - scrollView.frame.height * 4){
            index += 1
            getTrendingImages(page: index)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let trendingItem = trendingViewModel.trendingItems[indexPath.row]
        let alert = UIAlertController(title: "Notice", message: "Please choose your action!", preferredStyle: .actionSheet)
        let previewButton = UIAlertAction(title: "Preview", style: .default) { (previewAction) in
            let trendingImages = trendingItem.urls?.regular
            self.previewImage(image: trendingImages!)
            self.present(self.lightBoxController!, animated: true, completion: nil)
        }
        let saveButton = UIAlertAction(title: "Save", style: .default) { (saveAction) in
            self.saveImage(image: (trendingItem.urls?.regular)!)
        }
        let favoriteButton = UIAlertAction(title: "Favorite", style: .default) { (favoritePreview) in
            self.save(imageURL: (trendingItem.urls?.thumb)!, width: trendingItem.width!, height: trendingItem.height!)
        }
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        cancelButton.setValue(UIColor.red, forKey: "titleTextColor")
        alert.addAction(previewButton)
        alert.addAction(saveButton)
        alert.addAction(cancelButton)
        alert.addAction(favoriteButton)
        self.present(alert, animated: true, completion: nil)
    }
    
}

//MARK: - CollectionViewWaterFallLayoutDelegate
extension TrendingViewController: CollectionViewWaterfallLayoutDelegate {
    
    func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let trendingItem = trendingViewModel.trendingItems[indexPath.row]
        let trendingWidth = trendingItem.width
        let trendingHeight = trendingItem.height
        cellSizes.append(CGSize(width: trendingWidth!, height: trendingHeight!))
        //print(cellSizes)
        return cellSizes[indexPath.item]
    }
    
}
