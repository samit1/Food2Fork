//
//  F2FViewController.swift
//  Food2Fork
//
//  Created by Sami Taha on 7/18/18.
//  Copyright © 2018 Sami Taha. All rights reserved.
//

import UIKit

enum ViewState {
    case loading
    case populated
    case error
    case empty
    case loadScreen
}

class F2FViewController: UIViewController {

//    private var titleView : TitleView = {
//        let titleView = TitleView()
//        titleView.translatesAutoresizingMaskIntoConstraints = false
//        return titleView
//    }()
    
    private var recipeCollectionView : UICollectionView = {
        let collectionFlow = UICollectionViewFlowLayout.init()
        collectionFlow.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: collectionFlow)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = UIColor.white
        return collectionView
    }()
    
    private var recipes = [Recipe]()
//    private var viewState = ViewState.loadScreen {
//        didSet {
//            setViewForState()
//        }
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setBackgroundColor(.white)
        recipeCollectionView.delegate = self
        recipeCollectionView.dataSource = self
        recipeCollectionView.register(FoodCollectionViewCell.self, forCellWithReuseIdentifier: "foodCollectionCell")
        
        F2FAPI.performSearch(for: "cheese") {[weak self] (results) in
            guard let sSelf = self else {
                return
            }
            switch results {
            case .success(let recipeResponse):
                let recipes = recipeResponse.recipes
                print(recipes)
                sSelf.recipes = recipes
//                sSelf.viewState = recipes.count > 0 ? .populated : .empty
                sSelf.recipeCollectionView.reloadData()
            // TODO: Create error view
            case .failure(let error):
//                sSelf.viewState = .error
                print(error)
            }
        }
//        setViewForState()
    }
    
//    private func setViewForState() {
//        switch viewState {
//        case .loadScreen:
//            recipeCollectionView.isHidden = true
//            titleView.isHidden = false
//            titleView.configureLabel("Welcome")
//        case .loading:
//            recipeCollectionView.isHidden = true
//            titleView.isHidden = false
//            titleView.configureLabel("Loading...")
//        case .error:
//            recipeCollectionView.isHidden = true
//            titleView.isHidden = false
//            titleView.configureLabel("Oh know, it seems there was an error. Quit me and try again?")
//        case .empty:
//            recipeCollectionView.isHidden = true
//            titleView.isHidden = false
//            titleView.configureLabel("It sems no results were returned. ")
//        case .populated:
//            recipeCollectionView.isHidden = false
//            titleView.isHidden = true
//        }
//    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        recipeCollectionView.collectionViewLayout.invalidateLayout()
    }
    
    
    
    private func setBackgroundColor(_ color: UIColor) {
        view.backgroundColor = color
    }
    
    
    private struct ReuseIdentifiers {
        static let foodCollectionCell = "foodCollectionCell"
        
        private init() {}
    }
    
    override func loadView() {
        super.loadView()
        view.addSubview(recipeCollectionView)
//        view.addSubview(titleView)
        
        let margins = view.safeAreaLayoutGuide
        
        /* Set recipeCollectionView constraints */
        recipeCollectionView.topAnchor.constraint(equalTo: margins.topAnchor, constant: LayoutConstaints.top).isActive = true
        recipeCollectionView.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: LayoutConstaints.bottom).isActive = true
        recipeCollectionView.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: LayoutConstaints.leading).isActive = true
        recipeCollectionView.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: LayoutConstaints.trailing).isActive = true
//        
//        /* Set titleView constraints */
//        titleView.topAnchor.constraint(equalTo: margins.topAnchor, constant: LayoutConstaints.top).isActive = true
//        titleView.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: LayoutConstaints.bottom).isActive = true
//        titleView.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: LayoutConstaints.leading).isActive = true
//        titleView.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: LayoutConstaints.trailing).isActive = true
//        
    }
    
    struct LayoutConstaints {
        static let top = CGFloat(8.0)
        static let bottom = CGFloat(-8.0)
        static let leading = CGFloat(8.0)
        static let trailing = CGFloat(-8.0)
        private init() {}
    }
    
}

extension F2FViewController : UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return recipes.count > 0 ? 1 : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return recipes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReuseIdentifiers.foodCollectionCell, for: indexPath) as! FoodCollectionViewCell
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let cell = recipeCollectionView.dequeueReusableCell(withReuseIdentifier: ReuseIdentifiers.foodCollectionCell, for: indexPath) as! FoodCollectionViewCell
        let recipe = recipes[indexPath.row]
        cell.configureCell(title: recipe.title)
        PhotoStore.searchForPhoto(url: recipe.imageURL) { (photoResult) in
            switch photoResult {
            case .success(let img):
                
                /// Check for race condition. If indexPath is no longer on screen do not set image
                guard let cell = collectionView.cellForItem(at: indexPath) as? FoodCollectionViewCell else {
                    return
                }
                
                cell.configureCell(title: recipe.title, img: img)
            case .failure(let error):
                // TODO: Add placeholder image
                print(error)
            }
        }
        
    }
}

// TODO: Need to smartly pick the size of each cell. How can this be done smartly?
extension F2FViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.safeAreaLayoutGuide.layoutFrame.width * 0.8, height: view.safeAreaLayoutGuide.layoutFrame.height * 0.8)
    }
}



