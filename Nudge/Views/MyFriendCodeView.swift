//
//  FriendCodeView.swift
//  Nudge
//
//  Created by Eli Zhang on 1/23/22.
//

import Foundation
import UIKit

protocol FinishCopyingDelegate: AnyObject {
    func finishCopying()
}

class MyFriendCodeView: ContainerActionView {
    
    weak var delegate: FinishCopyingDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        textField.isUserInteractionEnabled = false
        textField.text = "Loading friend code..."
        
        actionButton.setImage(UIImage(named: "Copy"), for: .normal)
        actionButton.addTarget(self, action: #selector(copyCode), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(friendCode: String) {
        textField.text = friendCode
    }

    @objc func copyCode() {
        UIPasteboard.general.string = textField.text
        delegate?.finishCopying()
    }
}
