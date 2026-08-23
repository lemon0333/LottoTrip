//
//  SlotDTO.swift
//  LottoTrip
//
//  랜덤 장소(슬롯) 도메인 DTO — 실제 백엔드(yoonaji/lottotrip_be) 계약 기준.
//  POST /slot/draw, GET /slot/results/{slotId}
//

import Foundation

// MARK: - 요청

/// POST /slot/draw
/// - budget: 예산 "원 정수"(enum 아님, 0 이상)
/// - transport: "WALK" / "CAR"
/// - accessible: 무장애 필터(미전송 시 서버 false)
/// - contentTypeId: 장소종류 필터(문자열, nil=전체)
struct SlotDrawRequestDTO: Encodable {
    let latitude: Double
    let longitude: Double
    let budget: Int
    let transport: TransportType
    let accessible: Bool?
    let contentTypeId: String?

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

// MARK: - 응답 공통

/// 슬롯 결과에 딸린 미션 요약 (draw/result 공통)
struct SlotMissionDTO: Decodable {
    let missionId: Int
    let title: String
}

// MARK: - POST /slot/draw 응답

/// 뽑기 응답 place — 간단형(거리·썸네일 포함, 주소·소개 없음)
struct DrawPlaceDTO: Decodable {
    let placeId: Int
    let name: String
    let category: String       // 한글 displayName 그대로
    let latitude: Double?
    let longitude: Double?
    let distanceKm: Double?
    let thumbnailUrl: String?
}

struct SlotDrawResponseDTO: Decodable {
    let slotId: Int
    let place: DrawPlaceDTO
    let mission: SlotMissionDTO?
}

// MARK: - GET /slot/results/{slotId} 응답

/// 상세 조회 place — 주소·소개·홈페이지 포함(TourAPI 실시간). 영업시간/전화/메뉴/후기는 백엔드에 없음.
struct PlaceDetailDTO: Decodable {
    let placeId: Int
    let name: String
    let category: String
    let latitude: Double?
    let longitude: Double?
    let address: String?
    let description: String?
    let homepageUrl: String?
    let liveDetailLoaded: Bool?
}

struct SlotResultResponseDTO: Decodable {
    let slotId: Int
    let place: PlaceDetailDTO
    let mission: SlotMissionDTO?
}
