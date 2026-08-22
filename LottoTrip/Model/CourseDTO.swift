//
//  CourseDTO.swift
//  LottoTrip
//
//  여행 코스 도메인 DTO.
//  GET /course/items, POST /course/items, DELETE /course/items/{itemId}
//

import Foundation

/// POST /course/items — 슬롯(SavedSlot)을 코스에 추가. 08-17: resultId→slotId
struct AddCourseItemRequestDTO: Encodable {
    let slotId: Int
}

/// 코스 항목 (ERD course_items) — place 상세 + 미션 완료여부 포함
struct CourseItemDTO: Decodable {
    let itemId: Int
    let courseId: Int?
    let slotId: Int?             // 08-17 추가: 어느 슬롯에서 담았는지
    let placeId: Int
    let sequence: Int
    let place: PlaceDTO?
    let mission: CourseMissionDTO?  // 08-17 추가: items[].mission = {missionId, completed}
    let addedAt: String?
}

/// 코스 항목에 딸린 미션 요약 (GET /course/items)
struct CourseMissionDTO: Decodable {
    let missionId: Int
    let completed: Bool
}
