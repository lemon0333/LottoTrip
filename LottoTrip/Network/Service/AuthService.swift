//
//  AuthService.swift
//  LottoTrip
//
//  인증 도메인 서비스. 로그인/토큰 갱신 성공 시 TokenStore 에 자동 저장,
//  로그아웃 시 자동 제거한다.
//

import Foundation
import Moya

final class AuthService: NetworkManager {
    typealias Endpoint = AuthTargetType
    let provider: MoyaProvider<AuthTargetType>

    init(provider: MoyaProvider<AuthTargetType> = MoyaProvider<AuthTargetType>(plugins: [BearerTokenPlugin()])) {
        self.provider = provider
    }

    /// 소셜 로그인 → 서비스 토큰 발급 (성공 시 토큰 저장)
    func login(provider: OAuthProvider, providerToken: String,
               completion: @escaping (Result<LoginResponseDTO, NetworkError>) -> Void) {
        request(target: .login(provider: provider, providerToken: providerToken),
                decodingType: LoginResponseDTO.self) { result in
            if case let .success(dto) = result {
                TokenStore.save(accessToken: dto.accessToken, refreshToken: dto.refreshToken)
            }
            completion(result)
        }
    }

    /// 액세스 토큰 재발급 (성공 시 액세스 토큰만 갱신 — 서버가 refreshToken 은 재발급하지 않음)
    func refresh(completion: @escaping (Result<RefreshResponseDTO, NetworkError>) -> Void) {
        guard let refreshToken = TokenStore.refreshToken, !refreshToken.isEmpty else {
            completion(.failure(.server(code: .invalidRefreshToken,
                                        rawCode: ErrorCode.invalidRefreshToken.rawValue,
                                        message: ErrorCode.invalidRefreshToken.defaultMessage,
                                        status: 401)))
            return
        }
        request(target: .refresh(refreshToken: refreshToken),
                decodingType: RefreshResponseDTO.self) { result in
            if case let .success(dto) = result {
                TokenStore.accessToken = dto.accessToken
            }
            completion(result)
        }
    }

    /// 로그아웃 → 서버 토큰 무효화 + 로컬 토큰 제거
    func logout(completion: @escaping (Result<Void, NetworkError>) -> Void) {
        requestStatusCode(target: .logout) { result in
            if case .success = result { TokenStore.clear() }
            completion(result)
        }
    }

    /// 회원탈퇴(소프트 삭제) → 성공 시 로컬 토큰 제거. (앱스토어 심사 필수 기능)
    func withdraw(completion: @escaping (Result<WithdrawResponseDTO, NetworkError>) -> Void) {
        request(target: .withdraw, decodingType: WithdrawResponseDTO.self) { result in
            if case .success = result { TokenStore.clear() }
            completion(result)
        }
    }
}
