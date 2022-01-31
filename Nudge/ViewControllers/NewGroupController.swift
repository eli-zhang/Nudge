//
//  NewGroupController.swift
//  Nudge
//
//  Created by Eli Zhang on 1/28/22.
//

import Foundation
import UIKit
import Combine
import AudioToolbox

class NewGroupController: UIViewController, UISearchBarDelegate {
    var backButton: UIButton!
    
    var containerView: UIView!
    var newGroupLabel: UILabel!
    var newGroupNameView: NameEntryView!
    var selectGroupMembersLabel: UILabel!
    var friendSearchBar: SearchBarView!
    var friendLayout: UICollectionViewFlowLayout!
    var friendsCollectionView: UICollectionView!
    var groupMembersLabel: UILabel!
    var groupMembersLayout: UICollectionViewFlowLayout!
    var groupMembersCollectionView: UICollectionView!
    var confirmButton: UIButton!
    
    var getUserCancellable: AnyCancellable?
    var createGroupCancellable: AnyCancellable?
    
    var friends: [User] = [] {
        didSet {
            filteredFriends = friends
            selectedIds = []
        }
    }
    var filteredFriends: [User] = []
    var selectedIds: Set<String> = [] {
        didSet {
            groupMembers = friends.filter { selectedIds.contains($0._id) }
            groupMembersCollectionView.reloadData()
        }
    }
    var groupMembers: [User] = []
    
    let friendReuseIdentifier = "friendListReuseIdentifier"
    let groupMembersReuseIdentifier = "groupMembersListReuseIdentifier"
    let buttonPadding = 30
    
    convenience init(user: UserPopulated?) {
        self.init()
        if let user = user {
            self.friends = user.friends
            self.filteredFriends = self.friends
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(patternImage: UIImage(named: "Background.png")!)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        tap.delegate = self
        tap.cancelsTouchesInView = false

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
        
        newGroupLabel = UILabel()
        newGroupLabel.text = "Create a new group"
        newGroupLabel.font = UIFont(name: "OpenSans-Bold", size: 15)
        newGroupLabel.textColor = Colors.almostOpaqueWhite
        containerView.addSubview(newGroupLabel)

        newGroupNameView = NameEntryView()
        newGroupNameView.delegate = self
        containerView.addSubview(newGroupNameView)
        
        selectGroupMembersLabel = UILabel()
        selectGroupMembersLabel.text = "Select group members"
        selectGroupMembersLabel.font = UIFont(name: "OpenSans-Bold", size: 15)
        selectGroupMembersLabel.textColor = Colors.almostOpaqueWhite
        containerView.addSubview(selectGroupMembersLabel)
      
        friendSearchBar = SearchBarView()
        friendSearchBar.searchField.addTarget(self, action: #selector(didChangeSearch), for: .editingChanged)
        containerView.addSubview(friendSearchBar)
        
        friendLayout = UICollectionViewFlowLayout()
        friendLayout.scrollDirection = .horizontal
        friendLayout.minimumInteritemSpacing = 10
        friendLayout.itemSize = CGSize(width: 120, height: 52)
        
        friendsCollectionView = UICollectionView(frame: .zero, collectionViewLayout: friendLayout)
        friendsCollectionView.register(FriendListCollectionViewCell.self, forCellWithReuseIdentifier: friendReuseIdentifier)
        friendsCollectionView.allowsMultipleSelection = true
        friendsCollectionView.dataSource = self
        friendsCollectionView.delegate = self
        friendsCollectionView.backgroundColor = .clear
        friendsCollectionView.layer.masksToBounds = false
        friendsCollectionView.alwaysBounceHorizontal = true
        containerView.addSubview(friendsCollectionView)
        
        groupMembersLabel = UILabel()
        groupMembersLabel.text = "Group members"
        groupMembersLabel.textColor = Colors.almostOpaqueWhite
        groupMembersLabel.font = UIFont(name: "OpenSans-Bold", size: 15)
        containerView.addSubview(groupMembersLabel)
        
        groupMembersLayout = UICollectionViewFlowLayout()
        groupMembersLayout.scrollDirection = .horizontal
        groupMembersLayout.minimumInteritemSpacing = 10
        groupMembersLayout.itemSize = CGSize(width: 50, height: 50)

        groupMembersCollectionView = UICollectionView(frame: .zero, collectionViewLayout: groupMembersLayout)
        groupMembersCollectionView.register(UserColorCollectionViewCell.self, forCellWithReuseIdentifier: groupMembersReuseIdentifier)
        groupMembersCollectionView.dataSource = self
        groupMembersCollectionView.delegate = self
        groupMembersCollectionView.backgroundColor = .clear
        groupMembersCollectionView.layer.masksToBounds = false
        groupMembersCollectionView.alwaysBounceHorizontal = true
        containerView.addSubview(groupMembersCollectionView)
        
        confirmButton = UIButton()
        confirmButton.setImage(UIImage(named: "Check"), for: .normal)
        confirmButton.backgroundColor = .white
        confirmButton.layer.cornerRadius = 10
        confirmButton.layer.shadowColor = Colors.shadowColor.cgColor
        confirmButton.layer.shadowOpacity = 1
        confirmButton.layer.shadowOffset = CGSize(width: 3, height: 4)
        confirmButton.layer.shadowRadius = 2
        confirmButton.addTarget(self, action: #selector(submitGroupInfo), for: .touchUpInside)
        containerView.addSubview(confirmButton)
        
        selectGroupMembersLabel.alpha = 0
        friendSearchBar.alpha = 0
        friendsCollectionView.alpha = 0
        groupMembersLabel.alpha = 0
        groupMembersCollectionView.alpha = 0
        confirmButton.alpha = 0
        
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
                    self.friends = userInfo.friends
                    self.filteredFriends = userInfo.friends
                    self.friendsCollectionView.reloadData()
                }
            )

        setUpConstraints()
    }
        
    func setUpConstraints() {
        backButton.snp.makeConstraints { make in
            make.leading.top.equalTo(view.safeAreaLayoutGuide).inset(10)
            make.height.width.equalTo(40)
        }
        containerView.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        newGroupLabel.snp.makeConstraints { make in
            make.bottom.equalTo(newGroupNameView.snp.top).offset(-15)
            make.leading.trailing.equalTo(containerView).inset(buttonPadding)
        }
        newGroupNameView.snp.makeConstraints { make in
            make.bottom.equalTo(selectGroupMembersLabel.snp.top).offset(-20)
            make.leading.trailing.equalTo(containerView).inset(buttonPadding)
            make.height.equalTo(80)
        }
        selectGroupMembersLabel.snp.makeConstraints { make in
            make.bottom.equalTo(friendSearchBar.snp.top).offset(-15)
            make.leading.trailing.equalTo(containerView).inset(buttonPadding)
        }
        friendSearchBar.snp.makeConstraints { make in
            make.bottom.equalTo(friendsCollectionView.snp.top).offset(-15)
            make.height.equalTo(40)
            make.leading.trailing.equalTo(containerView).inset(buttonPadding)
        }
        friendsCollectionView.snp.makeConstraints { make in
            make.bottom.equalTo(groupMembersLabel.snp.top).offset(-20)
            make.height.equalTo(52)
            make.leading.trailing.equalTo(containerView).inset(buttonPadding)
        }
        groupMembersLabel.snp.makeConstraints { make in
            make.bottom.equalTo(groupMembersCollectionView.snp.top).offset(-15)
            make.leading.trailing.equalTo(containerView).inset(buttonPadding)
        }
        groupMembersCollectionView.snp.makeConstraints { make in
            make.bottom.equalTo(confirmButton.snp.top).offset(-40)
            make.height.equalTo(50)
            make.leading.trailing.equalTo(containerView).inset(buttonPadding)
        }
        confirmButton.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalTo(containerView).inset(buttonPadding)
            make.height.equalTo(55)
        }
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

        let delta = newGroupNameView.frame.maxY - keyboardFrame.minY
        
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
    
    func showFriendsList() {
        UIView.animate(withDuration: 0.2, animations: {
            self.selectGroupMembersLabel.alpha = 1
            self.friendSearchBar.alpha = 1
            self.friendsCollectionView.alpha = 1
            self.groupMembersLabel.alpha = 1
            self.groupMembersCollectionView.alpha = 1
            self.confirmButton.alpha = 1
        })
    }
    
    @objc func submitGroupInfo() {
        AudioServicesPlaySystemSound(1519)
        let name = newGroupNameView.textField.text
        createGroupCancellable = NetworkManager.createGroup(groupName: name ?? "No group name", memberIds: Array(selectedIds))
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                        case .failure(let error): print("Error: \(error)")
                        case .finished: print("Successfully created new group.")
                    }
                },
                receiveValue: { [weak self] _ in
                    guard let self = self else { return }
                    self.navigationController?.popViewController(animated: true)
                }
            )
    }
    
    @objc func didChangeSearch() {
        if let text = friendSearchBar.searchField.text {
            if !text.isEmpty {
                filteredFriends = friends.filter ({ friend in
                    if let valid = friend.name?.lowercased().contains(text.lowercased()) {
                        return valid
                    }
                    return false
                })
                friendsCollectionView.reloadData()
                return
            }
        }
        filteredFriends = friends
        friendsCollectionView.reloadData()
    }
}

extension NewGroupController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.friendsCollectionView {
            return filteredFriends.count
        }
        return groupMembers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.friendsCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: friendReuseIdentifier, for: indexPath) as! FriendListCollectionViewCell
            let friend = filteredFriends[indexPath.item]
            cell.configure(name: friend.name ?? "?",
                           colorType: ColorType.stringToColor(friend.color ?? ""))
            
            if selectedIds.contains(filteredFriends[indexPath.item]._id) {
                cell.friendPillView.layer.shadowColor = Colors.shadowColor.cgColor
                cell.friendPillView.layer.shadowOpacity = 1
                cell.friendPillView.layer.shadowOffset = CGSize(width: 1, height: 2)
                cell.friendPillView.layer.shadowRadius = 1
            } else {
                cell.friendPillView.layer.shadowColor = Colors.shadowColor.cgColor
                cell.friendPillView.layer.shadowOpacity = 1
                cell.friendPillView.layer.shadowOffset = CGSize(width: 3, height: 4)
                cell.friendPillView.layer.shadowRadius = 2
            }
            
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: groupMembersReuseIdentifier, for: indexPath) as! UserColorCollectionViewCell
        cell.isUserInteractionEnabled = false
        let member = groupMembers[indexPath.item]
        cell.configure(name: member.name ?? "?", colorType: ColorType.stringToColor(member.color ?? "WHITE"))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.friendsCollectionView {
            if selectedIds.contains(filteredFriends[indexPath.item]._id) {
                selectedIds.remove(filteredFriends[indexPath.item]._id)
            } else {
                selectedIds.insert(filteredFriends[indexPath.item]._id)
            }
            collectionView.deselectItem(at: indexPath, animated: true)
            collectionView.reloadItems(at: [indexPath])
        }
    }
}

extension NewGroupController: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view is UIButton {
            return false
        }
        return true
    }
}

extension NewGroupController: SubmitNameDelegate {
    func submitName(name: String) {
        AudioServicesPlaySystemSound(1519)
        showFriendsList()
    }
}

