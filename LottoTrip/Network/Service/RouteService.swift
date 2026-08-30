//
//  RouteService.swift
//  LottoTrip
//
//  길찾기 도메인 서비스. 슬롯 결과(slotId) 기준 대중교통/도보/자동차 경로.
//

import Foundation
import Moya

final class RouteService: NetworkManager {
    typealias Endpoint = RouteTargetType
    let provider: MoyaProvider<RouteTargetType>

    init(provider: MoyaProvider<RouteTargetType> = MoyaProvider<RouteTargetType>(plugins: [BearerTokenPlugin()])) {
        self.provider = provider
    }

    func transit(slotId: Int, completion: @escaping (Result<RouteResponseDTO, NetworkError>) -> Void) {
        request(target: .transit(slotId: slotId), decodingType: RouteResponseDTO.self, completion: completion)
    }
    func walk(slotId: Int, completion: @escaping (Result<WalkRouteDTO, NetworkError>) -> Void) {
        request(target: .walk(slotId: slotId), decodingType: WalkRouteDTO.self, completion: completion)
    }
    func car(slotId: Int, completion: @escaping (Result<CarRouteDTO, NetworkError>) -> Void) {
        request(target: .car(slotId: slotId), decodingType: CarRouteDTO.self, completion: completion)
    }
}
