//
//  PuzzleService.swift
//  LottoTrip
//

import Foundation
import Moya

final class PuzzleService: NetworkManager {
    typealias Endpoint = PuzzleTargetType
    let provider: MoyaProvider<PuzzleTargetType>

    init(provider: MoyaProvider<PuzzleTargetType> = MoyaProvider<PuzzleTargetType>(plugins: [BearerTokenPlugin()])) {
        self.provider = provider
    }

    func progress(completion: @escaping (Result<PuzzleProgressDTO, NetworkError>) -> Void) {
        request(target: .progress, decodingType: PuzzleProgressDTO.self, completion: completion)
    }

    func claim(regionId: String, completion: @escaping (Result<PuzzlePieceDTO, NetworkError>) -> Void) {
        request(target: .claim(regionId: regionId), decodingType: PuzzlePieceDTO.self, completion: completion)
    }
}
