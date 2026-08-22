//
//  ChatWireDTO.swift
//  LottoTrip
//
//  채팅 도메인 응답 DTO (REST — 목록/이력 조회 전용).
//  GET /chat/rooms, GET /chat/rooms/{roomId}/messages
//
//  ※ 실시간 송수신은 WebSocket(STOMP) 별도. 여기서는 과거 데이터 조회만 다룬다.
//  ※ UI 목업용 ChatRoomDTO/ChatMessageDTO(CommunityDTO.swift)와 구분되는 서버 와이어 모델.
//

import Foundation

/// 채팅방 요약 (ERD chat_rooms) — 목록 항목
struct ChatRoomSummaryDTO: Decodable {
    let roomId: Int
    let title: String
    let memberCount: Int?
    let lastMessage: String?
    let lastMessageAt: String?
    let createdAt: String?
}

/// 채팅 이력 페이지 (커서 기반 페이징)
struct ChatMessagePageDTO: Decodable {
    let messages: [ChatMessageItemDTO]
    let nextCursor: String?
    let hasNext: Bool?
}

/// 채팅 메시지 (ERD chat_messages)
struct ChatMessageItemDTO: Decodable {
    let messageId: Int
    let roomId: Int
    let userId: Int?          // 시스템/탈퇴 유저는 null 가능(set null)
    let senderNickname: String?
    let messageText: String
    let createdAt: String
}
