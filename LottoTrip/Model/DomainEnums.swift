//
//  DomainEnums.swift
//  LottoTrip
//
//  ERD 정의 enum 미러 (백엔드 PostgreSQL enum 과 문자열 일치).
//  Codable 이므로 요청/응답 양방향에 그대로 사용한다.
//

import Foundation

/// 소셜 로그인 제공자 (oauth_provider)
public enum OAuthProvider: String, Codable {
    case kakao  = "KAKAO"
    case naver  = "NAVER"
    case google = "GOOGLE"
}

/// 여행 카테고리 (travel_category)
public enum TravelCategory: String, Codable {
    case food     = "FOOD"
    case activity = "ACTIVITY"
    case nature   = "NATURE"
    case culture  = "CULTURE"
    case shopping = "SHOPPING"
}

/// 이동 수단 (transport_type) — 08-17 변경: WALK/CAR 2종
public enum TransportType: String, Codable {
    case walk = "WALK"   // 뚜벅이(택시 가정) — 검색 반경 10km
    case car  = "CAR"    // 자차 — 검색 반경 30km
}

/// 미디어 타입 (media_type)
public enum MediaType: String, Codable {
    case image = "IMAGE"
    case video = "VIDEO"
}

/// 비동기 작업 상태 (job_status) — 숏폼 렌더링
public enum JobStatus: String, Codable {
    case processing = "PROCESSING"
    case completed  = "COMPLETED"
    case failed     = "FAILED"
}

/// 미션 인증 상태 (mission_status)
public enum MissionStatus: String, Codable {
    case pending = "PENDING"
    case success = "SUCCESS"
    case fail    = "FAIL"
}

/// 예산 수준 (budget_level)
public enum BudgetLevel: String, Codable {
    case low    = "LOW"
    case medium = "MEDIUM"
    case high   = "HIGH"
}

/// 좌표 (POINT) — 위경도 표현
public struct Coordinate: Codable {
    public let latitude: Double
    public let longitude: Double

    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
}
