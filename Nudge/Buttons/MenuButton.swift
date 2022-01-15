//
//  MenuButton.swift
//  Nudge
//
//  Created by Eli Zhang on 1/15/22.
//

import UIKit
import SnapKit

class MenuButton: UIButton {
    var image: UIImage!
    var icon: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.cornerRadius = 10
        
        image = UIImage(named: "NudgeIconBlack")
        icon = UIImageView(image: image)
        icon.contentMode = .scaleAspectFit
        
        addSubview(icon)
        
        self.layer.shadowColor = Colors.shadowColor.cgColor
        self.layer.shadowOpacity = 1
        self.layer.shadowOffset = CGSize(width: 3, height: 4)
        self.layer.shadowRadius = 2
        
        setUpConstraints()
    }
    
    func setUpConstraints() {
        icon.snp.makeConstraints { make in
            make.width.equalTo(90)
            make.height.equalTo(55)
            make.edges.equalTo(self).inset(10)
        }
    }
    
    func configure(buttonType: MenuType) {
        switch buttonType {
        case .addNudge:
            image = UIImage(named: "PlusNudge")
            backgroundColor = Colors.purple1
        case .addFriend:
            image = UIImage(named: "PlusGroup")
            backgroundColor = Colors.purple2
        case .settings:
            image = UIImage(named: "Settings")
            backgroundColor = Colors.purple3
            icon.snp.remakeConstraints { make in
                make.center.equalTo(self)
                make.width.equalTo(41)
                make.height.equalTo(41)
            }
        }
        icon.image = image
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

enum MenuType {
    case addNudge
    case addFriend
    case settings
}
