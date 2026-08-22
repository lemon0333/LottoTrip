//
//  OnboardingStepViewController.swift
//  LottoTrip
//
//  단계 공통 뼈대:
//   - 인트로 상태: 질문 타이틀 + 퍼즐 히어로 + 진행 도트 + 좌하단 뒤로
//   - 퍼즐 탭 → 입력 상태: 채워진 타이틀 + 입력 컨텐츠 + 진행 도트 + 확인 체크
//  서브클래스는 inputContent / 유효성 / 값 저장만 구현한다.
//

import UIKit
import SnapKit

class OnboardingStepViewController: UIViewController {

    // 서브클래스가 주입하는 메타
    var stepIndex: Int = 0
    let stepTotal = 5

    /// 인트로 질문 (예: "나의 여행 스타일은?")
    var introQuestion: String { "" }
    /// 입력 화면 타이틀 (예: "아-이번 여행은___")
    var inputTitle: String { "" }
    /// 퍼즐 조각 실루엣
    var lobes: PuzzleInputView.Lobes { .init(top: true, right: true, bottom: true, left: true) }

    /// 컨테이너가 주입하는 콜백
    var onNext: (() -> Void)?
    var onBack: (() -> Void)?

    // 상태 뷰
    private let introContainer = UIView()
    private let inputContainer = UIView()
    private lazy var confirmButton = ConfirmCheckButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColor.card
        buildIntro()
        buildInput()
        inputContainer.isHidden = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // 스크린샷/미리보기용 디버그 훅: ONB_REVEAL=1 이면 입력 화면 바로 노출
        if ProcessInfo.processInfo.environment["ONB_REVEAL"] == "1", inputContainer.isHidden {
            revealInput()
        }
    }

    // MARK: - 인트로 상태

    private func buildIntro() {
        view.addSubview(introContainer)
        introContainer.snp.makeConstraints { $0.edges.equalToSuperview() }

        let title = UILabel.make(introQuestion, font: AppFont.bold(22), color: AppColor.ink, align: .center)
        let puzzle = PuzzleInputView(lobes: lobes)
        puzzle.addTarget(self, action: #selector(revealInput), for: .touchUpInside)
        let hint = UILabel.make("퍼즐을 눌러 입력해요 👆", font: AppFont.medium(14), color: AppColor.coral, align: .center)
        let dots = PageDots(total: stepTotal, current: stepIndex)

        let stack = UIStackView(arrangedSubviews: [title, puzzle, hint, dots])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 22
        stack.setCustomSpacing(30, after: hint)
        introContainer.addSubview(stack)
        stack.snp.makeConstraints {
            $0.centerY.equalToSuperview().offset(-30)
            $0.leading.trailing.equalToSuperview().inset(28)
        }

        // 화면 아무 데나 눌러도 입력으로 진입 (발견성 개선). 단, 버튼(뒤로) 위 탭은 제외.
        let tap = UITapGestureRecognizer(target: self, action: #selector(revealInput))
        tap.delegate = self
        introContainer.addGestureRecognizer(tap)

        startHintPulse(hint)

        let back = CircleBackButton()
        back.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        introContainer.addSubview(back)
        back.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(16)
        }
    }

    // MARK: - 입력 상태

    private func buildInput() {
        view.addSubview(inputContainer)
        inputContainer.snp.makeConstraints { $0.edges.equalToSuperview() }

        let title = UILabel.make(inputTitle, font: AppFont.bold(22), color: AppColor.ink, align: .center)
        let content = makeInputContent()
        let dots = PageDots(total: stepTotal, current: stepIndex)

        let stack = UIStackView(arrangedSubviews: [title, content, dots])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 22
        stack.setCustomSpacing(28, after: content)
        inputContainer.addSubview(stack)
        stack.snp.makeConstraints {
            $0.top.equalTo(inputContainer.safeAreaLayoutGuide).offset(64)
            $0.leading.trailing.equalToSuperview().inset(28)
        }
        content.snp.makeConstraints { $0.leading.trailing.equalToSuperview() }

        confirmButton.addTarget(self, action: #selector(confirmTapped), for: .touchUpInside)
        inputContainer.addSubview(confirmButton)
        confirmButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.greaterThanOrEqualTo(stack.snp.bottom).offset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(36)
        }

        let back = CircleBackButton()
        back.addTarget(self, action: #selector(inputBackTapped), for: .touchUpInside)
        inputContainer.addSubview(back)
        back.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(16)
        }
    }

    private func startHintPulse(_ view: UIView) {
        UIView.animate(withDuration: 0.7, delay: 0, options: [.repeat, .autoreverse]) {
            view.alpha = 0.35
        }
    }

    // MARK: - 상태 전환

    @objc private func revealInput() {
        crossfade(from: introContainer, to: inputContainer)
    }
    @objc private func inputBackTapped() {
        crossfade(from: inputContainer, to: introContainer)
    }
    private func crossfade(from: UIView, to: UIView) {
        to.alpha = 0; to.isHidden = false
        UIView.animate(withDuration: 0.25, animations: {
            from.alpha = 0; to.alpha = 1
        }, completion: { _ in
            from.isHidden = true; from.alpha = 1
        })
    }

    @objc private func backTapped() { onBack?() }
    @objc private func confirmTapped() {
        guard isValid else { return }
        saveValue()
        onNext?()
    }

    /// 서브클래스가 확인 버튼 활성/비활성을 갱신할 때 호출
    func updateConfirm() { confirmButton.setEnabled(isValid) }

    // MARK: - 서브클래스 오버라이드 포인트

    /// 입력 컨트롤 뷰
    func makeInputContent() -> UIView { UIView() }
    /// 확인 버튼 활성 조건
    var isValid: Bool { true }
    /// 확인 시 TripPreferenceStore 에 저장
    func saveValue() {}
}

// MARK: - 인트로 탭 제스처: 버튼(뒤로 등) 위 탭은 무시

extension OnboardingStepViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldReceive touch: UITouch) -> Bool {
        // 터치 지점이 버튼/컨트롤이면 제스처 대신 그 컨트롤이 처리하도록 양보
        !(touch.view is UIControl)
    }
}
