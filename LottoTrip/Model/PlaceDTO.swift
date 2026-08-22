//
//  PlaceDTO.swift
//  LottoTrip
//
//  장소/미디어/미션 공용 응답 DTO (ERD places / place_media / missions).
//  슬롯 결과·코스 항목 등 여러 도메인에서 공유한다.
//

import Foundation

/// 장소 (ERD places)
struct PlaceDTO: Decodable {
    let placeId: Int
    let cityId: Int?              // ERD: NULL 허용
    let name: String
    let description: String?
    /// 08-17: 자체 5종 → TourAPI cat2 25종+UNKNOWN. 값 체계가 유동적이라 문자열로 그대로 받는다
    /// (서버가 한글 카테고리명을 내려줌. 예: "자연관광지", "음식점").
    let category: String
    let address: String
    /// 좌표 — 중첩 `coordinate` 객체 또는 flat `latitude`/`longitude` 어느 쪽이 와도 파싱.
    /// (백엔드가 POINT ↔ lat/lng 를 오갈 수 있어 방어적으로 처리. 값이 없으면 nil)
    let coordinate: Coordinate?
    let budgetTier: BudgetLevel? // ERD: NULL 허용
    let publicTransportWeight: Int?
    let media: [PlaceMediaDTO]?

    // TourAPI 연동 필드 (ERD 추가분 — 있으면 활용, 없으면 무시)
    let contentId: String?       // TourAPI 콘텐츠 ID
    let contentTypeId: Int?      // 관광타입 코드 (12=관광지, 39=음식점 …)
    let modifiedTime: String?    // TourAPI 최종 수정일시 (배치 갱신 기준)

    enum CodingKeys: String, CodingKey {
        case placeId, cityId, name, description, category, address
        case coordinate, latitude, longitude
        case budgetTier, publicTransportWeight, media
        case contentId, contentTypeId, modifiedTime
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        placeId = try c.decode(Int.self, forKey: .placeId)
        cityId = try c.decodeIfPresent(Int.self, forKey: .cityId)
        name = try c.decode(String.self, forKey: .name)
        description = try c.decodeIfPresent(String.self, forKey: .description)
        category = try c.decodeIfPresent(String.self, forKey: .category) ?? "UNKNOWN"
        // address: 08-17 NULL 허용으로 완화 → 없으면 빈 문자열
        address = try c.decodeIfPresent(String.self, forKey: .address) ?? ""

        // 좌표: 중첩 coordinate 우선, 없으면 flat latitude/longitude, 둘 다 없으면 nil
        if let nested = try c.decodeIfPresent(Coordinate.self, forKey: .coordinate) {
            coordinate = nested
        } else if let lat = try c.decodeIfPresent(Double.self, forKey: .latitude),
                  let lng = try c.decodeIfPresent(Double.self, forKey: .longitude) {
            coordinate = Coordinate(latitude: lat, longitude: lng)
        } else {
            coordinate = nil
        }

        budgetTier = try c.decodeIfPresent(BudgetLevel.self, forKey: .budgetTier)
        publicTransportWeight = try c.decodeIfPresent(Int.self, forKey: .publicTransportWeight)
        media = try c.decodeIfPresent([PlaceMediaDTO].self, forKey: .media)
        contentId = try c.decodeIfPresent(String.self, forKey: .contentId)
        contentTypeId = try c.decodeIfPresent(Int.self, forKey: .contentTypeId)
        modifiedTime = try c.decodeIfPresent(String.self, forKey: .modifiedTime)
    }
}

/// 장소 미디어 (ERD place_media)
struct PlaceMediaDTO: Decodable {
    let mediaId: Int
    let mediaUrl: String
    let mType: MediaType
}

/// 미션 정보 (ERD missions) — 슬롯 결과에 딸려오는 미션
struct MissionInfoDTO: Decodable {
    let missionId: Int
    let placeId: Int?
    let title: String
    let guideDescription: String?
    let guideImageUrl: String
    let rewardPoint: Int
}
