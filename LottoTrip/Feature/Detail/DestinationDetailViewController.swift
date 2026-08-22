//
//  DestinationDetailViewController.swift
//  LottoTrip
//
//  목적지 상세 — 정보 / 메뉴 / 후기 탭 (커스텀 언더라인 탭바 + 콘텐츠 스왑).
//

import UIKit
import SnapKit

// MARK: - UnderlineTabBar (코랄 언더라인 커스텀 탭바 · 상세/길찾기 공용)
/// 라벨 여러 개를 가로 배치하고, 선택 탭은 ink bold + 코랄 밑줄로 표시한다.
final class UnderlineTabBar: UIView {

    /// 탭 선택 시 인덱스 전달
    var onSelect: ((Int) -> Void)?

    private let stack = UIStackView()
    private var labels: [UILabel] = []
    private let underline = UIView()
    private var selectedIndex = 0

    init(titles: [String]) {
        super.init(frame: .zero)

        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.alignment = .fill
        addSubview(stack)
        stack.snp.makeConstraints { $0.edges.equalToSuperview() }

        for (idx, title) in titles.enumerated() {
            let label = UILabel.make(title, font: AppFont.medium(15), color: AppColor.sub, align: .center)
            label.isUserInteractionEnabled = true
            label.tag = idx
            label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped(_:))))
            labels.append(label)
            stack.addArrangedSubview(label)
        }

        // 하단 구분선 + 코랄 언더라인
        let baseline = UIView()
        baseline.backgroundColor = AppColor.line
        addSubview(baseline)
        baseline.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(1)
        }

        underline.backgroundColor = AppColor.coral
        underline.layer.cornerRadius = 1.5
        addSubview(underline)

        snp.makeConstraints { $0.height.equalTo(46) }
        // 초기 선택
        DispatchQueue.main.async { [weak self] in self?.select(0, notify: false) }
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    @objc private func tapped(_ gesture: UITapGestureRecognizer) {
        guard let idx = gesture.view?.tag else { return }
        select(idx, notify: true)
    }

    /// 지정 인덱스 선택 (notify=false 면 콜백 미호출)
    func select(_ index: Int, notify: Bool) {
        guard index >= 0, index < labels.count else { return }
        selectedIndex = index
        for (idx, label) in labels.enumerated() {
            label.font = idx == index ? AppFont.bold(15) : AppFont.medium(15)
            label.textColor = idx == index ? AppColor.ink : AppColor.sub
        }
        moveUnderline(to: index)
        if notify { onSelect?(index) }
    }

    private func moveUnderline(to index: Int) {
        layoutIfNeeded()
        let target = labels[index]
        underline.snp.remakeConstraints {
            $0.bottom.equalToSuperview()
            $0.height.equalTo(3)
            $0.width.equalTo(target).multipliedBy(0.55)
            $0.centerX.equalTo(target)
        }
        UIView.animate(withDuration: 0.2) { self.layoutIfNeeded() }
    }
}

// MARK: - DestinationDetailViewController
final class DestinationDetailViewController: BaseScrollViewController {

    private let detail: PlaceDetail

    /// 탭별 콘텐츠 컨테이너 (탭 전환 시 내부 뷰 스왑)
    private let contentContainer = UIView()

    init(detail: PlaceDetail = PlaceDetailSampleData.sample) {
        self.detail = detail
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = ""

        contentStack.addArrangedSubview(headerView())
        contentStack.addArrangedSubview(imagePlaceholder())

        let tabBar = UnderlineTabBar(titles: ["정보", "메뉴", "후기"])
        tabBar.onSelect = { [weak self] idx in self?.showTab(idx) }
        contentStack.addArrangedSubview(tabBar)

        contentStack.addArrangedSubview(contentContainer)
        showTab(0)
    }

    // MARK: - 상단 헤더 (장소명 + 상태/후기)
    private func headerView() -> UIView {
        let name = UILabel.make(detail.name, font: AppFont.bold(22), color: AppColor.ink)
        name.setContentHuggingPriority(.defaultLow, for: .horizontal)

        let status = UILabel.make(detail.openStatus, font: AppFont.semibold(13), color: AppColor.lime)
        let reviews = UILabel.make("방문자 후기 \(detail.reviewCount)", font: AppFont.medium(13), color: AppColor.sub)

        let right = UIStackView(arrangedSubviews: [status, reviews])
        right.axis = .vertical
        right.alignment = .trailing
        right.spacing = 2
        right.setContentHuggingPriority(.required, for: .horizontal)

        let row = UIStackView(arrangedSubviews: [name, right])
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 8
        return row
    }

    // MARK: - 대표 이미지 placeholder
    private func imagePlaceholder() -> UIView {
        let image = UIView()
        image.backgroundColor = AppColor.tileEmpty
        image.layer.cornerRadius = 16
        image.snp.makeConstraints { $0.height.equalTo(200) }
        let icon = UILabel.make("사진", font: AppFont.medium(14), color: AppColor.sub, align: .center)
        image.addSubview(icon)
        icon.snp.makeConstraints { $0.center.equalToSuperview() }
        return image
    }

    // MARK: - 탭 전환
    private func showTab(_ index: Int) {
        contentContainer.subviews.forEach { $0.removeFromSuperview() }
        let content: UIView
        switch index {
        case 1:  content = menuTab()
        case 2:  content = reviewTab()
        default: content = infoTab()
        }
        contentContainer.addSubview(content)
        content.snp.makeConstraints { $0.edges.equalToSuperview() }
    }

    // MARK: - 정보 탭
    private func infoTab() -> UIView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 14

        stack.addArrangedSubview(infoRow(symbol: "mappin", text: detail.address))
        stack.addArrangedSubview(infoRow(symbol: "clock", text: "\(detail.openStatus)   \(detail.hours)"))
        stack.addArrangedSubview(infoRow(symbol: "phone", text: detail.phone))

        // 도로명 / 우편번호 2열 정보 카드
        let card = CardView(spacing: 12)
        card.addArranged(infoColumn(title: "도로명", value: detail.roadAddress),
                         infoColumn(title: "우편번호", value: detail.zipCode))
        stack.addArrangedSubview(card)
        return stack
    }

    /// SF Symbol 아이콘 + 텍스트 한 줄
    private func infoRow(symbol: String, text: String) -> UIView {
        let icon = UIImageView(image: UIImage(systemName: symbol))
        icon.tintColor = AppColor.sub
        icon.contentMode = .scaleAspectFit
        icon.snp.makeConstraints { $0.size.equalTo(20) }

        let label = UILabel.make(text, font: AppFont.medium(14), color: AppColor.ink)

        let row = UIStackView(arrangedSubviews: [icon, label])
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 12
        return row
    }

    /// 2열 정보 카드용 (제목 + 값)
    private func infoColumn(title: String, value: String) -> UIView {
        let t = UILabel.make(title, font: AppFont.medium(12), color: AppColor.sub)
        t.snp.makeConstraints { $0.width.equalTo(56) }
        let v = UILabel.make(value, font: AppFont.medium(14), color: AppColor.ink)
        let row = UIStackView(arrangedSubviews: [t, v])
        row.axis = .horizontal
        row.alignment = .top
        row.spacing = 10
        return row
    }

    // MARK: - 메뉴 탭
    private func menuTab() -> UIView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        detail.menus.forEach { stack.addArrangedSubview(menuRow(name: $0)) }
        return stack
    }

    private func menuRow(name: String) -> UIView {
        // 원형 아바타 placeholder
        let avatar = UIView()
        avatar.backgroundColor = AppColor.tileEmpty
        avatar.layer.cornerRadius = 20
        avatar.snp.makeConstraints { $0.size.equalTo(40) }

        let label = UILabel.make(name, font: AppFont.semibold(15), color: AppColor.ink)
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)

        // 이미지 placeholder 2개
        let thumbs = UIStackView(arrangedSubviews: [thumb(), thumb()])
        thumbs.axis = .horizontal
        thumbs.spacing = 8

        let row = UIStackView(arrangedSubviews: [avatar, label, thumbs])
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 12

        let box = UIView()
        box.backgroundColor = AppColor.card
        box.layer.cornerRadius = 14
        box.layer.borderWidth = 1
        box.layer.borderColor = AppColor.line.cgColor
        box.addSubview(row)
        row.snp.makeConstraints { $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 12, left: 14, bottom: 12, right: 14)) }
        return box
    }

    private func thumb() -> UIView {
        let v = UIView()
        v.backgroundColor = AppColor.tileEmpty
        v.layer.cornerRadius = 8
        v.snp.makeConstraints { $0.size.equalTo(36) }
        return v
    }

    // MARK: - 후기 탭
    private func reviewTab() -> UIView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        (0..<3).forEach { _ in stack.addArrangedSubview(reviewCard()) }
        return stack
    }

    private func reviewCard() -> UIView {
        let avatar = UIView()
        avatar.backgroundColor = AppColor.tileEmpty
        avatar.layer.cornerRadius = 16
        avatar.snp.makeConstraints { $0.size.equalTo(32) }
        let nameLabel = UILabel.make("이름", font: AppFont.semibold(14), color: AppColor.ink)
        let head = UIStackView(arrangedSubviews: [avatar, nameLabel])
        head.axis = .horizontal
        head.alignment = .center
        head.spacing = 10

        let image = UIView()
        image.backgroundColor = AppColor.tileEmpty
        image.layer.cornerRadius = 10
        image.snp.makeConstraints { $0.height.equalTo(120) }

        let card = CardView(spacing: 12)
        card.addArranged(head, image)
        return card
    }
}
