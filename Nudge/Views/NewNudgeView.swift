//
//  NewNudgeView.swift
//  Nudge
//
//  Created by Eli Zhang on 1/30/22.
//

import UIKit
import SnapKit

class NewNudgeView: UIView {
    var containerView: UIView!
    var textField: UITextField!
    var nudgeImage: UIImage!
    var nudgeIcon: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 10
        
        containerView = UIView()
        containerView.isUserInteractionEnabled = false
        containerView.backgroundColor = Colors.transpGray
        containerView.layer.cornerRadius = 10
        containerView.layer.shadowColor = Colors.shadowColor.cgColor
        containerView.layer.shadowOpacity = 1
        containerView.layer.shadowOffset = CGSize(width: 3, height: 4)
        containerView.layer.shadowRadius = 2
        addSubview(containerView)

        nudgeImage = UIImage(named: "NudgeIconBlack")
        nudgeIcon = UIImageView(image: nudgeImage)
        nudgeIcon.isUserInteractionEnabled = false
        addSubview(nudgeIcon)
        
        textField = UITextField()
        textField.attributedPlaceholder = NSAttributedString(
            string: "Write a message...",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white]
        )
        textField.textColor = .white
        textField.font = UIFont(name: "OpenSans-Regular", size: 15)
        addSubview(textField)
        
        backgroundColor = Colors.pink2
        
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
        textField.snp.makeConstraints { make in
            make.leading.trailing.equalTo(containerView).inset(15)
            make.centerY.equalTo(containerView)
        }
        nudgeIcon.snp.makeConstraints { make in
            make.trailing.equalTo(self).inset(10)
            make.height.width.equalTo(55)
            make.centerY.equalTo(self).offset(-2) // The icon is not perfectly visually centered
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
