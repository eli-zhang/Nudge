//
//  ProfilePictureCollectionViewCell.swift
//  Nudge
//
//  Created by Eli Zhang on 1/27/22.
//

import Foundation
import UIKit

class ProfilePictureCollectionViewCell: UICollectionViewCell {
    
    var profilePictureView: UserDefaultProfileView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        profilePictureView = UserDefaultProfileView()
        addSubview(profilePictureView)
        
        setUpConstraints()
    }
    
    func setUpConstraints() {
        profilePictureView.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }
    }
    
    func configure(name: String, colorType: ColorType) {
        profilePictureView.configure(name: name, colorType: colorType)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
