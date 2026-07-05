//
//  MissionTargetType.swift
//  LottoTrip
//

import Foundation
import Moya

enum MissionTargetType {
    case current(placeId: String)
    case verify(missionId: String, imageData: Data)   // 사진 인증(멀티파트)
    case history
}

extension MissionTargetType: TargetType {
    var baseURL: URL { URL(string: Domain.missionURL)! }

    var path: String {
        switch self {
        case .current: return "/current"
        case .verify:  return "/verify"
        case .history: return "/history"
        }
    }

    var method: Moya.Method {
        switch self {
        case .verify: return .post
        default:      return .get
        }
    }

    var task: Moya.Task {
        switch self {
        case let .current(placeId):
            return .requestParameters(parameters: ["placeId": placeId], encoding: URLEncoding.queryString)
        case let .verify(missionId, imageData):
            let photo = MultipartFormData(provider: .data(imageData), name: "photo",
                                          fileName: "mission.jpg", mimeType: "image/jpeg")
            let id = MultipartFormData(provider: .data(Data(missionId.utf8)), name: "missionId")
            return .uploadMultipart([photo, id])
        case .history:
            return .requestPlain
        }
    }

    var headers: [String: String]? {
        switch self {
        case .verify: return ["Content-Type": "multipart/form-data"]
        default:      return ["Content-Type": "application/json"]
        }
    }
}
