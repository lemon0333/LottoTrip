//
//  RouteDTO.swift
//  LottoTrip
//
//  길찾기 도메인 DTO — 배포 백엔드(3.37.104.92) 계약 기준.
//  GET /route/slot/{slotId}(대중교통), /walk, /car
//

import Foundation

/// 대중교통 경로: { totalMinutes, payment, legs[] }
struct RouteResponseDTO: Decodable {
    let totalMinutes: Int
    let payment: Int?
    let legs: [RouteLegDTO]
}

struct RouteLegDTO: Decodable {
    let mode: String            // "BUS" / "SUBWAY" / "WALK" 등
    let routeName: String?      // "버스 92" 등
    let startName: String?
    let endName: String?
    let stationCount: Int?
    let sectionMinutes: Int?
}

/// 도보 경로: { totalMinutes, totalDistanceMeters }
struct WalkRouteDTO: Decodable {
    let totalMinutes: Int
    let totalDistanceMeters: Int?
}

/// 자동차 경로: { totalMinutes, totalDistanceMeters, tollFare, taxiFare }
struct CarRouteDTO: Decodable {
    let totalMinutes: Int
    let totalDistanceMeters: Double?
    let tollFare: Int?
    let taxiFare: Int?
}
