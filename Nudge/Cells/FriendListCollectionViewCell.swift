//
//  FriendListCollectionViewCell.swift
//  Nudge
//
//  Created by Eli Zhang on 1/25/22.
//

import UIKit
import SnapKit

class FriendListCollectionViewCell: UICollectionViewCell {
    
    var friendPillView: UserPillView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.backgroundColor = .clear
        
        friendPillView = UserPillView()
        addSubview(friendPillView)
        
        setUpConstraints()
    }
    
    func setUpConstraints() {
        friendPillView.snp.makeConstraints { make in
            make.edges.equalTo(contentView)
        }
    }
    
    func configure(name: String, colorType: ColorType) {
        friendPillView.configure(name: name, colorType: colorType)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
