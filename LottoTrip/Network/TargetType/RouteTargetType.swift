//
//  RouteTargetType.swift
//  LottoTrip
//
//  길찾기 도메인 엔드포인트.
//  GET /route/slot/{slotId}(대중교통), /route/slot/{slotId}/walk, /route/slot/{slotId}/car
//

import Foundation
import Moya

enum RouteTargetType {
    case transit(slotId: Int)   // 대중교통
    case walk(slotId: Int)      // 도보
    case car(slotId: Int)       // 자동차
}

extension RouteTargetType: TargetType, AuthorizedTargetType {
    var baseURL: URL { URL(string: Domain.baseURL)! }

    var path: String {
        switch self {
        case let .transit(slotId): return "/route/slot/\(slotId)"
        case let .walk(slotId):    return "/route/slot/\(slotId)/walk"
        case let .car(slotId):     return "/route/slot/\(slotId)/car"
        }
    }

    var method: Moya.Method { .get }
    var task: Moya.Task { .requestPlain }
    var headers: [String: String]? { ["Content-Type": "application/json"] }
}
