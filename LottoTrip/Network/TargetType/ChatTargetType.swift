//
//  ChatTargetType.swift
//  LottoTrip
//
//  채팅 도메인 엔드포인트 (REST — 목록/이력 조회).
//  GET /chat/rooms, GET /chat/rooms/{roomId}/messages
//  ※ 실시간 송수신은 WebSocket(STOMP) 별도.
//

import Foundation
import Moya

enum ChatTargetType {
    case rooms                                              // 채팅방 목록
    case messages(roomId: Int, cursor: String?, size: Int?) // 채팅 이력(페이징)
}

extension ChatTargetType: TargetType, AuthorizedTargetType {
    var baseURL: URL { URL(string: Domain.baseURL)! }

    var path: String {
        switch self {
        case .rooms:
            return "\(Domain.chat)/rooms"
        case let .messages(roomId, _, _):
            return "\(Domain.chat)/rooms/\(roomId)/messages"
        }
    }

    var method: Moya.Method { .get }

    var task: Moya.Task {
        switch self {
        case .rooms:
            return .requestPlain
        case let .messages(_, cursor, size):
            var params: [String: Any] = [:]
            if let cursor { params["cursor"] = cursor }
            if let size { params["size"] = size }
            if params.isEmpty { return .requestPlain }
            return .requestParameters(parameters: params, encoding: URLEncoding.queryString)
        }
    }

    var headers: [String: String]? { ["Content-Type": "application/json"] }
}
