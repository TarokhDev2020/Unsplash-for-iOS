//
//  SearchViewController.swift
//  Unsplash
//
//  Created by Tarokh on 9/23/20.
//  Copyright © 2020 Tarokh. All rights reserved.
//

import UIKit
import JGProgressHUD
import CollectionViewWaterfallLayout
import Loaf
import Lightbox
import CoreData
import DZNEmptyDataSet

class SearchViewController: UIViewController, UISearchResultsUpdating {
    
    //MARK: - @IBOutlets
    @IBOutlet var searchCollectionView: UICollectionView!
    
    
    //MARK: - Variables
    private var searchController = UISearchController()
    private let searchViewModel = SearchViewModel()
    var hud: JGProgressHUD?
    var cellSizes = [CGSize]()
    var lightBoxController: LightboxController?

    //MARK: - Views
    override func viewDidLoad() {
        super.viewDidLoad()

        searchCollectionView.register(UINib(nibName: "SearchCell", bundle: nil), forCellWithReuseIdentifier: "searchCell")
        searchCollectionView.delegate = self
        searchCollectionView.dataSource = self
        searchCollectionView.emptyDataSetDelegate = self
        searchCollectionView.emptyDataSetSource = self
        setupWaterfallLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBarController?.title = "Search"
        tabBarController?.navigationController?.navigationBar.prefersLargeTitles = false
        let searchBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(search))
        tabBarController?.navigationItem.rightBarButtonItem = searchBarButtonItem
        //definesPresentationContext = true
    }
    
    //MARK: - Functions
    @objc private func search() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Type something..."
        self.present(searchController, animated: true, completion: nil)
    }
    
    private func searchImages(q: String) {
        searchViewModel.getSearchedImages(q: q) { (state) in
            switch state {
            case .success:
                DispatchQueue.global().async {
                    sleep(2)
                    DispatchQueue.main.async {
                        self.hud?.dismiss(animated: true)
                        self.searchCollectionView.reloadData()
                        self.searchController.dismiss(animated: true, completion: nil)
                        self.tabBarController?.title = q
                    }
                }
            case .failure:
                print("Failure")
            }
        }
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else {return}
        print("The search item is: \(text)")
    }
    
    private func setupWaterfallLayout() {
        let waterfallLayout = CollectionViewWaterfallLayout()
        waterfallLayout.columnCount = 2
        waterfallLayout.headerHeight = 50
        waterfallLayout.footerHeight = 20
        waterfallLayout.minimumColumnSpacing = 5
        waterfallLayout.minimumInteritemSpacing = 5
        searchCollectionView.collectionViewLayout = waterfallLayout
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
    
    private func previewImage(image: String) {
        lightBoxController = LightboxController(images: [LightboxImage(imageURL: URL(string: image)!)])
        lightBoxController!.dynamicBackground = true
    }

}

//MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension SearchViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searchViewModel.searchItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let searchCell = collectionView.dequeueReusableCell(withReuseIdentifier: "searchCell", for: indexPath) as! SearchCell
        let searchItem = searchViewModel.searchItems[indexPath.row]
        searchCell.configureCell(result: searchItem)
        return searchCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = searchViewModel.searchItems[indexPath.row]
        let alert = UIAlertController(title: "Notice", message: "Please choose your action!", preferredStyle: .actionSheet)
        let previewButton = UIAlertAction(title: "Preview", style: .default) { (previewAction) in
            self.previewImage(image: item.urls.regular)
            self.present(self.lightBoxController!, animated: true, completion: nil)
        }
        let saveButton = UIAlertAction(title: "Save", style: .default) { (saveAction) in
            self.saveImage(image: item.urls.regular)
        }
        let favoriteButton = UIAlertAction(title: "Favorite", style: .default) { (favoriteAction) in
            self.save(imageURL: item.urls.thumb, width: item.width, height: item.height)
        }
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        cancelButton.setValue(UIColor.red, forKey: "titleTextColor")
        alert.addAction(previewButton)
        alert.addAction(saveButton)
        alert.addAction(favoriteButton)
        alert.addAction(cancelButton)
        self.present(alert, animated: true, completion: nil)
    }
    
}

//MARK: - UISearchBarDelegate
extension SearchViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchViewModel.searchItems = []
        hud = JGProgressHUD(style: .dark)
        hud?.indicatorView = JGProgressHUDIndeterminateIndicatorView()
        hud?.show(in: self.view, animated: true)
        guard let text = searchBar.text else {return}
        self.searchImages(q: text)
    }
    
}

//MARK: - CollectionViewWaterFallLayoutDelegate
extension SearchViewController: CollectionViewWaterfallLayoutDelegate {
    
    func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let searchItem = searchViewModel.searchItems[indexPath.row]
        let searchWidth = searchItem.width
        let searchHeight = searchItem.height
        cellSizes.append(CGSize(width: searchWidth, height: searchHeight))
        //print(cellSizes)
        return cellSizes[indexPath.item]
    }
    
}

//MARK: - DZNEmptyDataSetDelegate, DZNEmptyDataSetSource
extension SearchViewController: DZNEmptyDataSetDelegate, DZNEmptyDataSetSource {
    
    func title(forEmptyDataSet scrollView: UIScrollView?) -> NSAttributedString? {
        let text = "Tap the search icon to search"
        
        let attributes = [
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18.0),
            NSAttributedString.Key.foregroundColor: UIColor.darkGray
        ]
        
        return NSAttributedString(string: text, attributes: attributes)
    }
    
}


