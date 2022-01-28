//
//  NudgeButtonTableCell.swift
//  Nudge
//
//  Created by Eli Zhang on 1/22/22.
//

import UIKit
import SnapKit

class NudgeButtonTableCell: UITableViewCell {
    var nudgeButton: NudgeButton!
    let nudgeButtonSpacing = 20
    let buttonPadding = 30

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = .clear
        backgroundColor = .clear
        
        nudgeButton = NudgeButton()
        contentView.addSubview(nudgeButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateConstraints() {
        nudgeButton.snp.makeConstraints { make in
            make.bottom.equalTo(contentView)
            make.leading.trailing.equalTo(contentView).inset(buttonPadding)
            make.top.equalTo(contentView).inset(nudgeButtonSpacing)
        }
        super.updateConstraints()
    }
    
    func configure(color: UIColor, description: String, group: String, status: NudgeStatus) {
        nudgeButton.configure(color: color, description: description, group: group, status: status)
    }
}
