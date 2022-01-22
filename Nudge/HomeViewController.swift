//
//  HomeViewController.swift
//  Nudge
//
//  Created by Eli Zhang on 1/14/22.
//

import UIKit
import Combine

class HomeViewController: UIViewController {
    var savedNudgesLabel: UILabel!
    var showAllLabel: UILabel!
    var nudgeButtonStack: UIStackView!
    var nudgeButton1: NudgeButton!
    var nudgeButton2: NudgeButton!
    var nudgeButton3: NudgeButton!
    var divider: UIView!
    var menuStack: UIStackView!
    var addNudgeButton: MenuButton!
    var addFriendButton: MenuButton!
    var settingsButton: MenuButton!
    
    var getUserCancellable: AnyCancellable?
    
    let buttonPadding = 30
    
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
        
        nudgeButton1 = NudgeButton()
        nudgeButton1.configure(color: Colors.pink1, description: "want to eat food", group: "hungry gang", status: .inactive)
        nudgeButton2 = NudgeButton()
        nudgeButton2.configure(color: Colors.pink2, description: "let me innnnn", group: "blu doorbell", status: .accepted)

        nudgeButton3 = NudgeButton()
        nudgeButton3.configure(color: Colors.pink3, description: "im sleeping", group: "blu", status: .rejected)
        
        nudgeButtonStack = UIStackView()
        nudgeButtonStack.axis = .vertical
        nudgeButtonStack.distribution = .fillProportionally
        nudgeButtonStack.spacing = 20
        nudgeButtonStack.addArrangedSubview(nudgeButton1)
        nudgeButtonStack.addArrangedSubview(nudgeButton2)
        nudgeButtonStack.addArrangedSubview(nudgeButton3)

        view.addSubview(nudgeButtonStack)
        
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
                receiveValue: { userInfo in
                    print(userInfo)
                }
            )
        

        setUpConstraints()
    }
        
    func setUpConstraints() {
        savedNudgesLabel.snp.makeConstraints { make in
            make.leading.equalTo(nudgeButton1)
            make.bottom.equalTo(nudgeButton1.snp.top).offset(-15)
        }
        showAllLabel.snp.makeConstraints { make in
            make.trailing.equalTo(nudgeButton1)
            make.bottom.equalTo(savedNudgesLabel)
        }
        nudgeButton1.snp.makeConstraints { make in
            make.height.equalTo(80)
        }
        nudgeButton2.snp.makeConstraints { make in
            make.height.equalTo(80)
        }
        nudgeButton3.snp.makeConstraints { make in
            make.height.equalTo(80)
        }
        nudgeButtonStack.snp.makeConstraints { make in
            make.leading.trailing.equalTo(view).inset(buttonPadding)
            make.centerY.equalTo(view).offset(-30)
        }
        divider.snp.makeConstraints { make in
            make.leading.trailing.equalTo(nudgeButton3)
            make.top.equalTo(nudgeButton3.snp.bottom).offset(20)
            make.height.equalTo(1)
        }
        menuStack.snp.makeConstraints { make in
            make.top.equalTo(divider.snp.bottom).offset(20)
            make.leading.trailing.equalTo(nudgeButton1)
            make.height.equalTo(70)
        }
    }
}
