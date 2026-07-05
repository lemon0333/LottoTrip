//
//  CommunityService.swift
//  LottoTrip
//

import Foundation
import Moya

final class CommunityService: NetworkManager {
    typealias Endpoint = CommunityTargetType
    let provider: MoyaProvider<CommunityTargetType>

    init(provider: MoyaProvider<CommunityTargetType> = MoyaProvider<CommunityTargetType>(plugins: [BearerTokenPlugin()])) {
        self.provider = provider
    }

    func nearby(lat: Double, lng: Double, radius: Int,
                completion: @escaping (Result<[CommunityPostDTO], NetworkError>) -> Void) {
        request(target: .nearby(lat: lat, lng: lng, radius: radius), decodingType: [CommunityPostDTO].self, completion: completion)
    }

    func like(postId: String, completion: @escaping (Result<Void, NetworkError>) -> Void) {
        requestStatusCode(target: .like(postId: postId), completion: completion)
    }

    func chatRooms(completion: @escaping (Result<[ChatRoomDTO], NetworkError>) -> Void) {
        request(target: .chatRooms, decodingType: [ChatRoomDTO].self, completion: completion)
    }
}
