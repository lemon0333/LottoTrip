//
//  BearerTokenPlugin.swift
//  LottoTrip
//
//  요청마다 Authorization 헤더에 Bearer 액세스 토큰을 주입한다.
//  (명세서 공통 헤더: `Authorization: Bearer {accessToken}` — 인증 필요한 API 한함)
//

import Foundation
import Moya

/// 토큰 보관소.
///
/// - Note: 데모 편의를 위해 UserDefaults 를 사용한다. 실제 배포에서는
///   accessToken/refreshToken 을 Keychain 에 저장하도록 교체할 것.
public enum TokenStore {
    private static let accessKey  = "lottotrip.accessToken"
    private static let refreshKey = "lottotrip.refreshToken"

    public static var accessToken: String? {
        get { UserDefaults.standard.string(forKey: accessKey) }
        set { UserDefaults.standard.set(newValue, forKey: accessKey) }
    }

    public static var refreshToken: String? {
        get { UserDefaults.standard.string(forKey: refreshKey) }
        set { UserDefaults.standard.set(newValue, forKey: refreshKey) }
    }

    public static var isLoggedIn: Bool {
        !(accessToken ?? "").isEmpty
    }

    /// 로그인 성공/토큰 갱신 시 한번에 갱신
    public static func save(accessToken: String, refreshToken: String?) {
        self.accessToken = accessToken
        if let refreshToken { self.refreshToken = refreshToken }
    }

    /// 로그아웃 시 전부 제거
    public static func clear() {
        UserDefaults.standard.removeObject(forKey: accessKey)
        UserDefaults.standard.removeObject(forKey: refreshKey)
    }
}

/// 인증 헤더 필요 여부를 TargetType 이 스스로 알린다.
/// (login/refresh/health 처럼 인증 불필요 엔드포인트는 false 로 오버라이드)
protocol AuthorizedTargetType {
    var requiresAuth: Bool { get }
}

extension AuthorizedTargetType {
    var requiresAuth: Bool { true }   // 기본값: 인증 필요
}

struct BearerTokenPlugin: PluginType {
    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        var request = request

        // 인증 불필요 엔드포인트면 헤더 주입 생략
        if let authorizable = target as? AuthorizedTargetType, authorizable.requiresAuth == false {
            return request
        }

        if let token = TokenStore.accessToken, !token.isEmpty {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        return request
    }
}
