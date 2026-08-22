//
//  HealthTargetType.swift
//  LottoTrip
//
//  헬스 체크 엔드포인트. GET /health (인증 불필요)
//

import Foundation
import Moya

enum HealthTargetType {
    case check
}

extension HealthTargetType: TargetType, AuthorizedTargetType {
    var baseURL: URL { URL(string: Domain.baseURL)! }
    var path: String { Domain.health }
    var method: Moya.Method { .get }
    var task: Moya.Task { .requestPlain }
    var headers: [String: String]? { ["Content-Type": "application/json"] }
    var requiresAuth: Bool { false }
}
