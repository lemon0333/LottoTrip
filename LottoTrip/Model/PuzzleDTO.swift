//
//  PuzzleDTO.swift
//  LottoTrip
//
//  강원 지도 퍼즐: 권역 조각 상태.
//

import Foundation

enum PieceStatus: String, Decodable {
    case locked      // 잠김 (미방문)
    case reserved    // 슬롯에서 뽑힘 (인증 대기)
    case completed   // 방문 인증 완료
}

struct PuzzlePieceDTO: Decodable {
    let regionId: String
    let name: String        // "강릉", "속초·고성" ...
    let status: PieceStatus

    init(regionId: String, name: String, status: PieceStatus) {
        self.regionId = regionId
        self.name = name
        self.status = status
    }
}

struct PuzzleProgressDTO: Decodable {
    let total: Int
    let completed: Int
    let pieces: [PuzzlePieceDTO]
}
