//
//  F2FViewController.swift
//  Food2Fork
//
//  Created by Sami Taha on 7/18/18.
//  Copyright © 2018 Sami Taha. All rights reserved.
//

import UIKit

/// View states
enum ViewState {
    /// View is loading
    case loading
    /// View is populated with results
    case populated
    /// There are major errors that the user should know about
    case error
    /// The view has no results to show
    case empty
    /// The very first state of the view controller. For example, when the user first launches the application, this is the initial state
    case loadScreen
}
class F2FViewController: UIViewController {

    // MARK: View Controller Lifecycle Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        setBackgroundColor(.white)
        setViewForState()
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
                sSelf.viewState = recipes.count > 0 ? .populated : .empty
                sSelf.recipeCollectionView.reloadData()
            case .failure(_):
                sSelf.viewState = .error
            }
        }
    }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        recipeCollectionView.collectionViewLayout.invalidateLayout()
    }
    
    override func loadView() {
        super.loadView()
        view.addSubview(recipeCollectionView)
        view.addSubview(titleView)
        
        let margins = view.safeAreaLayoutGuide
        
        /* Set recipeCollectionView constraints */
        recipeCollectionView.topAnchor.constraint(equalTo: margins.topAnchor, constant: LayoutConstaints.top).isActive = true
        recipeCollectionView.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: LayoutConstaints.bottom).isActive = true
        recipeCollectionView.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: LayoutConstaints.leading).isActive = true
        recipeCollectionView.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: LayoutConstaints.trailing).isActive = true
        
        /* Set titleView constraints */
        titleView.topAnchor.constraint(equalTo: margins.topAnchor, constant: LayoutConstaints.top).isActive = true
        titleView.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: LayoutConstaints.bottom).isActive = true
        titleView.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: LayoutConstaints.leading).isActive = true
        titleView.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: LayoutConstaints.trailing).isActive = true
    }
    
    
    // MARK: Views to display to User
    
    /// A view that shows a title to display to the user.
    /// Used to present the state of the View Controller to the user, e.g., the first load screen, when the view is searching, etc.
    private var titleView : TitleView = {
        let titleView = TitleView()
        titleView.translatesAutoresizingMaskIntoConstraints = false
        return titleView
    }()
    
    /// View to present recipes to the user
    private var recipeCollectionView : UICollectionView = {
        let collectionFlow = UICollectionViewFlowLayout.init()
        collectionFlow.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: collectionFlow)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = UIColor.white
        return collectionView
    }()
    
    // MARK: State handler
    
    private func setViewForState() {
        switch viewState {
        case .loadScreen:
            recipeCollectionView.isHidden = true
            titleView.isHidden = false
            titleView.configureLabel("Welcome")
        case .loading:
            recipeCollectionView.isHidden = true
            titleView.isHidden = false
            titleView.configureLabel("Loading...")
        case .error:
            recipeCollectionView.isHidden = true
            titleView.isHidden = false
            titleView.configureLabel("Oh know, it seems there was an error. Quit me and try again?")
        case .empty:
            recipeCollectionView.isHidden = true
            titleView.isHidden = false
            titleView.configureLabel("It sems no results were returned. ")
        case .populated:
            recipeCollectionView.isHidden = false
            titleView.isHidden = true
        }
    }
    
    /// Variable to hold the state of the view
    private var viewState = ViewState.loadScreen {
        didSet {
            setViewForState()
        }
    }
 
    // MARK: CollectionView
    
    /// Data source for the recipeColectionView
    private var recipes = [Recipe]()
 
    /// Reuse identifier for recipeCollectionView
    private struct ReuseIdentifiers {
        static let foodCollectionCell = "foodCollectionCell"
        private init() {}
    }
    
    // MARK: Private
    private func setBackgroundColor(_ color: UIColor) {
        view.backgroundColor = color
    }
    
    private struct LayoutConstaints {
        static let top = CGFloat(8.0)
        static let bottom = CGFloat(-8.0)
        static let leading = CGFloat(8.0)
        static let trailing = CGFloat(-8.0)
        private init() {}
    }
    
}

// MARK: CollectionView Delegate and CollectionViewDataSource Methods
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
    
    /// Configure cell is willDisplay instead of cellForItemAt because pre-fetching is enabled
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
                print(error)
            }
        }
        
    }
}

// MARK: UICollectionViewDelegateFlowLayout methods
/// QUESTION: I struggled with how I should be implementing this method. In this case, the API does not provide me useful information about the size of each image. How do I know what each cell size should be?
extension F2FViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.safeAreaLayoutGuide.layoutFrame.width * 0.8, height: view.safeAreaLayoutGuide.layoutFrame.height * 0.8)
    }
}



