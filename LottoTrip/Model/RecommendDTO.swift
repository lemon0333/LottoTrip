//
//  RecommendDTO.swift
//  LottoTrip
//
//  슬롯 랜덤 추천 (예산·이동수단·좌표 → 강원 목적지)
//

import Foundation

enum TravelMode: String, Codable {
    case walk   // 뚜벅이 (반경 1km + 무장애)
    case car    // 자차 (반경 20km 드라이브)
}

struct RecommendRequestDTO: Encodable {
    let budget: Int
    let mode: TravelMode
    let lat: Double
    let lng: Double
    let styles: [String]   // 감성카페 / 포토스팟 ...
}

struct DestinationDTO: Decodable {
    let id: String
    let name: String          // "강릉 아들바위공원"
    let regionId: String      // 퍼즐 조각 매핑 (예: "gangneung")
    let category: String      // "바다 · 절경 · 소원 명소"
    let distanceKm: Double
    let budget: Int
    let hidden: Bool          // 숨은 명소(롱테일) 여부
    let missionTitle: String  // "아들바위 소원 3초 촬영"
}
