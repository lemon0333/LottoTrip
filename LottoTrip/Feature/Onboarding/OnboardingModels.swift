//
//  OnboardingModels.swift
//  LottoTrip
//
//  취향 설정(온보딩) 위저드에서 수집하는 값 + 슬롯 요청으로의 매핑.
//

import Foundation

// MARK: - 여행 스타일 (최대 2개 중복 선택)

enum TravelStyle: String, CaseIterable {
    case rest       // 휴식형
    case food       // 맛집형
    case sightsee   // 감상형
    case experience // 체험형
    case active     // 활동형
    case explore    // 탐험형

    /// 한글 자음 배지 (ㄱ~ㅂ)
    var badge: String {
        switch self {
        case .rest: return "ㄱ"; case .food: return "ㄴ"; case .sightsee: return "ㄷ"
        case .experience: return "ㄹ"; case .active: return "ㅁ"; case .explore: return "ㅂ"
        }
    }
    var title: String {
        switch self {
        case .rest: return "휴식형"; case .food: return "맛집형"; case .sightsee: return "감상형"
        case .experience: return "체험형"; case .active: return "활동형"; case .explore: return "탐험형"
        }
    }
    var desc: String {
        switch self {
        case .rest: return "푹 쉬고 싶어"
        case .food: return "맛있는걸 먹고 싶어"
        case .sightsee: return "여기저기 구경하고 싶어"
        case .experience: return "체험 활동을 하고 싶어"
        case .active: return "활동적으로 놀고 싶어"
        case .explore: return "새로운 곳을 가고 싶어"
        }
    }
    /// 백엔드 travel_category 매핑 (참고용)
    var category: TravelCategory {
        switch self {
        case .rest: return .nature; case .food: return .food; case .sightsee: return .culture
        case .experience: return .activity; case .active: return .activity; case .explore: return .nature
        }
    }
}

// MARK: - 이동수단 (단일 선택)

enum TransportOption: String, CaseIterable {
    case walk    // 도보
    case transit // 대중교통
    case bike    // 자전거
    case car     // 자동차

    var title: String {
        switch self {
        case .walk: return "도보"; case .transit: return "대중교통"
        case .bike: return "자전거"; case .car: return "자동차"
        }
    }
    /// 백엔드 transport_type(WALK 10km / CAR 30km) 매핑.
    /// ⚠️ 온보딩 4종을 2종으로 압축 — 근거리(도보/자전거)=WALK, 원거리(대중교통/자동차)=CAR.
    ///    (대중교통·자전거의 정확한 매핑은 팀 확정 필요 — [[lottotrip-backend-changes]] 미결 #1)
    var transportType: TransportType {
        switch self {
        case .walk, .bike:   return .walk
        case .transit, .car: return .car
        }
    }
}

// MARK: - 온보딩 수집 상태

struct TripPreference {
    var styles: [TravelStyle] = []
    var durationDays: Int = 2
    var budgetWon: Int = 0
    var transport: TransportOption?
    var accommodationAddress: String = ""

    /// 예산(원) → 백엔드 budget_level 매핑
    var budgetLevel: BudgetLevel {
        switch budgetWon {
        case ..<80_000:   return .low
        case ..<200_000:  return .medium
        default:          return .high
        }
    }
}

/// 앱 전역 취향 저장소. 온보딩 완료 시 채워지고 슬롯 요청에서 읽힌다.
final class TripPreferenceStore {
    static let shared = TripPreferenceStore()
    private init() {}
    var current = TripPreference()
}
