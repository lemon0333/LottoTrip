//
//  UserMissionDTO.swift
//  LottoTrip
//
//  미션 완료(GPS 인증) 도메인 DTO — 실제 백엔드 계약 기준.
//  POST /missions/{missionId}/complete
//

import Foundation

/// POST /missions/{missionId}/complete 요청 바디 — GPS 좌표만(필수).
struct MissionCompleteRequestDTO: Encodable {
    let latitude: Double
    let longitude: Double
}

/// 미션 완료 처리 결과 — { missionId, completed, completedAt }
struct MissionCompleteResponseDTO: Decodable {
    let missionId: Int
    let completed: Bool
    let completedAt: String?
}
