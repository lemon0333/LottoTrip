//
//  MissionService.swift
//  LottoTrip
//
//  미션 도메인 서비스.
//

import Foundation
import Moya

final class MissionService: NetworkManager {
    typealias Endpoint = MissionTargetType
    let provider: MoyaProvider<MissionTargetType>

    init(provider: MoyaProvider<MissionTargetType> = MoyaProvider<MissionTargetType>(plugins: [BearerTokenPlugin()])) {
        self.provider = provider
    }

    /// 미션 완료 처리 — 08-17: GPS 인증 확정(허용 반경 500m). 현재 위치를 필수로 보낸다.
    /// - Parameter mediaUrl: 선택 인증샷 URL(선업로드). GPS만으로 완료되므로 보통 nil.
    func complete(missionId: Int, latitude: Double, longitude: Double,
                  mediaUrl: String? = nil,
                  completion: @escaping (Result<UserMissionDTO, NetworkError>) -> Void) {
        let body = MissionCompleteRequestDTO(
            certifiedMediaUrl: mediaUrl,
            mType: mediaUrl == nil ? nil : .image,
            latitude: latitude, longitude: longitude)
        request(target: .complete(missionId: missionId, body: body),
                decodingType: UserMissionDTO.self, completion: completion)
    }
}
