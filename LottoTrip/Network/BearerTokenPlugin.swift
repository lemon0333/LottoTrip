//
//  BearerTokenPlugin.swift
//  LottoTrip
//
//  Archive-iOS 패턴: 요청마다 Authorization 헤더에 토큰 주입.
//

import Foundation
import Moya

/// 액세스 토큰 보관소 (간단히 UserDefaults 기반)
enum TokenStore {
    private static let key = "lottotrip.accessToken"
    static var accessToken: String? {
        get { UserDefaults.standard.string(forKey: key) }
        set { UserDefaults.standard.set(newValue, forKey: key) }
    }
    static func clear() { UserDefaults.standard.removeObject(forKey: key) }
}

struct BearerTokenPlugin: PluginType {
    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        var request = request
        if let token = TokenStore.accessToken, !token.isEmpty {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        return request
    }
}
