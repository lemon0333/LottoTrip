//
//  PreferenceViewController.swift
//  LottoTrip
//
//  취향 설정 온보딩 플로우 코디네이터.
//  히어로 → 인트로 → 5단계(스타일·일정·예산·이동수단·숙소) → 메인 탭.
//  각 자식 화면은 좌하단 뒤로 / 확인·다음으로 스스로 전환을 요청하고,
//  컨테이너가 슬라이드 전환과 완료 처리를 담당한다.
//

import UIKit
import SnapKit

final class PreferenceViewController: UIViewController {

    private var pages: [UIViewController] = []
    private var index = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColor.card
        navigationController?.setNavigationBarHidden(true, animated: false)
        buildPages()
        // 스크린샷/미리보기용 디버그 훅: ONB_PAGE 로 특정 페이지부터 시작
        let start = Int(ProcessInfo.processInfo.environment["ONB_PAGE"] ?? "0") ?? 0
        show(index: min(max(start, 0), pages.count - 1), animated: false)
    }

    private func buildPages() {
        let hero = OnboardingHeroViewController()
        let intro = OnboardingIntroViewController()

        let steps: [OnboardingStepViewController] = [
            StyleStepViewController(),
            DurationStepViewController(),
            BudgetStepViewController(),
            TransportStepViewController(),
            AccommodationStepViewController()
        ]
        for (i, step) in steps.enumerated() { step.stepIndex = i }

        pages = [hero, intro] + steps

        for page in pages {
            switch page {
            case let hero as OnboardingHeroViewController:   hero.onNext = { [weak self] in self?.advance() }
            case let intro as OnboardingIntroViewController: intro.onNext = { [weak self] in self?.advance() }
                                                             intro.onBack = { [weak self] in self?.goBack() }
            case let step as OnboardingStepViewController:
                step.onNext = { [weak self] in self?.advance() }
                step.onBack = { [weak self] in self?.goBack() }
            default: break
            }
        }
    }

    // MARK: - 전환

    private func advance() {
        guard index < pages.count - 1 else { finish(); return }
        transition(to: index + 1, forward: true)
    }
    private func goBack() {
        guard index > 0 else { return }
        transition(to: index - 1, forward: false)
    }

    private func show(index newIndex: Int, animated: Bool) {
        let child = pages[newIndex]
        addChild(child)
        view.addSubview(child.view)
        child.view.frame = view.bounds
        child.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        child.didMove(toParent: self)
        index = newIndex
    }

    private func transition(to newIndex: Int, forward: Bool) {
        let current = pages[index]
        let next = pages[newIndex]
        addChild(next)
        next.view.frame = view.bounds
        next.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        let width = view.bounds.width
        next.view.transform = CGAffineTransform(translationX: forward ? width : -width, y: 0)
        view.addSubview(next.view)

        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            next.view.transform = .identity
            current.view.transform = CGAffineTransform(translationX: forward ? -width : width, y: 0)
        }, completion: { _ in
            current.willMove(toParent: nil)
            current.view.removeFromSuperview()
            current.removeFromParent()
            current.view.transform = .identity
            next.didMove(toParent: self)
            self.index = newIndex
        })
    }

    private func finish() {
        SceneDelegate.switchRoot(to: RootTabBarController())
    }
}

// MARK: - 히어로 (퍼즐 + 시작 유도)

final class OnboardingHeroViewController: UIViewController {
    var onNext: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColor.card

        // 좌상단 홈 아이콘 (레퍼런스의 '홈화면 아이콘')
        let homeIcon = UIView()
        homeIcon.backgroundColor = AppColor.ink
        homeIcon.layer.cornerRadius = 6
        view.addSubview(homeIcon)
        homeIcon.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            $0.leading.equalToSuperview().offset(20)
            $0.size.equalTo(26)
        }

        // 코랄 직소 퍼즐 클러스터 (상단)
        let panel = PuzzleClusterView()
        view.addSubview(panel)
        panel.snp.makeConstraints {
            $0.top.equalTo(homeIcon.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(view.snp.height).multipliedBy(0.5)
        }

        let title = UILabel.make("나만의 랜덤 여행,\n시작해 볼까요?", font: AppFont.bold(26), color: AppColor.ink)
        view.addSubview(title)
        title.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(28)
            $0.top.equalTo(panel.snp.bottom).offset(28)
        }

        // 다음(>) 버튼
        let next = UIButton(type: .system)
        var config = UIButton.Configuration.filled()
        config.image = UIImage(systemName: "chevron.right",
                               withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .bold))
        config.baseForegroundColor = .white
        config.baseBackgroundColor = AppColor.ink
        config.cornerStyle = .capsule
        next.configuration = config
        next.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
        view.addSubview(next)
        next.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(28)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(28)
            $0.size.equalTo(58)
        }
    }
    @objc private func nextTapped() { onNext?() }
}

/// 흰 배경 위에 큰 코랄 직소 조각들을 격자로 채운 장식 패널 (레퍼런스 히어로).
final class PuzzleClusterView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        clipsToBounds = true
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.sublayers?.filter { $0.name == "piece" }.forEach { $0.removeFromSuperlayer() }
        // 큰 직소 조각을 격자로 타일링. 홀수 행은 반 칸 밀어 맞물리는 느낌.
        let size: CGFloat = 118
        let cols = Int(ceil(bounds.width / size)) + 1
        let rows = Int(ceil(bounds.height / size)) + 1
        for row in 0..<rows {
            for col in 0..<cols {
                let x = CGFloat(col) * size + (row % 2 == 0 ? 0 : -size / 2)
                let y = CGFloat(row) * size
                let cell = CGRect(x: x, y: y, width: size, height: size)
                let piece = CAShapeLayer()
                piece.name = "piece"
                piece.path = PuzzlePieceView.jigsawPath(in: cell).cgPath
                piece.fillColor = AppColor.coral.cgColor
                layer.addSublayer(piece)
            }
        }
    }
}

// MARK: - 인트로 (취향 설정 안내)

final class OnboardingIntroViewController: UIViewController {
    var onNext: (() -> Void)?
    var onBack: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColor.card

        // 흐릿한 강원 지도 느낌의 코랄 블롭
        let blob = UIView()
        blob.backgroundColor = AppColor.coral.withAlphaComponent(0.18)
        blob.layer.cornerRadius = 120
        view.addSubview(blob)
        blob.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(280); $0.height.equalTo(360)
        }

        let title = UILabel.make("나의 취향과 상황을\n설정해 보아요.", font: AppFont.bold(24), color: AppColor.ink, align: .center)
        view.addSubview(title)
        title.snp.makeConstraints { $0.center.equalToSuperview() }

        // 진행: 탭하면 첫 단계로
        let tap = UITapGestureRecognizer(target: self, action: #selector(nextTapped))
        view.addGestureRecognizer(tap)

        let next = UIButton(type: .system)
        var config = UIButton.Configuration.filled()
        config.image = UIImage(systemName: "chevron.right",
                               withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .bold))
        config.baseForegroundColor = .white
        config.baseBackgroundColor = AppColor.coral
        config.cornerStyle = .capsule
        next.configuration = config
        next.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
        view.addSubview(next)
        next.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(28)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(28)
            $0.size.equalTo(58)
        }

        let back = CircleBackButton()
        back.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        view.addSubview(back)
        back.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(16)
        }
    }
    @objc private func nextTapped() { onNext?() }
    @objc private func backTapped() { onBack?() }
}
