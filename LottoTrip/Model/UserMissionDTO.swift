//
//  UserMissionDTO.swift
//  LottoTrip
//
//  미션 완료(인증) 도메인 DTO.
//  POST /missions/{missionId}/complete
//
//  ※ 인증 방식(사진/GPS)은 명세상 "논의 필요". 아래 요청 필드는 선택값으로 두어
//    서버 확정 시 손쉽게 반영할 수 있게 한다. 사진 인증은 선-업로드 후 URL 전달 가정.
//

import Foundation

/// POST /missions/{missionId}/complete 요청 바디 (전 필드 옵셔널)
struct MissionCompleteRequestDTO: Encodable {
    let certifiedMediaUrl: String?   // 업로드된 인증 사진/영상 URL
    let mType: MediaType?            // IMAGE / VIDEO
    let latitude: Double?            // GPS 인증용
    let longitude: Double?

    init(certifiedMediaUrl: String? = nil,
         mType: MediaType? = nil,
         latitude: Double? = nil,
         longitude: Double? = nil) {
        self.certifiedMediaUrl = certifiedMediaUrl
        self.mType = mType
        self.latitude = latitude
        self.longitude = longitude
    }
}

/// 미션 완료 처리 결과 (ERD user_missions)
struct UserMissionDTO: Decodable {
    let userMissionId: Int
    let missionId: Int
    let status: MissionStatus       // PENDING / SUCCESS / FAIL
    let certifiedMediaUrl: String?
    let rewardPoint: Int?
    let certifiedAt: String?
}
