//
//  VideoTargetType.swift
//  LottoTrip
//
//  숏폼(릴스) 생성 도메인 엔드포인트.
//  POST /video/upload-urls, POST /video/render, GET /video/render/{jobId}
//

import Foundation
import Moya

enum VideoTargetType {
    case uploadUrls(fileCount: Int, contentType: String)
    case render(RenderRequestDTO)
    case renderStatus(jobId: String)
}

extension VideoTargetType: TargetType, AuthorizedTargetType {
    var baseURL: URL { URL(string: Domain.baseURL)! }

    var path: String {
        switch self {
        case .uploadUrls:            return "\(Domain.video)/upload-urls"
        case .render:                return "\(Domain.video)/render"
        case let .renderStatus(jobId): return "\(Domain.video)/render/\(jobId)"
        }
    }

    var method: Moya.Method {
        switch self {
        case .uploadUrls, .render: return .post
        case .renderStatus:        return .get
        }
    }

    var task: Moya.Task {
        switch self {
        case let .uploadUrls(fileCount, contentType):
            return .requestJSONEncodable(UploadUrlRequestDTO(fileCount: fileCount, contentType: contentType))
        case let .render(dto):
            return .requestJSONEncodable(dto)
        case .renderStatus:
            return .requestPlain
        }
    }

    var headers: [String: String]? { ["Content-Type": "application/json"] }
}
