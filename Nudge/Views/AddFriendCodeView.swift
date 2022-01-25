//
//  AddFriendCodeView.swift
//  Nudge
//
//  Created by Eli Zhang on 1/23/22.
//

import Foundation
import UIKit

protocol AddFriendDelegate: AnyObject {
    func addFriend(friendCode: String)
}

class AddFriendCodeView: ContainerActionView {

    weak var delegate: AddFriendDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        textField.placeholder = "Enter friend code..."
        textField.autocorrectionType = .no

        actionButton.setImage(UIImage(named: "Check"), for: .normal)
        actionButton.addTarget(self, action: #selector(addFriend), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
                                
    @objc func addFriend() {
        guard let friendCode = textField.text else {
            return
        }
        delegate?.addFriend(friendCode: friendCode)
    }
}

