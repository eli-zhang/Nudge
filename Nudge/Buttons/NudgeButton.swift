//
//  NudgeButton.swift
//  Nudge
//
//  Created by Eli Zhang on 1/14/22.
//

import UIKit
import SnapKit

class NudgeButton: UIButton {
    var containerView: UIView!
    var descriptionLabel: UILabel!
    var groupLabel: UILabel!
    var nudgeImage: UIImage!
    var nudgeIcon: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        translatesAutoresizingMaskIntoConstraints = false
        
        layer.cornerRadius = 10
        
        containerView = UIView()
        containerView.backgroundColor = Colors.transpGray
        containerView.layer.cornerRadius = 10
        containerView.layer.shadowColor = Colors.shadowColor.cgColor
        containerView.layer.shadowOpacity = 1
        containerView.layer.shadowOffset = CGSize(width: 3, height: 4)
        containerView.layer.shadowRadius = 2

        nudgeImage = UIImage(named: "NudgeIconBlack")
        nudgeIcon = UIImageView(image: nudgeImage)
        
        addSubview(containerView)
        addSubview(nudgeIcon)
        descriptionLabel = UILabel()
        descriptionLabel.textColor = .white
        descriptionLabel.font = UIFont(name: "OpenSans-Regular", size: 15)
        
        groupLabel = UILabel()
        groupLabel.font = UIFont(name: "OpenSans-Bold", size: 10)
        groupLabel.textColor = .white
        addSubview(descriptionLabel)
        addSubview(groupLabel)
        
        self.layer.shadowColor = Colors.shadowColor.cgColor
        self.layer.shadowOpacity = 1
        self.layer.shadowOffset = CGSize(width: 3, height: 4)
        self.layer.shadowRadius = 2
        
        setUpConstraints()
    }
    
    func setUpConstraints() {
        containerView.snp.makeConstraints { make in
            make.leading.top.bottom.equalTo(self).inset(10)
            make.trailing.equalTo(nudgeIcon.snp.leading).offset(-10)
        }
        descriptionLabel.snp.makeConstraints { make in
            make.leading.trailing.equalTo(containerView).inset(10)
            make.centerY.equalTo(containerView).offset(-8)
        }
        groupLabel.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(2)
            make.leading.trailing.equalTo(containerView).inset(10)
        }
        nudgeIcon.snp.makeConstraints { make in
            make.trailing.equalTo(self).inset(10)
            make.height.width.equalTo(55)
            make.centerY.equalTo(self).offset(-2) // The icon is not perfectly visually centered
        }
    }
    
    func configure(color: UIColor, description: String, group: String, status: NudgeStatus) {
        backgroundColor = color
        descriptionLabel.text = description
        groupLabel.text = group
        switch status {
        case .inactive:
            nudgeImage = UIImage(named: "NudgeIconBlack")
        case .pending:
            nudgeImage = UIImage(named: "NudgeIconWhite")
        case .accepted:
            nudgeImage = UIImage(named: "NudgeIconBlue")
        case .rejected:
            nudgeImage = UIImage(named: "NudgeIconRed")
        }
        nudgeIcon.image = nudgeImage
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

enum NudgeStatus {
    case inactive
    case pending
    case accepted
    case rejected
}
