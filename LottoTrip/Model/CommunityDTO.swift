//
//  CommunityDTO.swift
//  LottoTrip
//

import Foundation

struct CommunityPostDTO: Decodable {
    let id: String
    let placeName: String
    let distanceText: String   // "120m"
    let likes: Int
    let comments: Int

    init(id: String, placeName: String, distanceText: String, likes: Int, comments: Int) {
        self.id = id; self.placeName = placeName; self.distanceText = distanceText
        self.likes = likes; self.comments = comments
    }
}

struct ChatRoomDTO: Decodable {
    let id: String
    let title: String          // "강릉 아들바위行 운명 공동체"
    let memberCount: Int
}

struct ChatMessageDTO: Decodable {
    let id: String
    let sender: String
    let text: String
    let isMine: Bool
    let isSystem: Bool

    init(id: String, sender: String, text: String, isMine: Bool, isSystem: Bool) {
        self.id = id; self.sender = sender; self.text = text
        self.isMine = isMine; self.isSystem = isSystem
    }
}
