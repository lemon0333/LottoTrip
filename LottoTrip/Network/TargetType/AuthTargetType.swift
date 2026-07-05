//
//  AuthTargetType.swift
//  LottoTrip
//

import Foundation
import Moya

enum AuthTargetType {
    case socialLogin(provider: String, token: String)
    case signup(SignupRequestDTO)
    case me
}

extension AuthTargetType: TargetType {
    var baseURL: URL { URL(string: Domain.authURL)! }

    var path: String {
        switch self {
        case .socialLogin: return "/login/social"
        case .signup:      return "/signup"
        case .me:          return "/me"
        }
    }

    var method: Moya.Method {
        switch self {
        case .me: return .get
        default:  return .post
        }
    }

    var task: Moya.Task {
        switch self {
        case let .socialLogin(provider, token):
            return .requestParameters(parameters: ["provider": provider, "token": token], encoding: JSONEncoding.default)
        case let .signup(dto):
            return .requestJSONEncodable(dto)
        case .me:
            return .requestPlain
        }
    }

    var headers: [String: String]? { ["Content-Type": "application/json"] }
}
