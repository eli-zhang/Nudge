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

class NameEntryView: ContainerActionView {

    weak var delegate: SubmitNameDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        actionButton.setImage(UIImage(named: "Check"), for: .normal)
        actionButton.addTarget(self, action: #selector(confirmName), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
                                
    @objc func confirmName() {
        delegate?.submitName(name: textField.text ?? "")
    }
}
