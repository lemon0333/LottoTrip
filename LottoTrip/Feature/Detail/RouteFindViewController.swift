//
//  RouteFindViewController.swift
//  LottoTrip
//
//  길찾기 — 대중교통 / 자동차 / 자전거 / 도보 (커스텀 탭 + 콘텐츠 스왑).
//  TODO: 실제 길찾기 연동(카카오/티맵 등) 필요 — 현재는 목업/placeholder.
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
    private let distanceKm: Int

    private let contentContainer = UIView()

    init(destinationName: String = "목적지 이름", distanceKm: Int = 110) {
        self.destinationName = destinationName
        self.distanceKm = distanceKm
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

    // MARK: - 탭 전환
    private func showTab(_ index: Int) {
        contentContainer.subviews.forEach { $0.removeFromSuperview() }
        let content: UIView
        switch index {
        case 0:  content = transitTab()
        case 2:  content = driveTab(duration: "6시간 12분", distance: "\(distanceKm)km")   // 자전거 (목업)
        case 3:  content = driveTab(duration: "22시간", distance: "\(distanceKm)km")        // 도보 (목업)
        default: content = driveTab(duration: "2시간 53분", distance: "\(distanceKm)km")    // 자동차
        }
        contentContainer.addSubview(content)
        content.snp.makeConstraints { $0.edges.equalToSuperview() }
    }

    // MARK: - 대중교통 탭
    private func transitTab() -> UIView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16

        stack.addArrangedSubview(UILabel.make("2시간 53분", font: AppFont.bold(22), color: AppColor.ink))
        stack.addArrangedSubview(UILabel.make("오후 1:30 - 오후 4:23", font: AppFont.medium(14), color: AppColor.sub))

        // 세로 타임라인
        stack.addArrangedSubview(timelineStep(
            title: "🚌 버스 92, 9",
            lines: ["3분 후 도착", "13개 정류장 · 21분 이동"]))
        stack.addArrangedSubview(timelineStep(
            title: "강변역 (B) 하차",
            lines: [], isLast: true))
        return stack
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

    // MARK: - 자동차 / 자전거 / 도보 탭 (동일 레이아웃 재사용)
    private func driveTab(duration: String, distance: String) -> UIView {
        let card = CardView(spacing: 6)
        card.addArranged(
            UILabel.make(duration, font: AppFont.bold(22), color: AppColor.ink),
            UILabel.make(distance, font: AppFont.medium(15), color: AppColor.sub)
        )

        let startButton = PrimaryButton(title: "안내 시작", bg: AppColor.ink)
        startButton.addTarget(self, action: #selector(startGuide), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [card, startButton])
        stack.axis = .vertical
        stack.spacing = 16
        return stack
    }

    @objc private func startGuide() {
        // TODO: 실제 길찾기 연동(카카오/티맵 등) 필요
        let alert = UIAlertController(title: "안내", message: "길찾기 연동 예정입니다.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}
