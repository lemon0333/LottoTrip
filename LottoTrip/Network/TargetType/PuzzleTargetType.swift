//
//  PuzzleTargetType.swift
//  LottoTrip
//

import Foundation
import Moya

enum PuzzleTargetType {
    case progress                    // 전체 조각 상태
    case region(id: String)          // 권역 상세
    case claim(regionId: String)     // 조각 획득(인증 성공)
}

extension PuzzleTargetType: TargetType {
    var baseURL: URL { URL(string: Domain.puzzleURL)! }

    var path: String {
        switch self {
        case .progress:          return "/progress"
        case let .region(id):    return "/region/\(id)"
        case .claim:             return "/piece/claim"
        }
    }

    var method: Moya.Method {
        switch self {
        case .claim: return .post
        default:     return .get
        }
    }

    var task: Moya.Task {
        switch self {
        case .progress, .region:
            return .requestPlain
        case let .claim(regionId):
            return .requestParameters(parameters: ["regionId": regionId], encoding: JSONEncoding.default)
        }
    }

    var headers: [String: String]? { ["Content-Type": "application/json"] }
}
