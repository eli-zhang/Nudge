//
//  GroupListCollectionViewCell.swift
//  Nudge
//
//  Created by Eli Zhang on 1/27/22.
//

import UIKit
import SnapKit

class GroupListCollectionViewCell: UICollectionViewCell, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var groupName: UILabel!
    var layout: UICollectionViewFlowLayout!
    var memberListCollection: UICollectionView!
    
    var members: [User] = []
    let maxMembers = 5
    
    let memberReuseIdentifier = "memberReuseIdentifier"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.cornerRadius = 15
        
        contentView.backgroundColor = Colors.purple1
        
        groupName = UILabel()
        contentView.addSubview(groupName)
        
        layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 25, height: 25)
        layout.minimumInteritemSpacing = -20
        
        memberListCollection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        memberListCollection.register(ProfilePictureCollectionViewCell.self, forCellWithReuseIdentifier: memberReuseIdentifier)
        memberListCollection.backgroundColor = .clear
        contentView.addSubview(memberListCollection)
        
        self.layer.shadowColor = Colors.shadowColor.cgColor
        self.layer.shadowOpacity = 1
        self.layer.shadowOffset = CGSize(width: 3, height: 4)
        self.layer.shadowRadius = 2
        
        setUpConstraints()
    }
    
    func setUpConstraints() {
        groupName.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(contentView).inset(20)
        }
        memberListCollection.snp.makeConstraints { make in
            make.top.equalTo(groupName.snp.bottom).offset(20)
            make.bottom.leading.trailing.equalTo(contentView).inset(20)
        }
    }
    
    func configure(group: GroupPopulated) {
        self.members = group.members
        memberListCollection.reloadData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return min(members.count, maxMembers)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: memberReuseIdentifier, for: indexPath) as! ProfilePictureCollectionViewCell
        let member = members[indexPath.item]
        cell.configure(name: member.name ?? "?", colorType: ColorType.stringToColor(member.color ?? "WHITE"))
        return cell
    }
}

class GroupListNewCollectionViewCell: UICollectionViewCell {
    var addImage: UIImage!
    var addIcon: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.layer.cornerRadius = 10
        
        contentView.backgroundColor = Colors.purple1
        
        addImage = UIImage(named: "CreateNew")
        addIcon = UIImageView(image: addImage)
        addIcon.contentMode = .scaleAspectFit
        contentView.addSubview(addIcon)
        
        self.layer.shadowColor = Colors.shadowColor.cgColor
        self.layer.shadowOpacity = 1
        self.layer.shadowOffset = CGSize(width: 3, height: 4)
        self.layer.shadowRadius = 2
        
        setUpConstraints()
    }
    
    func setUpConstraints() {
        addIcon.snp.makeConstraints { make in
            make.edges.equalTo(center).inset(30)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
