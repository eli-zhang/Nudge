//
//  UserDefaultProfileView.swift
//  Nudge
//
//  Created by Eli Zhang on 1/25/22.
//

import Foundation
import UIKit

enum ColorType {
    case white
    case black
    case blue
    case red
    case purple
    
    func toString() -> String {
        switch(self) {
        case .white:
            return "WHITE"
        case .black:
            return "BLACK"
        case .blue:
            return "BLUE"
        case .red:
            return "RED"
        case .purple:
            return "PURPLE"
        }
    }
    
    func stringToColor(string: String) -> ColorType {
        switch(string) {
        case "WHITE":
            return .white
        case "BLACK":
            return .black
        case "BLUE":
            return .blue
        case "RED":
            return .red
        case "PURPLE":
            return .purple
        default:
            return .white
        }
    }
}

class UserDefaultProfileView: UIView {
    var letterLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.cornerRadius = 16

        letterLabel = UILabel()
        letterLabel.font = UIFont(name: "OpenSans-Bold", size: 18)
        letterLabel.textAlignment = .center
        addSubview(letterLabel)
        
        setUpConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpConstraints() {
        letterLabel.snp.makeConstraints { make in
            make.center.equalTo(self)
        }
    }
    
    func configure(name: String, colorType: ColorType) {
        UIView.animate(withDuration: 0.3, animations: {
            switch colorType {
            case .white:
                self.backgroundColor = .white
                self.letterLabel.textColor = Colors.brown
            case .black:
                self.backgroundColor = Colors.gray
                self.letterLabel.textColor = .white
            case .blue:
                self.backgroundColor = Colors.blue
                self.letterLabel.textColor = .white
            case .red:
                self.backgroundColor = Colors.red
                self.letterLabel.textColor = .white
            case .purple:
                self.backgroundColor = Colors.richPurple
                self.letterLabel.textColor = .white
            }
        })
        
        
        letterLabel.text = String(name.prefix(1).uppercased())
    }
}

