//
//  Domain.swift
//  LottoTrip
//
//  API 명세서 기준 baseURL + 도메인별 경로 상수.
//  모든 엔드포인트는 https://api.lottotrip.com/api/v1 하위에 존재한다.
//

import Foundation

public enum Domain {
    /// 공통 베이스 URL.
    /// 기본값은 운영 도메인이며, `API_BASE_URL` 환경변수로 오버라이드 가능
    /// (로컬 목 서버/스테이징 전환용 — 예: http://localhost:8080/api/v1)
    public static let baseURL: String =
        ProcessInfo.processInfo.environment["API_BASE_URL"] ?? "https://api.lottotrip.com/api/v1"

    // 도메인별 prefix (TargetType.path 조합용)
    public static let auth      = "/auth"       // 인증
    public static let slot      = "/slot"       // 랜덤 장소(슬롯)
    public static let course    = "/course"     // 여행 코스
    public static let missions  = "/missions"   // 미션
    public static let video     = "/video"      // 숏폼 생성
    public static let chat      = "/chat"       // 채팅
    public static let health    = "/health"     // 헬스 체크
}
