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

    /// 상세를 조회할 슬롯 id (없으면 empty 상태로 표시)
    private let slotId: Int?

    /// 로딩 상태 — 정보 탭 표시에 사용
    private enum LoadState { case idle, loading, failed(String) }
    private var state: LoadState = .idle
    /// 서버 상세 조회 결과 (성공 시 채워짐)
    private var place: PlaceDetailDTO?

    /// 헤더 라벨 — 조회 완료 후 갱신
    private let nameLabel = UILabel.make("목적지", font: AppFont.bold(22), color: AppColor.ink)
    private let categoryLabel = UILabel.make("", font: AppFont.medium(13), color: AppColor.sub)

    /// 탭별 콘텐츠 컨테이너 (탭 전환 시 내부 뷰 스왑)
    private let contentContainer = UIView()
    /// 현재 선택된 탭 인덱스 (조회 완료 후 재렌더용)
    private var currentTab = 0

    init(slotId: Int? = nil) {
        self.slotId = slotId
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

        // slotId 가 있으면 상세 조회, 없으면 empty placeholder
        if let slotId = slotId {
            state = .loading
            fetch(slotId)
        }
        showTab(0)
    }

    // MARK: - 상세 조회
    private func fetch(_ slotId: Int) {
        APIClient.shared.slot.result(slotId: slotId) { [weak self] outcome in
            guard let self = self else { return }
            switch outcome {
            case .success(let response):
                self.place = response.place
                self.state = .idle
            case .failure(let error):
                self.state = .failed(error.description)
            }
            self.refresh()
        }
    }

    /// 헤더 + 현재 탭 재렌더
    private func refresh() {
        nameLabel.text = place?.name ?? "목적지"
        categoryLabel.text = place?.category ?? ""
        showTab(currentTab)
    }

    // MARK: - 상단 헤더 (장소명 + 카테고리)
    private func headerView() -> UIView {
        nameLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        categoryLabel.textAlignment = .right
        categoryLabel.setContentHuggingPriority(.required, for: .horizontal)

        let row = UIStackView(arrangedSubviews: [nameLabel, categoryLabel])
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
        currentTab = index
        contentContainer.subviews.forEach { $0.removeFromSuperview() }
        let content: UIView
        switch index {
        case 1:  content = centeredEmpty("메뉴 정보가 없어요")   // 백엔드에 메뉴 데이터 없음
        case 2:  content = centeredEmpty("후기가 없어요")       // 백엔드에 후기 데이터 없음
        default: content = infoTab()
        }
        contentContainer.addSubview(content)
        content.snp.makeConstraints { $0.edges.equalToSuperview() }
    }

    // MARK: - 정보 탭 (서버 상세 조회 결과)
    private func infoTab() -> UIView {
        // 조회 결과가 있으면 실제 정보 표시
        if let place = place {
            let stack = UIStackView()
            stack.axis = .vertical
            stack.spacing = 14

            stack.addArrangedSubview(infoRow(symbol: "mappin", text: place.address ?? "주소 정보가 없어요"))
            if let description = place.description, !description.isEmpty {
                let body = UILabel.make(description, font: AppFont.regular(14), color: AppColor.ink, lines: 0)
                stack.addArrangedSubview(body)
            }
            if let homepage = place.homepageUrl, !homepage.isEmpty {
                stack.addArrangedSubview(infoRow(symbol: "link", text: homepage))
            }
            return stack
        }

        // 결과 없음 — 상태별 placeholder
        switch state {
        case .loading:            return centeredEmpty("불러오는 중...")
        case .failed(let message): return centeredEmpty(message)
        case .idle:               return centeredEmpty("장소 정보가 없어요")
        }
    }

    /// SF Symbol 아이콘 + 텍스트 한 줄
    private func infoRow(symbol: String, text: String) -> UIView {
        let icon = UIImageView(image: UIImage(systemName: symbol))
        icon.tintColor = AppColor.sub
        icon.contentMode = .scaleAspectFit
        icon.snp.makeConstraints { $0.size.equalTo(20) }

        let label = UILabel.make(text, font: AppFont.medium(14), color: AppColor.ink, lines: 0)

        let row = UIStackView(arrangedSubviews: [icon, label])
        row.axis = .horizontal
        row.alignment = .top
        row.spacing = 12
        return row
    }

    // MARK: - 중앙 empty-state 라벨
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
}
