//
//  CommunityTargetType.swift
//  LottoTrip
//

import Foundation
import Moya

enum CommunityTargetType {
    case nearby(lat: Double, lng: Double, radius: Int)   // 위치기반 숏폼 피드
    case like(postId: String)
    case chatRooms                                       // 운명 공동체 채팅방 목록
}

extension CommunityTargetType: TargetType {
    var baseURL: URL { URL(string: Domain.communityURL)! }

    var path: String {
        switch self {
        case .nearby:            return "/nearby"
        case let .like(postId):  return "/posts/\(postId)/like"
        case .chatRooms:         return "/chat/rooms"
        }
    }

    var method: Moya.Method {
        switch self {
        case .like: return .post
        default:    return .get
        }
    }

    var task: Moya.Task {
        switch self {
        case let .nearby(lat, lng, radius):
            return .requestParameters(parameters: ["lat": lat, "lng": lng, "radius": radius],
                                      encoding: URLEncoding.queryString)
        case .like, .chatRooms:
            return .requestPlain
        }
    }

    var headers: [String: String]? { ["Content-Type": "application/json"] }
}
