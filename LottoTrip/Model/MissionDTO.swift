//
//  MissionDTO.swift
//  LottoTrip
//

import Foundation

struct MissionDTO: Decodable {
    let id: String
    let placeName: String       // "강릉 아들바위공원"
    let narratorLine: String    // 산신령 가라사대: "...소원을 3초간 담아보세요"
    let rewardPoint: Int        // 200
    let couponTitle: String     // "강릉 시그니처 카페 쿠폰"

    init(id: String, placeName: String, narratorLine: String, rewardPoint: Int, couponTitle: String) {
        self.id = id; self.placeName = placeName; self.narratorLine = narratorLine
        self.rewardPoint = rewardPoint; self.couponTitle = couponTitle
    }
}

struct MissionVerifyRequestDTO: Encodable {
    let missionId: String
    // 실제 사진은 멀티파트(.uploadMultipart)로 별도 첨부
}
