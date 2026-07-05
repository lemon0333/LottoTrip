//
//  SampleData.swift
//  LottoTrip
//
//  서버 붙기 전 화면 구동용 목 데이터.
//

import Foundation

enum SampleData {

    // 강원 8권역 퍼즐 (5완성 · 1예약 · 2잠김)
    static let puzzle = PuzzleProgressDTO(
        total: 8, completed: 5,
        pieces: [
            .init(regionId: "gangneung", name: "강릉",      status: .completed),
            .init(regionId: "sokcho",    name: "속초·고성", status: .completed),
            .init(regionId: "yangyang",  name: "양양",      status: .completed),
            .init(regionId: "pyeongchang", name: "평창",    status: .completed),
            .init(regionId: "jeongseon", name: "정선",      status: .completed),
            .init(regionId: "samcheok",  name: "삼척",      status: .reserved),
            .init(regionId: "wonju",     name: "원주",      status: .locked),
            .init(regionId: "chuncheon", name: "춘천·홍천", status: .locked)
        ])

    static let destination = DestinationDTO(
        id: "d1", name: "강릉 아들바위공원", regionId: "gangneung",
        category: "바다 · 절경 · 소원 명소", distanceKm: 18, budget: 50000,
        hidden: true, missionTitle: "아들바위 소원 3초 촬영")

    static let mission = MissionDTO(
        id: "m1", placeName: "강릉 아들바위공원",
        narratorLine: "아들바위에서 파도칠 때 소원을 빌면 이루어진대요.\n소원 비는 모습을 3초간 담아보세요!",
        rewardPoint: 200, couponTitle: "강릉 시그니처 카페 쿠폰")

    static let feed: [CommunityPostDTO] = [
        .init(id: "p1", placeName: "강릉 아들바위공원", distanceText: "120m", likes: 248, comments: 37),
        .init(id: "p2", placeName: "삼척 초곡 용굴",   distanceText: "1.4km", likes: 89,  comments: 12)
    ]

    static let chatRoom = ChatRoomDTO(id: "c1", title: "강릉 아들바위行 운명 공동체", memberCount: 8)

    static let chat: [ChatMessageDTO] = [
        .init(id: "s1", sender: "시스템", text: "같은 목적지 유저가 입장했어요", isMine: false, isSystem: true),
        .init(id: "1", sender: "감자러버", text: "오 저도 방금 아들바위 떴어요 ㅋㅋ", isMine: false, isSystem: false),
        .init(id: "2", sender: "나", text: "헐 저도요! 같이 소원 빌어요 🙏", isMine: true, isSystem: false),
        .init(id: "3", sender: "강릉토박이", text: "18시쯤 도착 예정인데 같이 숏폼 찍으실분?", isMine: false, isSystem: false),
        .init(id: "4", sender: "나", text: "콜! 노을 시간 딱 맞겠다", isMine: true, isSystem: false),
        .init(id: "s2", sender: "산신령봇", text: "파도 칠 때 소원 비는 거 잊지 마세요 🧙", isMine: false, isSystem: true)
    ]
}
