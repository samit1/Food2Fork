//
//  TitleView.swift
//  Food2Fork
//
//  Created by Sami Taha on 7/18/18.
//  Copyright © 2018 Sami Taha. All rights reserved.
//

import UIKit

class TitleView: UIView {

    // MARK: Public methods
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(title)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View lifecycle methods
    
    override func updateConstraints() {
        if viewsNeedConstraints {
            viewsNeedConstraints = !viewsNeedConstraints
            
            /* Set hugging and compression priorities */
            title.setContentHuggingPriority(.required, for: .horizontal)
            title.setContentHuggingPriority(.required, for: .vertical)
            title.setContentCompressionResistancePriority(.required, for: .horizontal)
            title.setContentCompressionResistancePriority(.required, for: .vertical)
            
            let margins = safeAreaLayoutGuide
            
            /* Set title constraints */
            title.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: LayoutConstants.leading).isActive = true
            title.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: LayoutConstants.trailing).isActive = true
            title.topAnchor.constraint(equalTo: margins.topAnchor, constant: LayoutConstants.top).isActive = true
            title.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: LayoutConstants.bottom).isActive = true
        }
        
        super.updateConstraints()
    }
    
    /// - parameter text: The text to display
    func configureLabel(_ text: String) {
        title.text = text
    }
    
    // MARK: Private 
    private let title : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = UIFont.boldSystemFont(ofSize: 36)
        label.textAlignment = .left
        return label
    }()
    
    private var viewsNeedConstraints = true
    
    private struct LayoutConstants {
        static let leading = CGFloat(8.0)
        static let trailing = CGFloat(-8.0)
        static let top = CGFloat(8.0)
        static let bottom = CGFloat(-8.0)
    }
    
}
