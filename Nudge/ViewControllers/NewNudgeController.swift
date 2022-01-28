////
////  NewNudgeController.swift
////  Nudge
////
////  Created by Eli Zhang on 1/27/22.
////
//
//import Foundation
//import UIKit
//import Combine
//import AudioToolbox
//
//class NewNudgeController: UIViewController {
//    var containerView: UIView!
//    var newNotificationPrompt: UILabel!
//    var messageEntryView: NameEntryView!
//    var layout: UICollectionViewFlowLayout!
//    var colorButtonCollectionView: UICollectionView!
//    var italicLabel: UILabel!
//    var userPillPreview: UserPillView!
//    var confirmButton: UIButton!
//    
//    var updateUserCancellable: AnyCancellable?
//    
//    var name = ""
//    var selectedColor: ColorType = .white
//    let reuseIdentifier = "colorButtonReuseIdentifier"
//    let buttonPadding = 30
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = UIColor(patternImage: UIImage(named: "Background.png")!)
//        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
//        tap.cancelsTouchesInView = false
//        view.addGestureRecognizer(tap)
//
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(keyboardWillShow),
//            name: UIResponder.keyboardWillShowNotification,
//            object: nil
//        )
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(keyboardWillHide),
//            name: UIResponder.keyboardWillHideNotification,
//            object: nil
//        )
//        
//        containerView = UIView()
//        containerView.backgroundColor = .clear
//        view.addSubview(containerView)
//
//        namePrompt = UILabel()
//        namePrompt.text = "What's your name?"
//        namePrompt.font = UIFont(name: "OpenSans-Semibold", size: 18)
//        namePrompt.textColor = Colors.offWhite
//        containerView.addSubview(namePrompt)
//        
//        nameEntryView = NameEntryView()
//        nameEntryView.delegate = self
//        containerView.addSubview(nameEntryView)
//        
//        pickColorLabel = UILabel()
//        pickColorLabel.text = "Pick a color you like:"
//        pickColorLabel.textColor = Colors.offWhite
//        pickColorLabel.font = UIFont(name: "OpenSans-Regular", size: 18)
//        containerView.addSubview(pickColorLabel)
//        
//        layout = UICollectionViewFlowLayout()
//        layout.scrollDirection = .horizontal
//        layout.itemSize = CGSize(width: 50, height: 50)
//        
//        colorButtonCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
//        colorButtonCollectionView.register(UserColorCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
//        colorButtonCollectionView.delegate = self
//        colorButtonCollectionView.dataSource = self
//        colorButtonCollectionView.backgroundColor = .clear
//        colorButtonCollectionView.layer.masksToBounds = false
//
//        containerView.addSubview(colorButtonCollectionView)
//        
//        italicLabel = UILabel()
//        italicLabel.text = "This is what your friends will see."
//        italicLabel.textColor = Colors.offWhite
//        italicLabel.font = UIFont(name: "OpenSans-Italic", size: 18)
//        containerView.addSubview(italicLabel)
//        
//        userPillPreview = UserPillView()
//        containerView.addSubview(userPillPreview)
//        
//        confirmButton = UIButton()
//        confirmButton.setImage(UIImage(named: "Check"), for: .normal)
//        confirmButton.backgroundColor = .white
//        confirmButton.layer.cornerRadius = 10
//        confirmButton.layer.shadowColor = Colors.shadowColor.cgColor
//        confirmButton.layer.shadowOpacity = 1
//        confirmButton.layer.shadowOffset = CGSize(width: 3, height: 4)
//        confirmButton.layer.shadowRadius = 2
//        confirmButton.addTarget(self, action: #selector(submitProfileInfo), for: .touchUpInside)
//        containerView.addSubview(confirmButton)
//        
//        pickColorLabel.alpha = 0
//        colorButtonCollectionView.alpha = 0
//        italicLabel.alpha = 0
//        userPillPreview.alpha = 0
//        confirmButton.alpha = 0
//        
//        setUpConstraints()
//    }
//    
//    func setUpConstraints() {
//        containerView.snp.makeConstraints { make in
//            make.leading.trailing.top.bottom.equalTo(view.safeAreaLayoutGuide)
//        }
//        namePrompt.snp.makeConstraints { make in
//            make.leading.trailing.equalTo(containerView).inset(buttonPadding)
//            make.bottom.equalTo(nameEntryView.snp.top).offset(-15)
//        }
//        nameEntryView.snp.makeConstraints { make in
//            make.bottom.equalTo(pickColorLabel.snp.top).offset(-20)
//            make.leading.trailing.equalTo(containerView).inset(buttonPadding)
//            make.height.equalTo(80)
//        }
//        pickColorLabel.snp.makeConstraints { make in
//            make.leading.equalTo(colorButtonCollectionView)
//            make.bottom.equalTo(colorButtonCollectionView.snp.top).offset(-15)
//        }
//        colorButtonCollectionView.snp.makeConstraints { make in
//            make.leading.trailing.equalTo(containerView).offset(buttonPadding)
//            make.height.equalTo(50)
//            make.bottom.equalTo(italicLabel.snp.top).offset(-20)
//        }
//        italicLabel.snp.makeConstraints { make in
//            make.bottom.equalTo(userPillPreview.snp.top).offset(-15)
//            make.leading.equalTo(containerView).inset(buttonPadding)
//        }
//        userPillPreview.snp.makeConstraints { make in
//            make.bottom.equalTo(confirmButton.snp.top).offset(-30)
//            make.height.equalTo(50)
//            make.leading.equalTo(containerView).inset(buttonPadding)
//        }
//        confirmButton.snp.makeConstraints { make in
//            make.leading.trailing.bottom.equalTo(containerView).inset(buttonPadding)
//            make.height.equalTo(55)
//        }
//    }
//    
//    @objc func keyboardWillShow(notification: NSNotification) {
//        guard let keyboardFrameValue
//                = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
//            return
//        }
//        let keyboardFrame = keyboardFrameValue.cgRectValue
//
//        let delta = nameEntryView.frame.maxY - keyboardFrame.minY
//        
//        containerView.snp.updateConstraints { make in
//            make.leading.trailing.equalTo(view.safeAreaLayoutGuide)
//            make.top.bottom.equalTo(view.safeAreaLayoutGuide).offset(delta)
//        }
//        
//        UIView.animate(withDuration: 0.2, animations: {
//            self.view.layoutIfNeeded()
//        })
//    }
//
//    @objc func keyboardWillHide(notification: NSNotification) {
//        containerView.snp.updateConstraints { make in
//            make.leading.trailing.equalTo(view.safeAreaLayoutGuide)
//            make.top.bottom.equalTo(view.safeAreaLayoutGuide)
//        }
//        
//        UIView.animate(withDuration: 0.2, animations: {
//            self.view.layoutIfNeeded()
//        })
//    }
//    
//    @objc func dismissKeyboard() {
//        view.endEditing(true)
//    }
//    
//    @objc func submitProfileInfo() {
//        let color = self.selectedColor.toString()
//        updateUserCancellable = NetworkManager.updateUserInfo(name: name, color: color)
//            .receive(on: DispatchQueue.main)
//            .sink(
//                receiveCompletion: { completion in
//                    switch completion {
//                        case .failure(let error): print("Error: \(error)")
//                        case .finished: print("Successfully updated user info.")
//                    }
//                },
//                receiveValue: { [weak self] _ in
//                    guard let self = self else { return }
//                    self.view.endEditing(true)
//                    AudioServicesPlaySystemSound(1519)
//                    UserDefaults.standard.set(self.name, forKey: "name")
//                    UIView.animate(withDuration: 0.2, animations: {
//                        self.containerView.alpha = 0
//                    })
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
//                        self.dismissViewController()
//                    })
//                }
//            )
//    }
//    
//    func showOtherInfo() {
//        UIView.animate(withDuration: 0.2, animations: {
//            self.pickColorLabel.alpha = 1
//            self.colorButtonCollectionView.alpha = 1
//            self.italicLabel.alpha = 1
//            self.userPillPreview.alpha = 1
//            self.confirmButton.alpha = 1
//        })
//    }
//    
//    func dismissViewController() {
//        navigationController?.popViewController(animated: false)
//    }
//}
//
//extension NewNudgeController: UICollectionViewDelegate, UICollectionViewDataSource {
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return 5
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! UserColorCollectionViewCell
//        switch (indexPath.item) {
//        case 0:
//            cell.configure(name: name, colorType: .white)
//        case 1:
//            cell.configure(name: name, colorType: .black)
//        case 2:
//            cell.configure(name: name, colorType: .blue)
//        case 3:
//            cell.configure(name: name, colorType: .red)
//        case 4:
//            cell.configure(name: name, colorType: .purple)
//        default:
//            cell.configure(name: name, colorType: .white)
//        }
//        return cell
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        switch (indexPath.item) {
//        case 0:
//            self.selectedColor = .white
//        case 1:
//            self.selectedColor = .black
//        case 2:
//            self.selectedColor = .blue
//        case 3:
//            self.selectedColor = .red
//        case 4:
//            self.selectedColor = .purple
//        default:
//            self.selectedColor = .white
//        }
//        
//        userPillPreview.configure(name: name, colorType: self.selectedColor)
//    }
//}
