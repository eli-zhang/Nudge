//
//  SearchBarView.swift
//  Nudge
//
//  Created by Eli Zhang on 1/28/22.
//

import Foundation
import UIKit

class SearchBarView: UIView {
    var searchField: UITextField!
    var searchImage: UIImage!
    var searchIcon: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = Colors.transpGray
        
        layer.cornerRadius = 10
        
        searchField = UITextField()
        searchField.attributedPlaceholder = NSAttributedString(
            string: "Search your friends...",
            attributes: [NSAttributedString.Key.foregroundColor: Colors.almostOpaqueWhite]
        )
        searchField.textColor = Colors.almostOpaqueWhite
        searchField.font = UIFont(name: "OpenSans-Regular", size: 13)
        addSubview(searchField)
        
        searchImage = UIImage(named: "Search")
        searchIcon = UIImageView(image: searchImage)
        addSubview(searchIcon)
        
        setUpConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpConstraints() {
        searchField.snp.makeConstraints { make in
            make.top.leading.equalTo(self).inset(10)
            make.trailing.equalTo(searchIcon.snp.leading).offset(-5)
        }
        searchIcon.snp.makeConstraints { make in
            make.trailing.equalTo(self).inset(10)
            make.centerY.equalTo(self)
            make.height.width.equalTo(21)
        }
    }
}
