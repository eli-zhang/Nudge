//
//  NetworkTypes.swift
//  Nudge
//
//  Created by Eli Zhang on 1/20/22.
//

import Foundation

struct User: Codable {
    let _id: String
    let name: String?
    let color: String?
    let friendCode: String
    let friends: [String]
    let groups: [String]
    let nudges: [String]
}

struct UserBasic: Codable {
    let _id: String
    let name: String?
    let color: String?
    let friendCode: String
    let friends: [String]
    let groups: [String]
    let nudges: [NudgePopulated]
}

struct UserPopulated: Codable {
    let _id: String
    let name: String?
    let color: String?
    let friendCode: String
    let friends: [User]
    let groups: [GroupPopulated]
    let nudges: [NudgePopulated]
}

struct NudgePopulated: Codable {
    let _id: String
    let message: String
    let assignedFriends: [User]?
    let assignedGroup: Group?
}

struct Group: Codable {
    let name: String
    let members: [String]
    let groupCode: String
}

struct GroupPopulated: Codable {
    let name: String
    let members: [User]
    let groupCode: String
}

struct NetworkTypes {

    struct Response<Data: Codable>: Codable {
        let success: Bool
        let data: Data?
        let err: String?
        let err_code: Int?
    }

    enum CreateUser {
        typealias Response = NetworkTypes.Response<Data>

        struct Body: Codable {
            let password: String
            let deviceToken: String?
        }
        
        typealias Data = String
    }
    
    enum UpdateUserInfo {
        typealias Response = NetworkTypes.Response<Data>

        struct Body: Codable {
            let name: String?
            let color: String?
            let deviceToken: String?
        }
        
        struct Data: Codable {}
    }
    
    enum GetUserInfo {
        typealias Response = NetworkTypes.Response<Data>
        
        typealias Data = UserPopulated
    }
    
    enum GetBasicUserInfo {
        typealias Response = NetworkTypes.Response<Data>
        
        typealias Data = UserBasic
    }
    
    enum AddFriendOrGroup {
        typealias Response = NetworkTypes.Response<Data>
        
        struct Body: Codable {
            let code: String
        }
        
        struct Data: Codable {}
    }
    
    enum CreateGroup {
        struct Body: Codable {
            let groupName: String
            let memberIds: [String]
        }
    }
    
    enum AddGroupMember {
        struct Body: Codable {
            let groupCode: String
        }
    }
    
    enum RemoveGroupMember {
        struct Body: Codable {
            let groupId: String
        }
    }
    
    enum CreateNudge {
        struct Body: Codable {
            let message: String
            let assignedFriends: [String]
            let assignedGroup: String?
        }
    }
    
    enum PingNudge {
        struct Body: Codable {}
    }
}
