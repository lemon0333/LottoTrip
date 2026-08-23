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

    /// 미션 완료 처리 — GPS 인증(허용 반경 500m). 현재 위치를 보낸다.
    func complete(missionId: Int, latitude: Double, longitude: Double,
                  completion: @escaping (Result<MissionCompleteResponseDTO, NetworkError>) -> Void) {
        let body = MissionCompleteRequestDTO(latitude: latitude, longitude: longitude)
        request(target: .complete(missionId: missionId, body: body),
                decodingType: MissionCompleteResponseDTO.self, completion: completion)
    }
}
