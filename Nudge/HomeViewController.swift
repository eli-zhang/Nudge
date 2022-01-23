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
    var chooseNameView: ChooseNameView!
    var divider: UIView!
    var menuStack: UIStackView!
    var addNudgeButton: MenuButton!
    var addFriendButton: MenuButton!
    var settingsButton: MenuButton!
    
    var nudges: [NudgePopulated] = []
    var getUserCancellable: AnyCancellable?
    var updateUserCancellable: AnyCancellable?
    let reuseIdentifier = "nudgeButtonReuseIdentifier"
    
    let buttonPadding = 30
    let nudgeButtonHeight = 80
    let nudgeButtonSpacing = 20
    let nudgeButtonCount = 3
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(patternImage: UIImage(named: "Background.png")!)
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))

        view.addGestureRecognizer(tap)
        
        chooseNameView = ChooseNameView()
        chooseNameView.isHidden = true
        chooseNameView.nameEntryView.delegate = self
        view.addSubview(chooseNameView)
        
        savedNudgesLabel = UILabel()
        savedNudgesLabel.isHidden = true
        savedNudgesLabel.text = "Saved Nudges"
        savedNudgesLabel.font = UIFont(name: "OpenSans-Bold", size: 15)
        savedNudgesLabel.textColor = Colors.almostOpaqueWhite
        view.addSubview(savedNudgesLabel)
        
        showAllLabel = UILabel()
        showAllLabel.isHidden = true
        showAllLabel.text = "Show All"
        showAllLabel.font = UIFont(name: "OpenSans-Regular", size: 15)
        showAllLabel.textAlignment = .right
        showAllLabel.textColor = Colors.almostOpaqueWhite
        view.addSubview(showAllLabel)
        
        nudgeTable = UITableView()
        nudgeTable.isHidden = true
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
        menuStack.isHidden = true
        menuStack.axis = .horizontal
        menuStack.distribution = .fillProportionally
        menuStack.spacing = 15
        menuStack.addArrangedSubview(addNudgeButton)
        menuStack.addArrangedSubview(addFriendButton)
        menuStack.addArrangedSubview(settingsButton)
        view.addSubview(menuStack)
        
        divider = UIView()
        divider.isHidden = true
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
                    if userInfo.name == nil {
                        self.showNameConfigure()
                    } else {
                        self.showNudgeInfo()
                    }
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
        chooseNameView.snp.makeConstraints { make in
            make.leading.trailing.equalTo(view).inset(buttonPadding)
            make.bottom.equalTo(view.snp.centerY)
            make.height.equalTo(115)
        }
        savedNudgesLabel.snp.makeConstraints { make in
            make.leading.equalTo(view).inset(buttonPadding)
            make.bottom.equalTo(nudgeTable.snp.top)
        }
        showAllLabel.snp.makeConstraints { make in
            make.trailing.equalTo(view).inset(buttonPadding)
            make.bottom.equalTo(savedNudgesLabel)
        }
        nudgeTable.snp.makeConstraints { make in
            make.leading.trailing.equalTo(view).inset(buttonPadding)
            make.centerY.equalTo(view).offset(-30)
            make.height.equalTo(0)
        }
        divider.snp.makeConstraints { make in
            make.leading.trailing.equalTo(view).inset(buttonPadding)
            make.top.equalTo(nudgeTable.snp.bottom).offset(20)
            make.height.equalTo(1)
        }
        menuStack.snp.makeConstraints { make in
            make.top.equalTo(divider.snp.bottom).offset(20)
            make.leading.trailing.equalTo(view).inset(buttonPadding)
            make.height.equalTo(70)
        }
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
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
        
        let group = nudge.assignedGroup?.name ?? getFriendsListFromNudge(assignedFriends: nudge.assignedFriends)
        cell.configure(color: color, description: nudge.message, group: group, status: .inactive)
        return cell
    }
    
    func getFriendsListFromNudge(assignedFriends: [User]?) -> String {
        guard let assignedFriends = assignedFriends else { return "No recipients specified" }
        let friendNames = assignedFriends.compactMap { $0.name }
        switch assignedFriends.count {
            case 0:
                return "No recipients specified"
            case 1:
                return friendNames[0]
            case 2:
                return "\(friendNames[0]) & \(friendNames[1])"
            case 3:
                return "\(friendNames[0]), \(friendNames[1]) & \(friendNames[2])"
            default:
                return "\(friendNames[0]), \(friendNames[1]) & \(friendNames.count - 2) more"
        }
    }
}


extension HomeViewController: SubmitNameDelegate {
    func submitName(name: String) {
        updateUserCancellable = NetworkManager.updateUserInfo(name: name)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                        case .failure(let error): print("Error: \(error)")
                        case .finished: print("Successfully updated user info.")
                    }
                },
                receiveValue: { [weak self] _ in
                    guard let self = self else { return }
                    self.showNudgeInfo()
                    self.dismissKeyboard()
                }
            )
    }
    
    func showNameConfigure() {
        self.chooseNameView.alpha = 0
        self.savedNudgesLabel.isHidden = true
        self.showAllLabel.isHidden = true
        self.nudgeTable.isHidden = true
        self.divider.isHidden = true
        self.menuStack.isHidden = true
        self.addNudgeButton.isHidden = true
        self.addFriendButton.isHidden = true
        self.settingsButton.isHidden = true
        UIView.animate(withDuration: 0.3, animations: {
            self.chooseNameView.isHidden = false
            self.chooseNameView.alpha = 1
        })
    }
    
    func showNudgeInfo() {
        self.chooseNameView.isHidden = true
        self.savedNudgesLabel.isHidden = false
        self.showAllLabel.isHidden = false
        self.nudgeTable.isHidden = false
        self.divider.isHidden = false
        self.menuStack.isHidden = false
        self.addNudgeButton.isHidden = false
        self.addFriendButton.isHidden = false
        self.settingsButton.isHidden = false
        self.savedNudgesLabel.alpha = 0
        self.showAllLabel.alpha = 0
        self.nudgeTable.alpha = 0
        self.divider.alpha = 0
        self.menuStack.alpha = 0
        self.addNudgeButton.alpha = 0
        self.addFriendButton.alpha = 0
        self.settingsButton.alpha = 0
        UIView.animate(withDuration: 0.3, animations: {
            self.savedNudgesLabel.alpha = 1
            self.showAllLabel.alpha = 1
            self.nudgeTable.alpha = 1
            self.divider.alpha = 1
            self.menuStack.alpha = 1
            self.addNudgeButton.alpha = 1
            self.addFriendButton.alpha = 1
            self.settingsButton.alpha = 1
        })
    }
}
