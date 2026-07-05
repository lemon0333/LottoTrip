//
//  MissionService.swift
//  LottoTrip
//

import Foundation
import Moya

final class MissionService: NetworkManager {
    typealias Endpoint = MissionTargetType
    let provider: MoyaProvider<MissionTargetType>

    init(provider: MoyaProvider<MissionTargetType> = MoyaProvider<MissionTargetType>(plugins: [BearerTokenPlugin()])) {
        self.provider = provider
    }

    func current(placeId: String, completion: @escaping (Result<MissionDTO, NetworkError>) -> Void) {
        request(target: .current(placeId: placeId), decodingType: MissionDTO.self, completion: completion)
    }

    func verify(missionId: String, imageData: Data, completion: @escaping (Result<Void, NetworkError>) -> Void) {
        requestStatusCode(target: .verify(missionId: missionId, imageData: imageData), completion: completion)
    }

    func history(completion: @escaping (Result<[MissionDTO], NetworkError>) -> Void) {
        request(target: .history, decodingType: [MissionDTO].self, completion: completion)
    }
}
