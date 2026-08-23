//
//  ChatWireDTO.swift
//  LottoTrip
//
//  채팅 도메인 응답 DTO (REST — 목록/이력) — 실제 백엔드 계약 기준.
//  GET /chat/rooms, GET /chat/rooms/{roomId}/messages
//  ※ 실시간 송수신은 WebSocket(STOMP) 별도. UI 목업(ChatRoomVC)과 구분되는 와이어 모델.
//

import Foundation

// MARK: - GET /chat/rooms  →  { rooms: [...] }

struct ChatRoomListDTO: Decodable {
    let rooms: [ChatRoomSummaryDTO]
}

struct ChatRoomSummaryDTO: Decodable {
    let roomId: Int
    let placeName: String
    let memberCount: Int
}

// MARK: - GET /chat/rooms/{roomId}/messages  →  { messages: [...], nextCursor }

struct ChatMessagePageDTO: Decodable {
    let messages: [ChatMessageItemDTO]
    let nextCursor: String?
}

struct ChatMessageItemDTO: Decodable {
    let messageId: Int
    let senderId: Int?
    let nickname: String?
    let messageText: String
    let createdAt: String
}
