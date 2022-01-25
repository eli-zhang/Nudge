//
//  UserColorCollectionViewCell.swift
//  Nudge
//
//  Created by Eli Zhang on 1/24/22.
//

import Foundation
import UIKit

class UserColorCollectionViewCell: UICollectionViewCell {
    
    var profilePictureView: UserDefaultProfileView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.cornerRadius = 15
        
        backgroundColor = Colors.purple1
        
        profilePictureView = UserDefaultProfileView()
        addSubview(profilePictureView)
        
        self.layer.shadowColor = Colors.shadowColor.cgColor
        self.layer.shadowOpacity = 1
        self.layer.shadowOffset = CGSize(width: 3, height: 4)
        self.layer.shadowRadius = 2
        
        setUpConstraints()
    }
    
    func setUpConstraints() {
        profilePictureView.snp.makeConstraints { make in
            make.edges.equalTo(self).inset(9)
        }
    }
    
    func configure(name: String, colorType: ColorType) {
        profilePictureView.configure(name: name, colorType: colorType)
    }
    
    override open var isSelected: Bool {
        didSet {
            if isSelected {
                self.layer.shadowColor = Colors.shadowColor.cgColor
                self.layer.shadowOpacity = 1
                self.layer.shadowOffset = CGSize(width: 1, height: 2)
                self.layer.shadowRadius = 1
            } else {
                self.layer.shadowColor = Colors.shadowColor.cgColor
                self.layer.shadowOpacity = 1
                self.layer.shadowOffset = CGSize(width: 3, height: 4)
                self.layer.shadowRadius = 2
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
