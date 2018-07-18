//
//  FoodCollectionViewCell.swift
//  Food2Fork
//
//  Created by Sami Taha on 7/18/18.
//  Copyright © 2018 Sami Taha. All rights reserved.
//

import UIKit

/// QUESTION: I wanted to add an activity indicator but I have trouble understanding what the size of the UIImage should be. 

class FoodCollectionViewCell: UICollectionViewCell {
    // MARK: Public methods
    override init(frame: CGRect) {
        super.init(frame: frame)
        vStackView.addArrangedSubview(title)
        vStackView.addArrangedSubview(imgView)
        addSubview(vStackView)
        backgroundColor = UIColor.white
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCell(title: String, img: UIImage) {
        self.title.text = title
        imgView.image = img
    }
    
    func configureCell(title: String) {
        self.title.text = title
        imgView.image = nil
    }
    
    func configureCellImg(img: UIImage) {
        imgView.image = img
    }
    
    // MARK: View lifecycle
    override func prepareForReuse() {
        super.prepareForReuse()
        
        title.text = ""
        imgView.image = nil
    }
    
    override func updateConstraints() {
        if viewsNeedConstrains {
            viewsNeedConstrains = !viewsNeedConstrains
            
            /* Set title hugging and compression*/
            title.setContentHuggingPriority(.required, for: .horizontal)
            title.setContentHuggingPriority(.required, for: .vertical)
            title.setContentCompressionResistancePriority(.required, for: .horizontal)
            title.setContentCompressionResistancePriority(.required, for: .vertical)
            
            /* Set imgView hugging and compression*/
            imgView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
            imgView.setContentHuggingPriority(.defaultHigh, for: .vertical)
            imgView.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
            imgView.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
            
            let margins = safeAreaLayoutGuide
            
            /* Set stackView constraints*/
            vStackView.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: LayoutConstants.leading).isActive = true
            vStackView.topAnchor.constraint(equalTo: margins.topAnchor, constant: LayoutConstants.top).isActive = true
            vStackView.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: LayoutConstants.bottom).isActive = true
            vStackView.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: LayoutConstants.trailing).isActive = true
        }
        super.updateConstraints()
    }
    
    
    // MARK: Views on screen
    private var vStackView : UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        return stackView
    }()
    
    private var title : UILabel = {
        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.numberOfLines = 0
        title.textAlignment = .left
        title.font = UIFont.boldSystemFont(ofSize: 18)
        title.textColor = UIColor.orange
        return title
    }()
    
    private var imgView : UIImageView = {
        let imgView = UIImageView()
        imgView.translatesAutoresizingMaskIntoConstraints = false
        imgView.backgroundColor = UIColor.black
        imgView.contentMode = .scaleAspectFit
        return imgView
    }()
    
    // MARK: Private
    
    private var viewsNeedConstrains = true
    
    private struct LayoutConstants {
        static let leading = CGFloat(8.0)
        static let trailing = CGFloat(-8.0)
        static let top = CGFloat(8.0)
        static let bottom = CGFloat(-8.0)
    }
    
}
