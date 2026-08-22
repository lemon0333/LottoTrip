//
//  HealthDTO.swift
//  LottoTrip
//
//  헬스 체크 응답 DTO. GET /health (인증 불필요)
//

import Foundation

/// 서버·DB 상태 (모니터링/배포 확인용)
struct HealthDTO: Decodable {
    let status: String    // "UP" / "DOWN" 등
    let db: String?       // DB 연결 상태
}
