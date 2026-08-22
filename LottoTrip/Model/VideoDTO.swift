//
//  VideoDTO.swift
//  LottoTrip
//
//  숏폼(릴스) 생성 도메인 DTO.
//  POST /video/upload-urls, POST /video/render, GET /video/render/{jobId}
//

import Foundation

// MARK: - 업로드 URL 발급

/// POST /video/upload-urls — S3 Presigned URL 발급 요청
struct UploadUrlRequestDTO: Encodable {
    let fileCount: Int
    let contentType: String   // "video/mp4" 등
}

/// 발급된 Presigned URL 목록
struct UploadUrlsResponseDTO: Decodable {
    let urls: [PresignedUrlDTO]
}

struct PresignedUrlDTO: Decodable {
    let uploadUrl: String   // 프론트 → S3 PUT 대상
    let fileKey: String     // 렌더 요청 시 clips 로 넘길 키/URL
}

// MARK: - 렌더링 요청/상태

/// POST /video/render — 클립 병합 + TTS 더빙 렌더링 요청 (비동기)
struct RenderRequestDTO: Encodable {
    let clips: [String]        // 업로드된 S3 클립 키/URL 목록
    let ttsScript: String      // 나레이션 스크립트
    let narrationType: String  // 나레이션 톤/보이스 종류
}

/// 렌더링 잡 생성 응답 (jobId 반환)
struct RenderJobDTO: Decodable {
    let jobId: String
    let status: JobStatus
}

/// GET /video/render/{jobId} — 렌더링 진행 상태(폴링)
struct RenderStatusDTO: Decodable {
    let jobId: String
    let status: JobStatus     // PROCESSING / COMPLETED / FAILED
    let videoUrl: String?     // COMPLETED 시 결과 URL
    let progress: Int?        // 진행률(0~100), 서버 제공 시
}
