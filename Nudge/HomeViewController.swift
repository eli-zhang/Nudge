//
//  HomeViewController.swift
//  Nudge
//
//  Created by Eli Zhang on 1/14/22.
//

import UIKit
import Combine
import SnapKit

struct NudgeInfo {
    
}

class HomeViewController: UIViewController {
    
    var savedNudgesLabel: UILabel!
    var showAllLabel: UILabel!
    var nudgeTable: UITableView!
    var divider: UIView!
    var menuStack: UIStackView!
    var addNudgeButton: MenuButton!
    var addFriendButton: MenuButton!
    var settingsButton: MenuButton!
    
    var nudges: [Nudge] = []
    var getUserCancellable: AnyCancellable?
    let reuseIdentifier = "nudgeButtonReuseIdentifier"
    
    let buttonPadding = 30
    let nudgeButtonHeight = 80
    let nudgeButtonSpacing = 20
    let nudgeButtonCount = 3
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(patternImage: UIImage(named: "Background.png")!)
        
        savedNudgesLabel = UILabel()
        savedNudgesLabel.text = "Saved Nudges"
        savedNudgesLabel.font = UIFont(name: "OpenSans-Bold", size: 15)
        savedNudgesLabel.textColor = Colors.almostOpaqueWhite
        view.addSubview(savedNudgesLabel)
        
        showAllLabel = UILabel()
        showAllLabel.text = "Show All"
        showAllLabel.font = UIFont(name: "OpenSans-Regular", size: 15)
        showAllLabel.textAlignment = .right
        showAllLabel.textColor = Colors.almostOpaqueWhite
        view.addSubview(showAllLabel)
        
        nudgeTable = UITableView()
        nudgeTable.backgroundColor = .clear
        nudgeTable.dataSource = self
        nudgeTable.delegate = self
        nudgeTable.isScrollEnabled = false
        nudgeTable.register(NudgeButtonTableCell.self, forCellReuseIdentifier: reuseIdentifier)
        view.addSubview(nudgeTable)
        
        addNudgeButton = MenuButton()
        addNudgeButton.configure(buttonType: .addNudge)
        addFriendButton = MenuButton()
        addFriendButton.configure(buttonType: .addFriend)
        settingsButton = MenuButton()
        settingsButton.configure(buttonType: .settings)

        menuStack = UIStackView()
        menuStack.axis = .horizontal
        menuStack.distribution = .fillProportionally
        menuStack.spacing = 15
        menuStack.addArrangedSubview(addNudgeButton)
        menuStack.addArrangedSubview(addFriendButton)
        menuStack.addArrangedSubview(settingsButton)
        view.addSubview(menuStack)
        
        divider = UIView()
        divider.backgroundColor = Colors.almostOpaqueWhite
        view.addSubview(divider)
        
        getUserCancellable = NetworkManager.getUserInfo()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                        case .failure(let error): print("Error: \(error)")
                        case .finished: print("Successfully fetched user info.")
                    }
                },
                receiveValue: { [weak self] userInfo in
                    guard let self = self else { return }
                    self.nudges = userInfo.nudges
                    let nudgesShown = min(self.nudgeButtonCount, self.nudges.count)
                    self.nudgeTable.reloadData()
                    self.nudgeTable.snp.updateConstraints { make in
                        make.leading.trailing.equalTo(self.view)
                        make.centerY.equalTo(self.view).offset(-30)
                        make.height.equalTo((self.nudgeButtonHeight + self.nudgeButtonSpacing) * nudgesShown + 10)
                    }
                }
            )
        

        setUpConstraints()
    }
        
    func setUpConstraints() {
        savedNudgesLabel.snp.makeConstraints { make in
            make.leading.equalTo(nudgeTable).offset(buttonPadding)
            make.bottom.equalTo(nudgeTable.snp.top)
        }
        showAllLabel.snp.makeConstraints { make in
            make.trailing.equalTo(nudgeTable).offset(-buttonPadding)
            make.bottom.equalTo(savedNudgesLabel)
        }
        nudgeTable.snp.makeConstraints { make in
            make.leading.trailing.equalTo(view).inset(buttonPadding)
            make.centerY.equalTo(view).offset(-30)
            make.height.equalTo(0)
        }
        divider.snp.makeConstraints { make in
            make.leading.trailing.equalTo(nudgeTable).inset(buttonPadding)
            make.top.equalTo(nudgeTable.snp.bottom).offset(20)
            make.height.equalTo(1)
        }
        menuStack.snp.makeConstraints { make in
            make.top.equalTo(divider.snp.bottom).offset(20)
            make.leading.trailing.equalTo(nudgeTable).inset(buttonPadding)
            make.height.equalTo(70)
        }
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(nudgeButtonHeight + nudgeButtonSpacing)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        min(nudgeButtonCount, nudges.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! NudgeButtonTableCell
        cell.setNeedsUpdateConstraints()
        let nudge = nudges[indexPath.row]
        var color: UIColor
        switch indexPath.row {
        case 0: color = Colors.pink1
        case 1: color = Colors.pink2
        case 2: color = Colors.pink3
        default: color = Colors.pink3
        }
        cell.configure(color: color, description: nudge.message, group: "placeholder", status: .inactive)
        return cell
    }
    
    
}
