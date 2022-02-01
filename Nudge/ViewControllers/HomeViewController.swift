//
//  HomeViewController.swift
//  Nudge
//
//  Created by Eli Zhang on 1/14/22.
//

import UIKit
import Combine
import SnapKit

class HomeViewController: UIViewController {
    
    var savedNudgesLabel: UILabel!
    var showAllLabel: UILabel!
    var nudgeTable: UITableView!
    var divider: UIView!
    var menuStack: UIStackView!
    var addNudgeButton: MenuButton!
    var addFriendButton: MenuButton!
    var settingsButton: MenuButton!
    
    var user: UserPopulated?
    var nudges: [NudgePopulated] = []
    var getUserCancellable: AnyCancellable?
    var pingNudgeCancellable: AnyCancellable?
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
        addNudgeButton.addTarget(self, action: #selector(pushNudgeController), for: .touchUpInside)
        addFriendButton = MenuButton()
        addFriendButton.configure(buttonType: .addFriend)
        addFriendButton.addTarget(self, action: #selector(pushFriendController), for: .touchUpInside)
        
        settingsButton = MenuButton()
        settingsButton.configure(buttonType: .settings)
        view.addSubview(settingsButton)

        menuStack = UIStackView()
        menuStack.axis = .horizontal
        menuStack.distribution = .fillProportionally
        menuStack.spacing = 15
        menuStack.addArrangedSubview(addNudgeButton)
        menuStack.addArrangedSubview(addFriendButton)
        view.addSubview(menuStack)
        
        divider = UIView()
        divider.backgroundColor = Colors.almostOpaqueWhite
        view.addSubview(divider)
        
        savedNudgesLabel.alpha = 0
        showAllLabel.alpha = 0
        nudgeTable.alpha = 0
        divider.alpha = 0
        settingsButton.alpha = 0
        menuStack.alpha = 0
        settingsButton.alpha = 0

        
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
                    self.user = userInfo
                    self.nudges = userInfo.nudges
                    let nudgesShown = min(self.nudgeButtonCount, self.nudges.count)
                    self.nudgeTable.reloadData()
                    self.nudgeTable.snp.updateConstraints { make in
                        make.leading.trailing.equalTo(self.view)
                        make.centerY.equalTo(self.view).offset(-30)
                        make.height.equalTo((self.nudgeButtonHeight + self.nudgeButtonSpacing) * nudgesShown + 10)
                    }
                    if self.nudges.isEmpty {
                        self.showMenuButton()
                    } else {
                        self.showNudgeInfo()
                    }
                }
            )
        

        setUpConstraints()
    }
        
    func setUpConstraints() {
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
        settingsButton.snp.makeConstraints { make in
            make.top.equalTo(divider.snp.bottom).offset(20)
            make.trailing.equalTo(view).inset(buttonPadding)
            make.height.width.equalTo(70)
        }
        menuStack.snp.makeConstraints { make in
            make.top.equalTo(divider.snp.bottom).offset(20)
            make.leading.equalTo(view).inset(buttonPadding)
            make.trailing.equalTo(settingsButton.snp.leading).offset(-15)
            make.height.equalTo(70)
        }
    }
    
    @objc func pushNudgeController() {
        let newNudgeController = NewNudgeController(user: self.user)
        navigationController?.pushViewController(newNudgeController, animated: true)
    }
    
    @objc func pushFriendController() {
        let friendViewController = FriendController(user: self.user)
        navigationController?.pushViewController(friendViewController, animated: true)
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
        cell.nudgeButton.tag = indexPath.row
        cell.nudgeButton.delegate = self
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
    
    func showMenuButton() {
        settingsButton.snp.makeConstraints { make in
            make.centerY.equalTo(view)
            make.trailing.equalTo(view).inset(buttonPadding)
            make.height.width.equalTo(70)
        }
        menuStack.snp.makeConstraints { make in
            make.centerY.equalTo(view)
            make.leading.equalTo(view).inset(buttonPadding)
            make.trailing.equalTo(settingsButton.snp.leading).offset(-15)
            make.height.equalTo(70)
        }
        
        UIView.animate(withDuration: 0.3, animations: {
            self.settingsButton.alpha = 1
            self.menuStack.alpha = 1
            self.settingsButton.alpha = 1
        })
    }
    
    func showNudgeInfo() {
        UIView.animate(withDuration: 0.3, animations: {
            self.savedNudgesLabel.alpha = 1
            self.showAllLabel.alpha = 1
            self.nudgeTable.alpha = 1
            self.divider.alpha = 1
            self.settingsButton.alpha = 1
            self.menuStack.alpha = 1
            self.settingsButton.alpha = 1
        })
    }
}

extension HomeViewController: PingNudgeDelegate {
    func pingNudge(index: Int) {
        let nudgeId = nudges[index]._id
        pingNudgeCancellable = NetworkManager.pingNudge(nudgeId: nudgeId)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                        case .failure(let error): print("Error: \(error)")
                        case .finished: print("Successfully pinged nudge.")
                    }
                },
                receiveValue: { [weak self] _ in
                    guard let self = self else { return }
                    self.dismissKeyboard()
                }
            )
    }
}
