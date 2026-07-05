//
//  RecommendTargetType.swift
//  LottoTrip
//

import Foundation
import Moya

enum RecommendTargetType {
    case spin(RecommendRequestDTO)      // 취향 기반 랜덤 목적지
    case reroll(sessionId: String)      // 다시 돌리기
}

extension RecommendTargetType: TargetType {
    var baseURL: URL { URL(string: Domain.recommendURL)! }

    var path: String {
        switch self {
        case .spin:   return "/spin"
        case .reroll: return "/reroll"
        }
    }

    var method: Moya.Method { .post }

    var task: Moya.Task {
        switch self {
        case let .spin(dto):
            return .requestJSONEncodable(dto)
        case let .reroll(sessionId):
            return .requestParameters(parameters: ["sessionId": sessionId], encoding: JSONEncoding.default)
        }
    }

    var headers: [String: String]? { ["Content-Type": "application/json"] }
}
