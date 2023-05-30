//
//  User.swift
//  Broche
//
//  Created by Jacob Johnson on 5/18/23.
//

import Foundation
import Firebase

struct User: Identifiable, Hashable, Codable {
    let id: String
    var username: String
    var profileImageUrl: String?
    var fullname: String?
    var bio: String?
    let email: String
    
    var isCurrentUser: Bool {
        guard let currentUid = Auth.auth().currentUser?.uid else { return false }
        return currentUid == id
    }
}

extension User {
    static var MOCK_USERS: [User] = [
        .init(id: NSUUID().uuidString, username: "skunsky", profileImageUrl: "example" , fullname: "Jacob Johnson", bio: "creator of broche", email: "test@gmail.com"),
        .init(id: NSUUID().uuidString, username: "batman", profileImageUrl: nil, fullname: "bruce wayne", bio: "gothoms dark knight", email: "batman@gmail.com"),
        .init(id: NSUUID().uuidString, username: "ironman", profileImageUrl: nil, fullname: "tony stark", bio: "catch you in the skys", email: "ironman@gmail.com"),
        .init(id: NSUUID().uuidString, username: "hulk", profileImageUrl: nil, fullname: "hulk baner smash", bio: "i like to smash things", email: "hulk@gmail.com"),
        .init(id: NSUUID().uuidString, username: "thor", profileImageUrl: nil, fullname: "thor asgard", bio: "god of thunder baby.", email: "thor@gmail.com")
    ]
}
