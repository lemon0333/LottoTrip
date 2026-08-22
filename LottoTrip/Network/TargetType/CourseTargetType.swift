//
//  CourseTargetType.swift
//  LottoTrip
//
//  여행 코스 도메인 엔드포인트.
//  GET /course/items, POST /course/items, DELETE /course/items/{itemId}
//

import Foundation
import Moya

enum CourseTargetType {
    case items                       // 코스 조회
    case add(slotId: Int)            // 코스에 추가
    case deleteItem(itemId: Int)     // 코스 항목 삭제
}

extension CourseTargetType: TargetType, AuthorizedTargetType {
    var baseURL: URL { URL(string: Domain.baseURL)! }

    var path: String {
        switch self {
        case .items:                  return "\(Domain.course)/items"
        case .add:                    return "\(Domain.course)/items"
        case let .deleteItem(itemId): return "\(Domain.course)/items/\(itemId)"
        }
    }

    var method: Moya.Method {
        switch self {
        case .items:      return .get
        case .add:        return .post
        case .deleteItem: return .delete
        }
    }

    var task: Moya.Task {
        switch self {
        case .items:
            return .requestPlain
        case let .add(slotId):
            return .requestJSONEncodable(AddCourseItemRequestDTO(slotId: slotId))
        case .deleteItem:
            return .requestPlain
        }
    }

    var headers: [String: String]? { ["Content-Type": "application/json"] }
}
