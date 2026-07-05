//
//  AuthService.swift
//  LottoTrip
//

import Foundation
import Moya

final class AuthService: NetworkManager {
    typealias Endpoint = AuthTargetType
    let provider: MoyaProvider<AuthTargetType>

    init(provider: MoyaProvider<AuthTargetType> = MoyaProvider<AuthTargetType>(plugins: [BearerTokenPlugin()])) {
        self.provider = provider
    }

    func socialLogin(provider p: String, token: String,
                     completion: @escaping (Result<LoginResponseDTO, NetworkError>) -> Void) {
        request(target: .socialLogin(provider: p, token: token), decodingType: LoginResponseDTO.self, completion: completion)
    }

    func signup(_ dto: SignupRequestDTO, completion: @escaping (Result<LoginResponseDTO, NetworkError>) -> Void) {
        request(target: .signup(dto), decodingType: LoginResponseDTO.self, completion: completion)
    }

    func me(completion: @escaping (Result<UserDTO, NetworkError>) -> Void) {
        request(target: .me, decodingType: UserDTO.self, completion: completion)
    }
}
