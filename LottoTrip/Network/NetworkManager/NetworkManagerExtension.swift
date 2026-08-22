//
//  NetworkManagerExtension.swift
//  LottoTrip
//
//  공통 응답(envelope) 기본 구현.
//
//  검증 순서:
//   1) 응답 바디에서 error(envelope.error) 를 먼저 파싱 → 있으면 서버 에러로 매핑
//   2) HTTP status 2xx 확인
//   3) data 디코딩 → 반환
//

import Foundation
import Moya
import Alamofire

extension NetworkManager {

    /// 프로젝트 공통 JSONDecoder
    fileprivate var decoder: JSONDecoder { NetworkDecoder.shared }

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
                completion(.failure(self.handleMoyaError(error)))
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
                completion(.failure(self.handleMoyaError(error)))
            }
        }
    }

    // MARK: - 3. 성공/실패만 확인
    func requestStatusCode(
        target: Endpoint,
        completion: @escaping (Result<Void, NetworkError>) -> Void
    ) {
        provider.request(target) { result in
            switch result {
            case .success(let response):
                switch self.validate(response) {
                case .success:            completion(.success(()))
                case .failure(let error): completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(self.handleMoyaError(error)))
            }
        }
    }

    // MARK: - 응답 처리 (필수)
    private func handleResponse<T: Decodable>(
        _ response: Response,
        decodingType: T.Type
    ) -> Result<T, NetworkError> {
        if let error = serverErrorIfPresent(response) { return .failure(error) }
        guard (200...299).contains(response.statusCode) else {
            return .failure(.networkError(message: Self.statusMessage(response)))
        }
        do {
            let api = try decoder.decode(ApiResponse<T>.self, from: response.data)
            guard let data = api.data else { return .failure(.dataNil) }
            return .success(data)
        } catch {
            // 최상위가 envelope 이 아니라 data 그 자체로 내려오는 경우 대비
            if let raw = try? decoder.decode(T.self, from: response.data) {
                return .success(raw)
            }
            return .failure(.failToDecode(String(describing: error)))
        }
    }

    // MARK: - 응답 처리 (옵셔널)
    private func handleResponseOptional<T: Decodable>(
        _ response: Response,
        decodingType: T.Type
    ) -> Result<T?, NetworkError> {
        if let error = serverErrorIfPresent(response) { return .failure(error) }
        guard (200...299).contains(response.statusCode) else {
            return .failure(.networkError(message: Self.statusMessage(response)))
        }
        if response.data.isEmpty { return .success(nil) }
        do {
            let api = try decoder.decode(ApiResponse<T>.self, from: response.data)
            return .success(api.data)
        } catch {
            return .failure(.failToDecode(String(describing: error)))
        }
    }

    // MARK: - status/error 만 검증 (data 무시)
    private func validate(_ response: Response) -> Result<Void, NetworkError> {
        if let error = serverErrorIfPresent(response) { return .failure(error) }
        guard (200...299).contains(response.statusCode) else {
            return .failure(.networkError(message: Self.statusMessage(response)))
        }
        return .success(())
    }

    /// 응답 바디에 envelope.error 가 있으면 서버 에러로 매핑, 없으면 nil.
    private func serverErrorIfPresent(_ response: Response) -> NetworkError? {
        guard let meta = try? decoder.decode(ApiEnvelopeMeta.self, from: response.data),
              let body = meta.error else { return nil }
        return .server(
            code: ErrorCode(code: body.code),
            rawCode: body.code,
            message: body.message,
            status: meta.status
        )
    }

    // MARK: - HTTP status 메시지 (error 바디 없을 때 폴백)
    private static func statusMessage(_ response: Response) -> String {
        switch response.statusCode {
        case 300..<400: return "리다이렉션 오류가 발생했습니다. (\(response.statusCode))"
        case 400..<500: return "클라이언트 오류가 발생했습니다. (\(response.statusCode))"
        case 500..<600: return "서버 오류가 발생했습니다. (\(response.statusCode))"
        default:        return "알 수 없는 오류가 발생했습니다. (\(response.statusCode))"
        }
    }

    // MARK: - Moya/전송 계층 오류 처리
    func handleMoyaError(_ error: MoyaError) -> NetworkError {
        // 응답이 존재하면(HTTP 에러) envelope.error 우선 매핑
        if let response = error.response, let mapped = serverErrorIfPresent(response) {
            return mapped
        }
        // Moya 는 전송 오류를 MoyaError.underlying(AFError, _) → AFError.sessionTaskFailed(URLError)
        // 처럼 여러 겹으로 감싼다. 체인을 끝까지 풀어 실제 URLError 를 찾아 한글 메시지로 매핑한다.
        guard let urlError = Self.extractURLError(error) else {
            return .otherMoyaError(error.errorDescription)
        }
        switch urlError.code {
        case .notConnectedToInternet: return .networkError(message: "인터넷 연결이 끊겼습니다.")
        case .timedOut:               return .networkError(message: "요청 시간이 초과되었습니다.")
        case .cannotFindHost,
             .dnsLookupFailed:        return .networkError(message: "서버를 찾을 수 없습니다. 잠시 후 다시 시도해주세요.")
        case .cannotConnectToHost,
             .networkConnectionLost:  return .networkError(message: "서버에 연결할 수 없습니다.")
        default:                      return .networkError(message: "네트워크 오류가 발생했습니다. (\(urlError.code.rawValue))")
        }
    }

    /// MoyaError → AFError → URLError 로 이어지는 오류 체인에서 URLError 를 추출.
    private static func extractURLError(_ error: Error) -> URLError? {
        if let urlError = error as? URLError { return urlError }
        if let afError = error.asAFError, let underlying = afError.underlyingError {
            return extractURLError(underlying)
        }
        if case let MoyaError.underlying(underlying, _) = error {
            return extractURLError(underlying)
        }
        let nsError = error as NSError
        if let underlying = nsError.userInfo[NSUnderlyingErrorKey] as? Error {
            return extractURLError(underlying)
        }
        return nil
    }
}

// MARK: - async/await 편의 래퍼 (iOS 17 타깃)

extension NetworkManager {
    func request<T: Decodable>(_ target: Endpoint, as type: T.Type) async -> Result<T, NetworkError> {
        await withCheckedContinuation { continuation in
            request(target: target, decodingType: type) { continuation.resume(returning: $0) }
        }
    }

    func requestStatusCode(_ target: Endpoint) async -> Result<Void, NetworkError> {
        await withCheckedContinuation { continuation in
            requestStatusCode(target: target) { continuation.resume(returning: $0) }
        }
    }
}

// MARK: - 공용 디코더

enum NetworkDecoder {
    static let shared: JSONDecoder = {
        let decoder = JSONDecoder()
        // 서버 응답 키는 camelCase(accessToken/jobId 등)로 내려온다고 가정.
        // ISO8601 형식 날짜(createdAt 등)는 각 DTO 에서 String 으로 받고 필요 시 파싱.
        return decoder
    }()
}
