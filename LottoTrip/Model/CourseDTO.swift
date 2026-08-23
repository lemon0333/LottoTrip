//
//  CourseDTO.swift
//  LottoTrip
//
//  여행 코스 도메인 DTO — 실제 백엔드 계약 기준.
//  GET /course/items, POST /course/items, DELETE /course/items/{itemId}
//

import Foundation

/// 코스에서 쓰는 장소 요약 (placeId, name 만)
struct CoursePlaceDTO: Decodable {
    let placeId: Int
    let name: String
}

/// 코스 항목에 딸린 미션 완료여부
struct CourseMissionDTO: Decodable {
    let missionId: Int
    let completed: Bool
}

// MARK: - POST /course/items

/// 요청: 슬롯(slotId)을 코스에 추가
struct AddCourseItemRequestDTO: Encodable {
    let slotId: Int
}

/// 추가 응답: { itemId, place, addedAt }
struct CourseItemResponseDTO: Decodable {
    let itemId: Int
    let place: CoursePlaceDTO
    let addedAt: String?
}

// MARK: - GET /course/items

/// 조회 응답: { items: [ { itemId, place, mission } ] }
struct CourseItemsResponseDTO: Decodable {
    let items: [CourseItemDTO]
}

struct CourseItemDTO: Decodable {
    let itemId: Int
    let place: CoursePlaceDTO
    let mission: CourseMissionDTO?
}

// MARK: - DELETE /course/items/{itemId}

/// 삭제 응답: { itemId, deleted }
struct CourseItemRemoveResponseDTO: Decodable {
    let itemId: Int
    let deleted: Bool
}
