//
//  SlotTargetType.swift
//  LottoTrip
//
//  랜덤 장소(슬롯) 도메인 엔드포인트.
//  POST /slot/draw, GET /slot/results/{resultId}
//

import Foundation
import Moya

enum SlotTargetType {
    case draw(SlotDrawRequestDTO)
    case result(slotId: Int)
}

extension SlotTargetType: TargetType, AuthorizedTargetType {
    var baseURL: URL { URL(string: Domain.baseURL)! }

    var path: String {
        switch self {
        case .draw:               return "\(Domain.slot)/draw"
        case let .result(slotId): return "\(Domain.slot)/results/\(slotId)"
        }
    }

    var method: Moya.Method {
        switch self {
        case .draw:   return .post
        case .result: return .get
        }
    }

    var task: Moya.Task {
        switch self {
        case let .draw(dto): return .requestJSONEncodable(dto)
        case .result:        return .requestPlain
        }
    }

    var headers: [String: String]? { ["Content-Type": "application/json"] }
}
