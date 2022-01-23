//
//  NameEntryView.swift
//  Nudge
//
//  Created by Eli Zhang on 1/23/22.
//

import UIKit

protocol SubmitNameDelegate: AnyObject {
    func submitName(name: String)
}

class NameEntryView: UIView {
    
    var containerView: UIView!
    var nameEntryField: UITextField!
    var confirmButton: UIButton!
    weak var delegate: SubmitNameDelegate?
    
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
        
        nameEntryField = UITextField()
        nameEntryField.attributedPlaceholder = NSAttributedString(
            string: "Tap here to enter a name.",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white]
        )
        nameEntryField.textColor = .white
        nameEntryField.font = UIFont(name: "OpenSans-Regular", size: 15)
        addSubview(nameEntryField)
        
        confirmButton = UIButton()
        confirmButton.setImage(UIImage(named: "Check"), for: .normal)
        confirmButton.backgroundColor = Colors.offWhite
        confirmButton.layer.cornerRadius = 10
        confirmButton.layer.shadowColor = Colors.shadowColor.cgColor
        confirmButton.layer.shadowOpacity = 0.5
        confirmButton.layer.shadowOffset = CGSize(width: 3, height: 4)
        confirmButton.layer.shadowRadius = 2
        confirmButton.addTarget(self, action: #selector(confirmName), for: .touchUpInside)
        addSubview(confirmButton)
        
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
            make.trailing.equalTo(confirmButton.snp.leading).offset(-15)
        }
        confirmButton.snp.makeConstraints { make in
            make.width.height.equalTo(45)
            make.trailing.equalTo(self).offset(-15)
            make.centerY.equalTo(containerView)
        }
        nameEntryField.snp.makeConstraints { make in
            make.edges.equalTo(containerView).inset(15)
        }
    }
                                
    @objc func confirmName() {
        delegate?.submitName(name: nameEntryField.text ?? "")
    }
}
