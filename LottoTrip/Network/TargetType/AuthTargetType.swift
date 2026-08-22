//
//  AuthTargetType.swift
//  LottoTrip
//
//  인증 도메인 엔드포인트.
//  POST /auth/login·/refresh (인증 불필요), POST /auth/logout, DELETE /auth/me (회원탈퇴)
//

import Foundation
import Moya

enum AuthTargetType {
    case login(provider: OAuthProvider, providerToken: String)
    case refresh(refreshToken: String)
    case logout
    case withdraw   // 08-17 신설: DELETE /auth/me 회원탈퇴 (앱스토어 심사 필수)
}

extension AuthTargetType: TargetType, AuthorizedTargetType {
    var baseURL: URL { URL(string: Domain.baseURL)! }

    var path: String {
        switch self {
        case .login:    return "\(Domain.auth)/login"
        case .refresh:  return "\(Domain.auth)/refresh"
        case .logout:   return "\(Domain.auth)/logout"
        case .withdraw: return "\(Domain.auth)/me"
        }
    }

    var method: Moya.Method {
        switch self {
        case .withdraw: return .delete
        default:        return .post
        }
    }

    var task: Moya.Task {
        switch self {
        case let .login(provider, providerToken):
            return .requestJSONEncodable(LoginRequestDTO(provider: provider, providerToken: providerToken))
        case let .refresh(refreshToken):
            return .requestJSONEncodable(RefreshRequestDTO(refreshToken: refreshToken))
        case .logout, .withdraw:
            return .requestPlain
        }
    }

    var headers: [String: String]? { ["Content-Type": "application/json"] }

    /// login/refresh 는 액세스 토큰 없이 호출, logout·withdraw 는 Authorization 필요
    var requiresAuth: Bool {
        switch self {
        case .login, .refresh:   return false
        case .logout, .withdraw: return true
        }
    }
}
