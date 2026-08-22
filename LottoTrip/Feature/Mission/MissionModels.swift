//
//  MissionModels.swift
//  LottoTrip
//
//  산신령 미션 화면용 로컬 모델 + 샘플 데이터 (강릉 아들바위공원 소원 빌기 테마).
//

import Foundation

struct MissionItem {
    let index: Int              // 0-based 순번
    let missionId: Int          // 서버 미션 식별자
    let title: String           // "첫 번째 임무" 등
    let narratorLines: [String] // 산신령 대사 (말풍선별)
    let guide: String           // 인증 가이드 문구
    var completed: Bool
}

enum MissionSampleData {

    /// 한글 서수 라벨 (첫/두/세 번째 임무). 개수는 백엔드 기준(장소당 3개).
    static let ordinals = ["첫", "두", "세"]

    static let missions: [MissionItem] = [
        MissionItem(
            index: 0, missionId: 101, title: "첫 번째 임무",
            narratorLines: [
                "허허, 먼 길 오느라 고생했구나.",
                "나는 이 바닷가를 지키는 산신령이니라.",
                "저 아들바위는 파도가 칠 때 소원을 빌면 들어준다는 전설이 있지.",
                "먼저 바다를 바라보며 세 번 숨을 고르고 소원을 빌어 보아라."
            ],
            guide: "바다를 바라보며 소원 비는 모습 3초 담기.",
            completed: false),
        MissionItem(
            index: 1, missionId: 102, title: "두 번째 임무",
            narratorLines: [
                "옳지, 마음이 제법 정갈해졌구나.",
                "옛날 이 마을 어부는 아들바위에 정성을 올려 귀한 아들을 얻었느니라.",
                "이번엔 두 손을 모아 정성껏 절하는 모습을 담아 오너라."
            ],
            guide: "아들바위를 향해 두 손 모아 절하는 모습 담기.",
            completed: false),
        MissionItem(
            index: 2, missionId: 103, title: "세 번째 임무",
            narratorLines: [
                "네 정성이 파도를 타고 내게 닿았느니라. 마지막이니라.",
                "노을이 바다를 물들일 때, 두 팔을 활짝 벌려 이 강릉을 품어 보아라.",
                "그 모습을 담으면 지도의 마지막 조각이 열릴 것이니라."
            ],
            guide: "노을을 배경으로 두 팔 벌린 인증샷 담기.",
            completed: false)
    ]
}
