//
//  FriendViewController.swift
//  Nudge
//
//  Created by Eli Zhang on 1/23/22.
//

import Foundation
import UIKit
import Combine
import AudioToolbox

class FriendViewController: UIViewController {
    
    var notificationBanner: UIView!
    var notificationBannerLabel: UILabel!
    
    var backButton: UIButton!
    
    var containerView: UIView!
    var myFriendCodeLabel: UILabel!
    var myFriendCodeView: MyFriendCodeView!
    var divider: UIView!
    var addFriendLabel: UILabel!
    var addFriendCodeView: AddFriendCodeView!
    var yourFriendsLabel: UILabel!
    var friendLayout: UICollectionViewFlowLayout!
    var friendsCollectionView: UICollectionView!
    
    var yourGroupsLabel: UILabel!
    var groupsLayout: UICollectionViewFlowLayout!
    var groupsCollectionView: UICollectionView!
    
    var getUserCancellable: AnyCancellable?
    var addFriendCancellable: AnyCancellable?
    
    var friends: [User] = []
    var groups: [GroupPopulated] = []
    
    let friendReuseIdentifier = "friendListReuseIdentifier"
    let groupReuseIdentifier = "groupListReuseIdentifier"
    let newGroupReuseIdentifier = "groupListNewReuseIdentifier"
    let buttonPadding = 30
    
    convenience init(user: UserPopulated?) {
        self.init()
        if let user = user {
            self.friends = user.friends
            self.groups = user.groups
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(patternImage: UIImage(named: "Background.png")!)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        tap.delegate = self

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )

        view.addGestureRecognizer(tap)
        
        containerView = UIView() // Make sure this is in the back so it doesn't cover other views
        containerView.backgroundColor = .clear
        view.addSubview(containerView)
        
        backButton = UIButton()
        backButton.addTarget(self, action: #selector(popViewController), for: .touchUpInside)
        backButton.setImage(UIImage(named: "Back"), for: .normal)
        view.addSubview(backButton)
        
        notificationBanner = UIView()
        notificationBanner.backgroundColor = Colors.offWhite
        notificationBanner.alpha = 0
        notificationBanner.layer.cornerRadius = 10
        notificationBanner.layer.shadowColor = Colors.shadowColor.cgColor
        notificationBanner.layer.shadowOpacity = 1
        notificationBanner.layer.shadowOffset = CGSize(width: 3, height: 4)
        notificationBanner.layer.shadowRadius = 2

        view.addSubview(notificationBanner)

        notificationBannerLabel = UILabel()
        notificationBannerLabel.textColor = Colors.gray
        notificationBannerLabel.textAlignment = .center
        notificationBannerLabel.font = UIFont(name: "OpenSans-Semibold", size: 14)
        notificationBanner.addSubview(notificationBannerLabel)
        
        myFriendCodeLabel = UILabel()
        myFriendCodeLabel.text = "Your friend code"
        myFriendCodeLabel.font = UIFont(name: "OpenSans-Bold", size: 15)
        myFriendCodeLabel.textColor = Colors.almostOpaqueWhite
        containerView.addSubview(myFriendCodeLabel)

        myFriendCodeView = MyFriendCodeView()
        myFriendCodeView.delegate = self
        containerView.addSubview(myFriendCodeView)
        
        divider = UIView()
        divider.backgroundColor = Colors.halfOpacityWhite
        containerView.addSubview(divider)
        
        addFriendLabel = UILabel()
        addFriendLabel.text = "Add a friend or group"
        addFriendLabel.font = UIFont(name: "OpenSans-Bold", size: 15)
        addFriendLabel.textColor = Colors.almostOpaqueWhite
        containerView.addSubview(addFriendLabel)
        
        addFriendCodeView = AddFriendCodeView()
        addFriendCodeView.textField.placeholder = "Enter friend/group code..."
        addFriendCodeView.delegate = self
        containerView.addSubview(addFriendCodeView)
        
        yourFriendsLabel = UILabel()
        yourFriendsLabel.text = "Your friends"
        yourFriendsLabel.textColor = Colors.almostOpaqueWhite
        yourFriendsLabel.font = UIFont(name: "OpenSans-Bold", size: 15)
        containerView.addSubview(yourFriendsLabel)
        
        friendLayout = UICollectionViewFlowLayout()
        friendLayout.scrollDirection = .horizontal
        friendLayout.minimumInteritemSpacing = 10
        friendLayout.itemSize = CGSize(width: 120, height: 52)
        
        friendsCollectionView = UICollectionView(frame: .zero, collectionViewLayout: friendLayout)
        friendsCollectionView.register(FriendListCollectionViewCell.self, forCellWithReuseIdentifier: friendReuseIdentifier)
        friendsCollectionView.dataSource = self
        friendsCollectionView.delegate = self
        friendsCollectionView.backgroundColor = .clear
        friendsCollectionView.layer.masksToBounds = false
        friendsCollectionView.alwaysBounceHorizontal = true
        containerView.addSubview(friendsCollectionView)
        
        yourGroupsLabel = UILabel()
        yourGroupsLabel.text = "Your groups"
        yourGroupsLabel.textColor = Colors.almostOpaqueWhite
        yourGroupsLabel.font = UIFont(name: "OpenSans-Bold", size: 15)
        containerView.addSubview(yourGroupsLabel)
        
        groupsLayout = UICollectionViewFlowLayout()
        groupsLayout.scrollDirection = .horizontal
        groupsLayout.minimumInteritemSpacing = 10
        groupsLayout.itemSize = CGSize(width: 80, height: 80)

        groupsCollectionView = UICollectionView(frame: .zero, collectionViewLayout: groupsLayout)
        groupsCollectionView.register(GroupListCollectionViewCell.self, forCellWithReuseIdentifier: groupReuseIdentifier)
        groupsCollectionView.register(GroupListNewCollectionViewCell.self, forCellWithReuseIdentifier: newGroupReuseIdentifier)
        groupsCollectionView.dataSource = self
        groupsCollectionView.delegate = self
        groupsCollectionView.backgroundColor = .clear
        groupsCollectionView.layer.masksToBounds = false
        groupsCollectionView.alwaysBounceHorizontal = true
        containerView.addSubview(groupsCollectionView)
        
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
                    self.myFriendCodeView.textField.text = userInfo.friendCode
                    self.friends = userInfo.friends
                    self.groups = userInfo.groups
                    self.friendsCollectionView.reloadData()
                    self.groupsCollectionView.reloadData()
                }
            )

        setUpConstraints()
    }
        
    func setUpConstraints() {
        notificationBanner.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.height.equalTo(35)
        }
        notificationBannerLabel.snp.makeConstraints { make in
            make.center.equalTo(notificationBanner)
            make.leading.trailing.equalTo(notificationBanner).inset(20)
        }
        backButton.snp.makeConstraints { make in
            make.leading.top.equalTo(view.safeAreaLayoutGuide).inset(10)
            make.height.width.equalTo(40)
        }
        containerView.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        myFriendCodeLabel.snp.makeConstraints { make in
            make.bottom.equalTo(myFriendCodeView.snp.top).offset(-15)
            make.leading.trailing.equalTo(containerView).inset(buttonPadding)
        }
        myFriendCodeView.snp.makeConstraints { make in
            make.bottom.equalTo(divider.snp.top).offset(-25)
            make.leading.trailing.equalTo(containerView).inset(buttonPadding)
            make.height.equalTo(80)
        }
        divider.snp.makeConstraints { make in
            make.bottom.equalTo(addFriendLabel.snp.top).offset(-20)

            make.leading.trailing.equalTo(containerView).inset(buttonPadding)
            make.height.equalTo(1)
        }
        addFriendLabel.snp.makeConstraints { make in
            make.bottom.equalTo(addFriendCodeView.snp.top).offset(-15)
            make.leading.trailing.equalTo(containerView).inset(buttonPadding)
        }
        addFriendCodeView.snp.makeConstraints { make in
            make.bottom.equalTo(yourFriendsLabel.snp.top).offset(-45)
            make.leading.trailing.equalTo(containerView).inset(buttonPadding)
            make.height.equalTo(80)
        }
        yourFriendsLabel.snp.makeConstraints { make in
            make.bottom.equalTo(friendsCollectionView.snp.top).offset(-15)
            make.leading.trailing.equalTo(containerView).inset(buttonPadding)
        }
        friendsCollectionView.snp.makeConstraints { make in
            make.bottom.equalTo(yourGroupsLabel.snp.top).offset(-20)
            make.height.equalTo(52)
            make.leading.trailing.equalTo(containerView).inset(buttonPadding)
        }
        yourGroupsLabel.snp.makeConstraints { make in
            make.bottom.equalTo(groupsCollectionView.snp.top).offset(-15)
            make.leading.trailing.equalTo(containerView).inset(buttonPadding)
        }
        groupsCollectionView.snp.makeConstraints { make in
            make.bottom.equalTo(containerView).offset(-60)
            make.height.equalTo(80)
            make.leading.trailing.equalTo(containerView).inset(buttonPadding)
        }
        
    }
    
    func showNotification(text: String) {
        notificationBannerLabel.text = text
        UIView.animate(withDuration: 0.2, animations: {
            self.notificationBanner.alpha = 1
        })
        
        let delay = Int(3 * Double(1000))
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(delay), execute: {
            UIView.animate(withDuration: 0.2, animations: {
                self.notificationBanner.alpha = 0
            })
        })
    }
    
    @objc func popViewController() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardFrameValue
                = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        let keyboardFrame = keyboardFrameValue.cgRectValue

        let delta = myFriendCodeView.frame.maxY - keyboardFrame.minY
        
        containerView.snp.updateConstraints { make in
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            make.top.bottom.equalTo(view.safeAreaLayoutGuide).offset(delta)
        }
        
        UIView.animate(withDuration: 0.2, animations: {
            self.view.layoutIfNeeded()
        })
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        containerView.snp.updateConstraints { make in
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            make.top.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        UIView.animate(withDuration: 0.2, animations: {
            self.view.layoutIfNeeded()
        })

    }
}

extension FriendViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.friendsCollectionView {
            return friends.count
        }
        return groups.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.friendsCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: friendReuseIdentifier, for: indexPath) as! FriendListCollectionViewCell
            let friend = friends[indexPath.item]
            cell.configure(name: friend.name ?? "",
                           colorType: ColorType.stringToColor(friend.color ?? ""))
            return cell
        }
        
        if indexPath.item == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: newGroupReuseIdentifier, for: indexPath) as! GroupListNewCollectionViewCell
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: groupReuseIdentifier, for: indexPath) as! GroupListCollectionViewCell
            let group = groups[indexPath.item]
            cell.configure(group: group)
            return cell
        }
    }
    
    
}

extension FriendViewController: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view is UIButton {
            return false
        }
        return true
    }
}

extension FriendViewController: FinishCopyingDelegate, AddFriendDelegate {
    func finishCopying() {
        AudioServicesPlaySystemSound(1520)
        showNotification(text: "Copied code!")
    }
    func addFriend(friendCode: String) {
        addFriendCancellable = NetworkManager.addFriendOrGroup(code: friendCode)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                        case .failure(let error): print("Error: \(error)")
                        case .finished: print("Successfully added friend.")
                    }
                },
                receiveValue: { [weak self] _ in
                    guard let self = self else { return }
                    AudioServicesPlaySystemSound(1520)
                    self.showNotification(text: "Added friend!")
                }
            )
    }
}
