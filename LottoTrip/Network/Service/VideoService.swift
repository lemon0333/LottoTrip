//
//  VideoService.swift
//  LottoTrip
//
//  숏폼(릴스) 생성 도메인 서비스.
//  업로드 URL 발급 → (프론트가 S3 직접 업로드) → 렌더 요청 → 상태 폴링.
//

import Foundation
import Moya

final class VideoService: NetworkManager {
    typealias Endpoint = VideoTargetType
    let provider: MoyaProvider<VideoTargetType>

    init(provider: MoyaProvider<VideoTargetType> = MoyaProvider<VideoTargetType>(plugins: [BearerTokenPlugin()])) {
        self.provider = provider
    }

    /// 업로드 URL 발급 — S3 Presigned URL
    func uploadUrls(fileCount: Int, contentType: String,
                    completion: @escaping (Result<UploadUrlsResponseDTO, NetworkError>) -> Void) {
        request(target: .uploadUrls(fileCount: fileCount, contentType: contentType),
                decodingType: UploadUrlsResponseDTO.self, completion: completion)
    }

    /// 릴스 생성 요청 — 병합 + TTS 렌더링 (비동기, jobId 반환)
    func render(clips: [String], ttsScript: String, narrationType: String,
                completion: @escaping (Result<RenderJobDTO, NetworkError>) -> Void) {
        let dto = RenderRequestDTO(clips: clips, ttsScript: ttsScript, narrationType: narrationType)
        request(target: .render(dto), decodingType: RenderJobDTO.self, completion: completion)
    }

    /// 릴스 상태 조회 — 폴링
    func renderStatus(jobId: String,
                      completion: @escaping (Result<RenderStatusDTO, NetworkError>) -> Void) {
        request(target: .renderStatus(jobId: jobId), decodingType: RenderStatusDTO.self, completion: completion)
    }
}
