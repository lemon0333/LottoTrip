//
//  AuthDTO.swift
//  LottoTrip
//
//  인증 도메인 DTO. (POST /auth/login, /auth/refresh, /auth/logout)
//

import Foundation

// MARK: - 요청

/// POST /auth/login — 소셜 토큰으로 서비스 토큰(JWT) 발급
struct LoginRequestDTO: Encodable {
    let provider: OAuthProvider    // 08-17: KAKAO / APPLE / GOOGLE (NAVER 폐기)
    let providerToken: String      // 소셜 SDK 로 받은 access token
    // TODO(미결): 애플 revoke(심사 필수) 붙일 시 authorizationCode 추가 필요
}

/// POST /auth/refresh — 리프레시 토큰으로 액세스 토큰 재발급
struct RefreshRequestDTO: Encodable {
    let refreshToken: String
}

// MARK: - 응답

/// 로그인/토큰 갱신 성공 시 반환되는 토큰 쌍
struct TokenDTO: Decodable {
    let accessToken: String
    let refreshToken: String?
}

/// 로그인 응답 (토큰 + 유저 정보). user 는 서버 구현에 따라 없을 수 있어 옵셔널.
struct LoginResponseDTO: Decodable {
    let accessToken: String
    let refreshToken: String?
    let user: UserDTO?
}

/// 사용자 (ERD users) — 08-17: email·nickname NULL 허용(애플 이메일가리기)
struct UserDTO: Decodable {
    let userId: Int
    let email: String?
    let nickname: String?
    let profileImageUrl: String?
    let createdAt: String?
}

/// DELETE /auth/me — 회원탈퇴 응답
struct WithdrawResponseDTO: Decodable {
    let deleted: Bool
    let deletedAt: String?
}
