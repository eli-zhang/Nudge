//
//  ChooseNameView.swift
//  Nudge
//
//  Created by Eli Zhang on 1/23/22.
//

import Foundation
import UIKit

class ChooseNameView: UIView {
    var namePrompt: UILabel!
    var nameEntryView: NameEntryView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .clear
        
        namePrompt = UILabel()
        namePrompt.text = "Hi, my name is..."
        namePrompt.font = UIFont(name: "OpenSans-Semibold", size: 18)
        namePrompt.textColor = .white
        addSubview(namePrompt)
        
        nameEntryView = NameEntryView()
        addSubview(nameEntryView)
        
        setUpConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpConstraints() {
        namePrompt.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(self)
        }
        nameEntryView.snp.makeConstraints { make in
            make.top.equalTo(namePrompt.snp.bottom).offset(15)
            make.leading.trailing.equalTo(self)
            make.bottom.equalTo(self)
        }
    }
}
