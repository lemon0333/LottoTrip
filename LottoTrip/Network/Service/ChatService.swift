//
//  ChatService.swift
//  LottoTrip
//
//  채팅 도메인 서비스 (REST — 목록/이력 조회).
//  ※ 실시간 송수신은 WebSocket(STOMP) 별도 구현 필요.
//

import Foundation
import Moya

final class ChatService: NetworkManager {
    typealias Endpoint = ChatTargetType
    let provider: MoyaProvider<ChatTargetType>

    init(provider: MoyaProvider<ChatTargetType> = MoyaProvider<ChatTargetType>(plugins: [BearerTokenPlugin()])) {
        self.provider = provider
    }

    /// 채팅방 목록 조회 — 내가 배정된 운명 공동체 방
    func rooms(completion: @escaping (Result<[ChatRoomSummaryDTO], NetworkError>) -> Void) {
        request(target: .rooms, decodingType: [ChatRoomSummaryDTO].self, completion: completion)
    }

    /// 채팅 이력 조회 — 특정 방의 지난 메시지 (커서 페이징)
    func messages(roomId: Int, cursor: String? = nil, size: Int? = nil,
                  completion: @escaping (Result<ChatMessagePageDTO, NetworkError>) -> Void) {
        request(target: .messages(roomId: roomId, cursor: cursor, size: size),
                decodingType: ChatMessagePageDTO.self, completion: completion)
    }
}
