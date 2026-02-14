//
//  UserModel.swift
//  CRUD-App
//

import Foundation

struct User: Codable, Identifiable {
    let id: Int?
    var name: String
    var email: String
    var phone: String?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case email
        case phone
    }
}
