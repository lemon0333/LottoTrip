//
//  RouteFindViewController.swift
//  LottoTrip
//
//  길찾기 — 대중교통 / 자동차 / 자전거 / 도보 (커스텀 탭 + 콘텐츠 스왑).
//  slotId 기준 RouteService 실제 경로 조회.
//

import UIKit
import SnapKit

// MARK: - RouteMapView (지도 placeholder + 코랄 경로선 데코)
/// tileEmpty 배경 위에 출발→도착 지그재그 경로선(CAShapeLayer)과 핀을 그린다.
final class RouteMapView: UIView {

    private let routeLayer = CAShapeLayer()
    private let startPin = UIView()
    private let endPin = UIView()
    private let startLabel = UILabel.make("출발", font: AppFont.semibold(12), color: AppColor.sub, align: .center)
    private let endLabel = UILabel.make("도착", font: AppFont.semibold(12), color: AppColor.ink, align: .center)

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = AppColor.tileEmpty
        layer.cornerRadius = 16
        clipsToBounds = true

        routeLayer.strokeColor = AppColor.coral.cgColor
        routeLayer.fillColor = UIColor.clear.cgColor
        routeLayer.lineWidth = 4
        routeLayer.lineCap = .round
        routeLayer.lineJoin = .round
        layer.addSublayer(routeLayer)

        // 데코용이라 프레임 기반 배치 (Auto Layout 미사용)
        configurePin(startPin, color: AppColor.sub)
        configurePin(endPin, color: AppColor.ink)
        addSubview(startPin)
        addSubview(endPin)
        addSubview(startLabel)
        addSubview(endLabel)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func configurePin(_ pin: UIView, color: UIColor) {
        pin.backgroundColor = color
        pin.layer.cornerRadius = 8
        pin.layer.borderWidth = 3
        pin.layer.borderColor = UIColor.white.cgColor
        pin.frame = CGRect(x: 0, y: 0, width: 16, height: 16)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let inset: CGFloat = 36
        let start = CGPoint(x: inset, y: inset)
        let end = CGPoint(x: bounds.width - inset, y: bounds.height - inset)

        // 출발 → 도착 지그재그 경로 (데코용 근사치)
        let path = UIBezierPath()
        path.move(to: start)
        path.addLine(to: CGPoint(x: bounds.width * 0.32, y: inset))
        path.addLine(to: CGPoint(x: bounds.width * 0.32, y: bounds.midY))
        path.addLine(to: CGPoint(x: bounds.width * 0.66, y: bounds.midY))
        path.addLine(to: CGPoint(x: bounds.width * 0.66, y: bounds.height - inset))
        path.addLine(to: end)
        routeLayer.path = path.cgPath

        startPin.center = start
        endPin.center = end
        startLabel.sizeToFit()
        endLabel.sizeToFit()
        startLabel.center = CGPoint(x: start.x, y: start.y + 18)
        endLabel.center = CGPoint(x: end.x, y: end.y + 18)
    }
}

// MARK: - RouteFindViewController
final class RouteFindViewController: BaseScrollViewController {

    private let destinationName: String
    /// 경로를 조회할 슬롯 id (없으면 empty 상태로 표시)
    private let slotId: Int?

    private let contentContainer = UIView()
    /// 현재 선택된 탭 인덱스 (비동기 응답의 stale 방지)
    private var currentTab = 0

    init(destinationName: String = "목적지", slotId: Int? = nil) {
        self.destinationName = destinationName
        self.slotId = slotId
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = destinationName

        let map = RouteMapView()
        map.snp.makeConstraints { $0.height.equalTo(260) }
        contentStack.addArrangedSubview(map)

        let tabBar = UnderlineTabBar(titles: ["대중교통", "자동차", "자전거", "도보"])
        tabBar.onSelect = { [weak self] idx in self?.showTab(idx) }
        contentStack.addArrangedSubview(tabBar)

        contentStack.addArrangedSubview(contentContainer)
        showTab(0)
    }

    // MARK: - 탭 전환 (선택 시 해당 경로 조회)
    private func showTab(_ index: Int) {
        currentTab = index

        guard let slotId = slotId else {
            setContent(centeredEmpty("경로 정보를 불러올 수 없어요"))
            return
        }

        setContent(centeredEmpty("불러오는 중..."))
        switch index {
        case 0:  fetchTransit(slotId, for: index)          // 대중교통
        case 3:  fetchWalk(slotId, for: index)             // 도보
        default: fetchCar(slotId, for: index)              // 자동차 / 자전거
        }
    }

    /// 컨테이너 콘텐츠 스왑
    private func setContent(_ view: UIView) {
        contentContainer.subviews.forEach { $0.removeFromSuperview() }
        contentContainer.addSubview(view)
        view.snp.makeConstraints { $0.edges.equalToSuperview() }
    }

    // MARK: - 경로 조회
    private func fetchTransit(_ slotId: Int, for index: Int) {
        APIClient.shared.route.transit(slotId: slotId) { [weak self] outcome in
            guard let self = self, self.currentTab == index else { return }
            switch outcome {
            case .success(let route):  self.setContent(self.transitContent(route))
            case .failure(let error):  self.setContent(self.centeredEmpty(error.description))
            }
        }
    }

    private func fetchCar(_ slotId: Int, for index: Int) {
        APIClient.shared.route.car(slotId: slotId) { [weak self] outcome in
            guard let self = self, self.currentTab == index else { return }
            switch outcome {
            case .success(let car):    self.setContent(self.carContent(car))
            case .failure(let error):  self.setContent(self.centeredEmpty(error.description))
            }
        }
    }

    private func fetchWalk(_ slotId: Int, for index: Int) {
        APIClient.shared.route.walk(slotId: slotId) { [weak self] outcome in
            guard let self = self, self.currentTab == index else { return }
            switch outcome {
            case .success(let walk):   self.setContent(self.walkContent(walk))
            case .failure(let error):  self.setContent(self.centeredEmpty(error.description))
            }
        }
    }

    // MARK: - 대중교통 콘텐츠 (총 시간 + 요금 + 구간 타임라인)
    private func transitContent(_ route: RouteResponseDTO) -> UIView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16

        stack.addArrangedSubview(UILabel.make(durationText(route.totalMinutes), font: AppFont.bold(22), color: AppColor.ink))
        if let payment = route.payment {
            stack.addArrangedSubview(UILabel.make("요금 \(payment)원", font: AppFont.medium(14), color: AppColor.sub))
        }

        if route.legs.isEmpty {
            stack.addArrangedSubview(UILabel.make("상세 구간 정보가 없어요", font: AppFont.medium(13), color: AppColor.sub))
        } else {
            for (idx, leg) in route.legs.enumerated() {
                stack.addArrangedSubview(timelineStep(
                    title: legTitle(leg),
                    lines: legLines(leg),
                    isLast: idx == route.legs.count - 1))
            }
        }
        return stack
    }

    /// 구간(leg) 제목 — 노선명 우선, 없으면 이동수단 한글
    private func legTitle(_ leg: RouteLegDTO) -> String {
        if let name = leg.routeName, !name.isEmpty { return name }
        return modeLabel(leg.mode)
    }

    private func modeLabel(_ mode: String) -> String {
        switch mode.uppercased() {
        case "BUS":    return "버스"
        case "SUBWAY": return "지하철"
        case "WALK":   return "도보"
        default:       return mode
        }
    }

    /// 구간 상세 텍스트 (출발→도착, 정류장 수·소요시간)
    private func legLines(_ leg: RouteLegDTO) -> [String] {
        var lines: [String] = []
        if let start = leg.startName, let end = leg.endName {
            lines.append("\(start) → \(end)")
        } else if let start = leg.startName {
            lines.append(start)
        } else if let end = leg.endName {
            lines.append("\(end) 하차")
        }
        var detail: [String] = []
        if let count = leg.stationCount { detail.append("\(count)개 정류장") }
        if let minutes = leg.sectionMinutes { detail.append("\(minutes)분 이동") }
        if !detail.isEmpty { lines.append(detail.joined(separator: " · ")) }
        return lines
    }

    // MARK: - 자동차 / 도보 콘텐츠
    private func carContent(_ car: CarRouteDTO) -> UIView {
        var details: [String] = []
        if let meters = car.totalDistanceMeters { details.append(distanceText(meters: meters)) }
        if let toll = car.tollFare, toll > 0 { details.append("통행료 \(toll)원") }
        if let taxi = car.taxiFare, taxi > 0 { details.append("택시 예상 \(taxi)원") }
        return summaryCard(duration: durationText(car.totalMinutes), details: details)
    }

    private func walkContent(_ walk: WalkRouteDTO) -> UIView {
        var details: [String] = []
        if let meters = walk.totalDistanceMeters { details.append(distanceText(meters: Double(meters))) }
        return summaryCard(duration: durationText(walk.totalMinutes), details: details)
    }

    /// 총 시간 카드 + 부가정보 + 안내 시작 버튼
    private func summaryCard(duration: String, details: [String]) -> UIView {
        let card = CardView(spacing: 6)
        card.addArranged(UILabel.make(duration, font: AppFont.bold(22), color: AppColor.ink))
        details.forEach { card.addArranged(UILabel.make($0, font: AppFont.medium(15), color: AppColor.sub)) }

        let startButton = PrimaryButton(title: "안내 시작", bg: AppColor.ink)
        startButton.addTarget(self, action: #selector(startGuide), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [card, startButton])
        stack.axis = .vertical
        stack.spacing = 16
        return stack
    }

    // MARK: - 포맷 헬퍼
    /// 분 → "X시간 Y분"
    private func durationText(_ minutes: Int) -> String {
        let hours = minutes / 60, mins = minutes % 60
        if hours > 0 && mins > 0 { return "\(hours)시간 \(mins)분" }
        if hours > 0 { return "\(hours)시간" }
        return "\(mins)분"
    }

    /// 미터 → "X.Ykm"
    private func distanceText(meters: Double) -> String {
        String(format: "%.1fkm", meters / 1000)
    }

    // MARK: - 중앙 empty-state / placeholder 라벨
    private func centeredEmpty(_ text: String) -> UIView {
        let container = UIView()
        let label = UILabel.make(text, font: AppFont.medium(14), color: AppColor.sub, align: .center, lines: 0)
        container.addSubview(label)
        label.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.bottom.equalToSuperview().inset(48)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        return container
    }

    /// 왼쪽 코랄 세로선 + 점 + 우측 텍스트로 구성된 타임라인 스텝
    private func timelineStep(title: String, lines: [String], isLast: Bool = false) -> UIView {
        // 왼쪽 레일 (점 + 세로선)
        let dot = UIView()
        dot.backgroundColor = AppColor.coral
        dot.layer.cornerRadius = 6
        dot.snp.makeConstraints { $0.size.equalTo(12) }

        let rail = UIView()
        rail.addSubview(dot)
        dot.snp.makeConstraints { $0.top.centerX.equalToSuperview() }
        rail.snp.makeConstraints { $0.width.equalTo(12) }

        if !isLast {
            let line = UIView()
            line.backgroundColor = AppColor.coral.withAlphaComponent(0.5)
            rail.addSubview(line)
            line.snp.makeConstraints {
                $0.top.equalTo(dot.snp.bottom).offset(2)
                $0.centerX.equalToSuperview()
                $0.width.equalTo(2)
                $0.bottom.equalToSuperview()
            }
        }

        // 우측 텍스트
        let texts = UIStackView()
        texts.axis = .vertical
        texts.spacing = 4
        texts.addArrangedSubview(UILabel.make(title, font: AppFont.bold(16), color: AppColor.ink))
        lines.forEach { texts.addArrangedSubview(UILabel.make($0, font: AppFont.medium(13), color: AppColor.sub)) }

        let row = UIStackView(arrangedSubviews: [rail, texts])
        row.axis = .horizontal
        row.alignment = .top
        row.spacing = 14
        // 마지막이 아니면 아래로 여유를 줘 세로선이 보이게
        if !isLast {
            texts.snp.makeConstraints { $0.height.greaterThanOrEqualTo(52) }
        }
        return row
    }

    @objc private func startGuide() {
        // TODO: 실제 길찾기 연동(카카오/티맵 등) 필요
        let alert = UIAlertController(title: "안내", message: "길찾기 연동 예정입니다.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}
