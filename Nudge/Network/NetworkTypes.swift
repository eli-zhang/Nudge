//
//  NetworkTypes.swift
//  Nudge
//
//  Created by Eli Zhang on 1/20/22.
//

import Foundation

struct Nudge: Codable {
    let _id: String
    let message: String
    let assignedFriends: [String]?
    let assignedGroup: String?
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
            let deviceToken: String?
        }
        
        struct Data: Codable {}
    }
    
    enum GetUserInfo {
        typealias Response = NetworkTypes.Response<Data>
        
        struct Data: Codable {
            let name: String?
            let friendCode: String
            let friends: [String]
            let groups: [String]
            let nudges: [Nudge]
        }
    }
    
    enum AddFriend {
        typealias Response = NetworkTypes.Response<Data>
        
        struct Body: Codable {
            let friendCode: String
        }
        
        struct Data: Codable {}
    }
    
    enum DeleteFriend {
        typealias Response = NetworkTypes.Response<Data>
    }
    
    enum CreateGroup {
        
    }
}
