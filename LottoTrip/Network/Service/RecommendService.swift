//
//  RecommendService.swift
//  LottoTrip
//

import Foundation
import Moya

final class RecommendService: NetworkManager {
    typealias Endpoint = RecommendTargetType
    let provider: MoyaProvider<RecommendTargetType>

    init(provider: MoyaProvider<RecommendTargetType> = MoyaProvider<RecommendTargetType>(plugins: [BearerTokenPlugin()])) {
        self.provider = provider
    }

    func spin(_ dto: RecommendRequestDTO, completion: @escaping (Result<DestinationDTO, NetworkError>) -> Void) {
        request(target: .spin(dto), decodingType: DestinationDTO.self, completion: completion)
    }

    func reroll(sessionId: String, completion: @escaping (Result<DestinationDTO, NetworkError>) -> Void) {
        request(target: .reroll(sessionId: sessionId), decodingType: DestinationDTO.self, completion: completion)
    }
}
