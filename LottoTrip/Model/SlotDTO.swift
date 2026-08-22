//
//  SlotDTO.swift
//  LottoTrip
//
//  랜덤 장소(슬롯) 도메인 DTO.
//  POST /slot/draw, GET /slot/results/{slotId}
//

import Foundation

/// POST /slot/draw — GPS·예산·이동수단 기반 랜덤 목적지 1곳 + 미션 요청
struct SlotDrawRequestDTO: Encodable {
    let latitude: Double
    let longitude: Double
    let budget: BudgetLevel        // LOW / MEDIUM / HIGH
    let transport: TransportType   // WALK / CAR
    let accessible: Bool?          // 08-17 선택: 무장애 필터 (nil=미적용)
    let contentTypeId: Int?        // 08-17 선택: 장소종류 필터 (nil=전체; 숙박 32는 서버가 항상 제외)

    // nil 필드는 전송에서 생략 (서버는 미전송=미적용으로 처리)
    enum CodingKeys: String, CodingKey {
        case latitude, longitude, budget, transport, accessible, contentTypeId
    }
    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(latitude, forKey: .latitude)
        try c.encode(longitude, forKey: .longitude)
        try c.encode(budget, forKey: .budget)
        try c.encode(transport, forKey: .transport)
        try c.encodeIfPresent(accessible, forKey: .accessible)
        try c.encodeIfPresent(contentTypeId, forKey: .contentTypeId)
    }
}

/// 슬롯 결과 (draw 응답 / results 조회 공통) — 08-17: SlotResult→SavedSlot, resultId→slotId
struct SavedSlotDTO: Decodable {
    let slotId: Int
    let place: PlaceDTO
    let mission: MissionInfoDTO?
    let createdAt: String?
}
