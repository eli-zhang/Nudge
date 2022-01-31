//
//  NewNudgeController.swift
//  Nudge
//
//  Created by Eli Zhang on 1/27/22.
//

import Foundation
import UIKit
import Combine
import AudioToolbox

class NewNudgeController: UIViewController, UISearchBarDelegate {
    var backButton: UIButton!
    
    var containerView: UIView!
    var newNudgeLabel: UILabel!
    var newNudgeNameView: NewNudgeView!
    var recipientLabel: UILabel!
    var friendGroupSearchBar: SearchBarView!
    var groupsLayout: UICollectionViewFlowLayout!
    var groupsCollectionView: UICollectionView!
    var friendLabel: UILabel!
    var friendLayout: UICollectionViewFlowLayout!
    var friendsCollectionView: UICollectionView!
    var confirmButton: UIButton!
    
    var getUserCancellable: AnyCancellable?
    var createNudgeCancellable: AnyCancellable?
    
    var friends: [User] = [] {
        didSet {
            filteredFriends = friends
            selectedFriendIds = []
        }
    }
    var filteredFriends: [User] = []
    var selectedFriendIds: Set<String> = []
    var selectedGroupId: String? = nil
    var groups: [GroupPopulated] = [] {
        didSet {
            filteredGroups = groups
            selectedGroupId = nil
        }
    }
    var filteredGroups: [GroupPopulated] = []
    
    let friendReuseIdentifier = "friendListReuseIdentifier"
    let groupReuseIdentifier = "groupListReuseIdentifier"
    let buttonPadding = 30
    
    convenience init(user: UserPopulated?) {
        self.init()
        if let user = user {
            self.friends = user.friends
            self.filteredFriends = self.friends
            self.groups = user.groups
            self.filteredGroups = self.groups
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
        
        newNudgeLabel = UILabel()
        newNudgeLabel.text = "Create a new nudge"
        newNudgeLabel.font = UIFont(name: "OpenSans-Bold", size: 15)
        newNudgeLabel.textColor = Colors.almostOpaqueWhite
        containerView.addSubview(newNudgeLabel)

        newNudgeNameView = NewNudgeView()
        containerView.addSubview(newNudgeNameView)
        
        recipientLabel = UILabel()
        recipientLabel.text = "Who are the recipients?"
        recipientLabel.font = UIFont(name: "OpenSans-Bold", size: 15)
        recipientLabel.textColor = Colors.almostOpaqueWhite
        containerView.addSubview(recipientLabel)
      
        friendGroupSearchBar = SearchBarView()
        friendGroupSearchBar.searchField.addTarget(self, action: #selector(didChangeSearch), for: .editingChanged)
        friendGroupSearchBar.searchField.attributedPlaceholder = NSAttributedString(
            string: "Search your groups and friends...",
            attributes: [NSAttributedString.Key.foregroundColor: Colors.almostOpaqueWhite]
        )
        containerView.addSubview(friendGroupSearchBar)
        
        groupsLayout = UICollectionViewFlowLayout()
        groupsLayout.scrollDirection = .horizontal
        groupsLayout.minimumInteritemSpacing = 10

        groupsCollectionView = UICollectionView(frame: .zero, collectionViewLayout: groupsLayout)
        groupsCollectionView.register(GroupListCollectionViewCell.self, forCellWithReuseIdentifier: groupReuseIdentifier)
        groupsCollectionView.showsHorizontalScrollIndicator = false
        groupsCollectionView.dataSource = self
        groupsCollectionView.delegate = self
        groupsCollectionView.backgroundColor = .clear
        groupsCollectionView.layer.masksToBounds = false
        groupsCollectionView.alwaysBounceHorizontal = true
        containerView.addSubview(groupsCollectionView)
        
        friendLabel = UILabel()
        friendLabel.text = "Or pick individually from your friends:"
        friendLabel.textColor = Colors.almostOpaqueWhite
        friendLabel.font = UIFont(name: "OpenSans-Bold", size: 15)
        containerView.addSubview(friendLabel)
        
        friendLayout = UICollectionViewFlowLayout()
        friendLayout.scrollDirection = .horizontal
        friendLayout.minimumInteritemSpacing = 10
        
        friendsCollectionView = UICollectionView(frame: .zero, collectionViewLayout: friendLayout)
        friendsCollectionView.register(FriendListCollectionViewCell.self, forCellWithReuseIdentifier: friendReuseIdentifier)
        friendsCollectionView.allowsMultipleSelection = true
        friendsCollectionView.dataSource = self
        friendsCollectionView.delegate = self
        friendsCollectionView.backgroundColor = .clear
        friendsCollectionView.layer.masksToBounds = false
        friendsCollectionView.alwaysBounceHorizontal = true
        containerView.addSubview(friendsCollectionView)
        
        confirmButton = UIButton()
        confirmButton.setImage(UIImage(named: "Check"), for: .normal)
        confirmButton.backgroundColor = .white
        confirmButton.layer.cornerRadius = 10
        confirmButton.layer.shadowColor = Colors.shadowColor.cgColor
        confirmButton.layer.shadowOpacity = 1
        confirmButton.layer.shadowOffset = CGSize(width: 3, height: 4)
        confirmButton.layer.shadowRadius = 2
        confirmButton.addTarget(self, action: #selector(submitNudgeInfo), for: .touchUpInside)
        containerView.addSubview(confirmButton)
        
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
        newNudgeLabel.snp.makeConstraints { make in
            make.bottom.equalTo(newNudgeNameView.snp.top).offset(-15)
            make.leading.trailing.equalTo(containerView).inset(buttonPadding)
        }
        newNudgeNameView.snp.makeConstraints { make in
            make.bottom.equalTo(recipientLabel.snp.top).offset(-20)
            make.leading.trailing.equalTo(containerView).inset(buttonPadding)
            make.height.equalTo(80)
        }
        recipientLabel.snp.makeConstraints { make in
            make.bottom.equalTo(friendGroupSearchBar.snp.top).offset(-15)
            make.leading.trailing.equalTo(containerView).inset(buttonPadding)
        }
        friendGroupSearchBar.snp.makeConstraints { make in
            make.bottom.equalTo(groupsCollectionView.snp.top).offset(-15)
            make.height.equalTo(40)
            make.leading.trailing.equalTo(containerView).inset(buttonPadding)
        }
        groupsCollectionView.snp.makeConstraints { make in
            make.bottom.equalTo(friendLabel.snp.top).offset(-20)
            make.height.equalTo(80)
            make.leading.trailing.equalTo(containerView).inset(buttonPadding)
        }
        friendLabel.snp.makeConstraints { make in
            make.bottom.equalTo(friendsCollectionView.snp.top).offset(-15)
            make.leading.trailing.equalTo(containerView).inset(buttonPadding)
        }
        friendsCollectionView.snp.makeConstraints { make in
            make.bottom.equalTo(confirmButton.snp.top).offset(-40)
            make.height.equalTo(52)
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

        let delta = newNudgeNameView.frame.maxY - keyboardFrame.minY
        
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
    
    @objc func submitNudgeInfo() {
        AudioServicesPlaySystemSound(1519)
        let message = newNudgeNameView.textField.text ?? "No message"
        createNudgeCancellable = NetworkManager.createNudge(message: message, assignedFriends: Array(selectedFriendIds), assignedGroup: selectedGroupId)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                        case .failure(let error): print("Error: \(error)")
                        case .finished: print("Successfully created new nudge.")
                    }
                },
                receiveValue: { [weak self] _ in
                    guard let self = self else { return }
                    self.navigationController?.popViewController(animated: true)
                }
            )
    }
    
    @objc func didChangeSearch() {
        if let text = friendGroupSearchBar.searchField.text {
            if !text.isEmpty {
                filteredFriends = friends.filter ({ friend in
                    if let valid = friend.name?.lowercased().contains(text.lowercased()) {
                        return valid
                    }
                    return false
                })
                filteredGroups = groups.filter ({ group in
                    return group.name.lowercased().contains(text.lowercased())
                })
                friendsCollectionView.reloadData()
                groupsCollectionView.reloadData()
                return
            }
        }
        filteredGroups = groups
        filteredFriends = friends
        groupsCollectionView.reloadData()
        friendsCollectionView.reloadData()
    }
}

extension NewNudgeController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.friendsCollectionView {
            return filteredFriends.count
        }
        return filteredGroups.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.friendsCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: friendReuseIdentifier, for: indexPath) as! FriendListCollectionViewCell
            let friend = filteredFriends[indexPath.item]
            cell.configure(name: friend.name ?? "?",
                           colorType: ColorType.stringToColor(friend.color ?? ""))
            
            if selectedFriendIds.contains(filteredFriends[indexPath.item]._id) {
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
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: groupReuseIdentifier, for: indexPath) as! GroupListCollectionViewCell
        if selectedGroupId == filteredGroups[indexPath.item]._id {
            cell.layer.shadowColor = Colors.shadowColor.cgColor
            cell.layer.shadowOpacity = 1
            cell.layer.shadowOffset = CGSize(width: 1, height: 2)
            cell.layer.shadowRadius = 1
        } else {
            cell.layer.shadowColor = Colors.shadowColor.cgColor
            cell.layer.shadowOpacity = 1
            cell.layer.shadowOffset = CGSize(width: 3, height: 4)
            cell.layer.shadowRadius = 2
        }
        
        
        cell.isUserInteractionEnabled = false
        let group = filteredGroups[indexPath.item]
        cell.configure(group: group)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.friendsCollectionView {
            if selectedFriendIds.contains(filteredFriends[indexPath.item]._id) {
                selectedFriendIds.remove(filteredFriends[indexPath.item]._id)
            } else {
                selectedFriendIds.insert(filteredFriends[indexPath.item]._id)
            }
            collectionView.deselectItem(at: indexPath, animated: true)
            collectionView.reloadItems(at: [indexPath])
        } else {
            selectedGroupId = filteredGroups[indexPath.item]._id
            collectionView.deselectItem(at: indexPath, animated: true)
            collectionView.reloadItems(at: [indexPath])
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == self.groupsCollectionView {
            return CGSize(width: 130, height: 80)
        }
        return CGSize(width: 120, height: 52)
    }
}

extension NewNudgeController: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view is UIButton {
            return false
        }
        return true
    }
}
