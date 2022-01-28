//
//  UserPillView.swift
//  Nudge
//
//  Created by Eli Zhang on 1/25/22.
//

import Foundation
import UIKit

class UserPillView: UIView {
    var profilePictureView: UserDefaultProfileView!
    var containerView: UIView!
    var userNameLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = Colors.purple1
        layer.cornerRadius = 15

        profilePictureView = UserDefaultProfileView()
        addSubview(profilePictureView)
        
        containerView = UIView()
        containerView.backgroundColor = Colors.transpGray
        containerView.layer.cornerRadius = 10
        containerView.layer.shadowColor = Colors.shadowColor.cgColor
        containerView.layer.shadowOpacity = 1
        containerView.layer.shadowOffset = CGSize(width: 3, height: 4)
        containerView.layer.shadowRadius = 2
        addSubview(containerView)
        
        userNameLabel = UILabel()
        userNameLabel.font = UIFont(name: "OpenSans-Regular", size: 13)
        userNameLabel.textAlignment = .center
        userNameLabel.textColor = .white
        addSubview(userNameLabel)
        
        layer.shadowColor = Colors.shadowColor.cgColor
        layer.shadowOpacity = 1
        layer.shadowOffset = CGSize(width: 3, height: 4)
        layer.shadowRadius = 2
        
        setUpConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpConstraints() {
        profilePictureView.snp.makeConstraints { make in
            make.leading.top.bottom.equalTo(self).inset(9)
            make.width.equalTo(32)
        }
        containerView.snp.makeConstraints { make in
            make.leading.equalTo(profilePictureView.snp.trailing).offset(8)
            make.top.bottom.trailing.equalTo(self).inset(9)
        }
        userNameLabel.snp.makeConstraints { make in
            make.edges.equalTo(containerView).inset(8)
        }
    }
    
    func configure(name: String, colorType: ColorType) {
        profilePictureView.configure(name: name, colorType: colorType)
        userNameLabel.text = name
    }
}
