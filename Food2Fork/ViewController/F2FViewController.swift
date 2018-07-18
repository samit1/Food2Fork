//
//  F2FViewController.swift
//  Food2Fork
//
//  Created by Sami Taha on 7/18/18.
//  Copyright © 2018 Sami Taha. All rights reserved.
//

import UIKit

class F2FViewController: UIViewController {
//
//    private var collectionView : UICollectionView = {
//        let collectionView = UICollectionView()
//        collectionView.translatesAutoresizingMaskIntoConstraints = false
//        return collectionView
//    }()
//    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setBackgroundColor(.white)
        F2FAPI.performSearch(for: "cheese") { (results) in
            print(results)
        }


    }
    
    private func setBackgroundColor(_ color: UIColor) {
        view.backgroundColor = color
    }
}
