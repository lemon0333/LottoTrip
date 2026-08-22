//
//  HealthService.swift
//  LottoTrip
//
//  헬스 체크 도메인 서비스. (인증 불필요)
//

import Foundation
import Moya

final class HealthService: NetworkManager {
    typealias Endpoint = HealthTargetType
    let provider: MoyaProvider<HealthTargetType>

    init(provider: MoyaProvider<HealthTargetType> = MoyaProvider<HealthTargetType>(plugins: [BearerTokenPlugin()])) {
        self.provider = provider
    }

    /// 서버·DB 상태 점검
    func check(completion: @escaping (Result<HealthDTO, NetworkError>) -> Void) {
        request(target: .check, decodingType: HealthDTO.self, completion: completion)
    }
}
