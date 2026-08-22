//
//  PlaceDetailModels.swift
//  LottoTrip
//
//  목적지 상세 화면 로컬 모델 + 목업 샘플 (API 미연동).
//

import Foundation

/// 목적지 상세 정보 모델 (아직 API 없음 · 목업)
struct PlaceDetail {
    let name: String            // 장소명
    let openStatus: String      // 영업 상태 (예: "영업 중")
    let reviewCount: Int        // 방문자 후기 수
    let address: String         // 지번/전체 주소
    let roadAddress: String     // 도로명 주소
    let zipCode: String         // 우편번호
    let phone: String           // 전화번호 (없으면 placeholder)
    let hours: String           // 영업시간
    let menus: [String]         // 메뉴 이름 목록
}

/// 상세 화면용 샘플 데이터
enum PlaceDetailSampleData {
    static let sample = PlaceDetail(
        name: "강원도막걸리술빵",
        openStatus: "영업 중",
        reviewCount: 3,
        address: "강원 속초시 중앙시장로6길 14 54번",
        roadAddress: "강원 속초시 중앙동 471-5",
        zipCode: "24832",
        phone: "전화번호",
        hours: "09:00 - 19:00",
        menus: ["이름", "이름", "이름", "이름"]
    )
}
