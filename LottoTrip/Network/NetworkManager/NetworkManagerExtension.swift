//
//  NetworkManagerExtension.swift
//  LottoTrip
//
//  Archive-iOS 패턴 그대로: request/requestOptional/requestStatusCode 기본 구현 +
//  상태코드(200~299) && ApiResponse.code=="200" 검증, 서버 에러/디코딩 에러 처리.
//

import Foundation
import Moya

extension NetworkManager {

    // MARK: - 1. 필수 데이터 요청
    func request<T: Decodable>(
        target: Endpoint,
        decodingType: T.Type,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) {
        provider.request(target) { result in
            switch result {
            case .success(let response):
                completion(self.handleResponse(response, decodingType: decodingType))
            case .failure(let error):
                completion(.failure(self.handleNetworkError(error)))
            }
        }
    }

    // MARK: - 2. 옵셔널 데이터 요청
    func requestOptional<T: Decodable>(
        target: Endpoint,
        decodingType: T.Type,
        completion: @escaping (Result<T?, NetworkError>) -> Void
    ) {
        provider.request(target) { result in
            switch result {
            case .success(let response):
                completion(self.handleResponseOptional(response, decodingType: decodingType))
            case .failure(let error):
                completion(.failure(self.handleNetworkError(error)))
            }
        }
    }

    // MARK: - 3. 상태 코드만 확인
    func requestStatusCode(
        target: Endpoint,
        completion: @escaping (Result<Void, NetworkError>) -> Void
    ) {
        provider.request(target) { result in
            switch result {
            case .success(let response):
                let decoded: Result<ApiResponse<String?>?, NetworkError> =
                    self.handleResponseOptional(response, decodingType: ApiResponse<String?>.self)
                switch decoded {
                case .success: completion(.success(()))
                case .failure(let error): completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(self.handleNetworkError(error)))
            }
        }
    }

    // MARK: - 응답 처리 (필수)
    private func handleResponse<T: Decodable>(
        _ response: Response,
        decodingType: T.Type
    ) -> Result<T, NetworkError> {
        do {
            guard (200...299).contains(response.statusCode) else {
                return .failure(.networkError(message: Self.statusMessage(response)))
            }
            let apiResponse = try JSONDecoder().decode(ApiResponse<T>.self, from: response.data)
            guard apiResponse.code == "200" else {
                return .failure(.serverError(apiResponse.message))
            }
            guard let result = apiResponse.result else {
                return .failure(.dataNil)
            }
            return .success(result)
        } catch {
            return .failure(.failToDecode(response.description))
        }
    }

    // MARK: - 응답 처리 (옵셔널)
    private func handleResponseOptional<T: Decodable>(
        _ response: Response,
        decodingType: T.Type
    ) -> Result<T?, NetworkError> {
        do {
            guard (200...299).contains(response.statusCode) else {
                return .failure(.networkError(message: Self.statusMessage(response)))
            }
            if response.data.isEmpty { return .success(nil) }
            let apiResponse = try JSONDecoder().decode(ApiResponse<T>.self, from: response.data)
            guard apiResponse.code == "200" else {
                return .failure(.serverError(apiResponse.message))
            }
            return .success(apiResponse.result)
        } catch {
            return .failure(.failToDecode(response.debugDescription))
        }
    }

    private static func statusMessage(_ response: Response) -> String {
        let base: String
        switch response.statusCode {
        case 300..<400: base = "리다이렉션 오류가 발생했습니다. (\(response.statusCode))"
        case 400..<500: base = "클라이언트 오류가 발생했습니다. (\(response.statusCode))"
        case 500..<600: base = "서버 오류가 발생했습니다. (\(response.statusCode))"
        default:        base = "알 수 없는 오류가 발생했습니다. (\(response.statusCode))"
        }
        let serverMessage = try? JSONDecoder().decode(ErrorResponse.self, from: response.data)
        return serverMessage?.message ?? base
    }

    // MARK: - 네트워크 오류 처리
    func handleNetworkError(_ error: Error) -> NetworkError {
        let nsError = error as NSError
        switch nsError.code {
        case NSURLErrorNotConnectedToInternet: return .networkError(message: "인터넷 연결이 끊겼습니다.")
        case NSURLErrorTimedOut:               return .networkError(message: "요청 시간이 초과되었습니다.")
        default:                               return .networkError(message: "네트워크 오류가 발생했습니다.")
        }
    }
}
