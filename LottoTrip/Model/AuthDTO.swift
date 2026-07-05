//
//  AuthDTO.swift
//  LottoTrip
//

import Foundation

struct LoginResponseDTO: Decodable {
    let accessToken: String
    let refreshToken: String?
    let user: UserDTO
}

struct UserDTO: Decodable {
    let id: Int
    let nickname: String
    let profileImageURL: String?
}

struct SignupRequestDTO: Encodable {
    let provider: String   // kakao / apple / google
    let token: String
    let nickname: String
}
