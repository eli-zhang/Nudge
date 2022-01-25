//
//  ContainerActionButton.swift
//  Nudge
//
//  Created by Eli Zhang on 1/23/22.
//

import UIKit

class ContainerActionView: UIView {
    
    var containerView: UIView!
    var textField: UITextField!
    var actionButton: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 10
        
        backgroundColor = Colors.pink2
        
        containerView = UIView()
        containerView.backgroundColor = Colors.transpGray
        containerView.layer.cornerRadius = 10
        containerView.layer.shadowColor = Colors.shadowColor.cgColor
        containerView.layer.shadowOpacity = 1
        containerView.layer.shadowOffset = CGSize(width: 3, height: 4)
        containerView.layer.shadowRadius = 2
        addSubview(containerView)
        
        textField = UITextField()
        textField.attributedPlaceholder = NSAttributedString(
            string: "Tap here to enter a name.",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white]
        )
        textField.textColor = .white
        textField.font = UIFont(name: "OpenSans-Regular", size: 15)
        addSubview(textField)
        
        actionButton = UIButton()
        actionButton.backgroundColor = Colors.offWhite
        actionButton.layer.cornerRadius = 10
        actionButton.layer.shadowColor = Colors.shadowColor.cgColor
        actionButton.layer.shadowOpacity = 0.5
        actionButton.layer.shadowOffset = CGSize(width: 3, height: 4)
        actionButton.layer.shadowRadius = 2
        addSubview(actionButton)
        
        self.layer.shadowColor = Colors.shadowColor.cgColor
        self.layer.shadowOpacity = 1
        self.layer.shadowOffset = CGSize(width: 3, height: 4)
        self.layer.shadowRadius = 2
        
        setUpConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpConstraints() {
        containerView.snp.makeConstraints { make in
            make.leading.top.bottom.equalTo(self).inset(10)
            make.trailing.equalTo(actionButton.snp.leading).offset(-15)
        }
        actionButton.snp.makeConstraints { make in
            make.width.height.equalTo(45)
            make.trailing.equalTo(self).offset(-15)
            make.centerY.equalTo(containerView)
        }
        textField.snp.makeConstraints { make in
            make.edges.equalTo(containerView).inset(15)
        }
    }
}
