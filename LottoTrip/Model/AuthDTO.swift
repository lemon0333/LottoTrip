//
//  AuthDTO.swift
//  LottoTrip
//
//  인증 도메인 DTO — 실제 백엔드 계약 기준.
//  POST /auth/login, /auth/refresh, /auth/logout, DELETE /auth/me
//

import Foundation

// MARK: - 요청

/// POST /auth/login — provider 는 "KAKAO" / "APPLE" / "GOOGLE"
struct LoginRequestDTO: Encodable {
    let provider: OAuthProvider
    let providerToken: String
    // TODO(미결): 애플 revoke(심사 필수) 시 authorizationCode 추가
}

/// POST /auth/refresh
struct RefreshRequestDTO: Encodable {
    let refreshToken: String
}

// MARK: - 응답

/// 로그인 응답: { accessToken, refreshToken, user }
struct LoginResponseDTO: Decodable {
    let accessToken: String
    let refreshToken: String?
    let user: UserInfoDTO?
}

/// 로그인 유저 정보: { userId, nickname, isNewUser }
struct UserInfoDTO: Decodable {
    let userId: Int
    let nickname: String?
    let isNewUser: Bool?
}

/// 토큰 갱신 응답: { accessToken } (refreshToken 재발급 없음)
struct RefreshResponseDTO: Decodable {
    let accessToken: String
}

/// 회원탈퇴 응답: { deleted, deletedAt }
struct WithdrawResponseDTO: Decodable {
    let deleted: Bool
    let deletedAt: String?
}
