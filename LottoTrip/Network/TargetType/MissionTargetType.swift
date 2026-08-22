//
//  MissionTargetType.swift
//  LottoTrip
//
//  미션 도메인 엔드포인트.
//  POST /missions/{missionId}/complete
//

import Foundation
import Moya

enum MissionTargetType {
    case complete(missionId: Int, body: MissionCompleteRequestDTO?)
}

extension MissionTargetType: TargetType, AuthorizedTargetType {
    var baseURL: URL { URL(string: Domain.baseURL)! }

    var path: String {
        switch self {
        case let .complete(missionId, _):
            return "\(Domain.missions)/\(missionId)/complete"
        }
    }

    var method: Moya.Method { .post }

    var task: Moya.Task {
        switch self {
        case let .complete(_, body):
            if let body { return .requestJSONEncodable(body) }
            return .requestPlain
        }
    }

    var headers: [String: String]? { ["Content-Type": "application/json"] }
}
