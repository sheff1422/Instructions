// Copyright (c) 2016-present Frédéric Maquin <fred@ephread.com> and contributors.
// Licensed under the terms of the MIT License.

import UIKit
import Instructions

// That's the default controller, using every defaults made available by Instructions.
// It can't get any simpler.
class TestFlowViewController: ProfileViewController {

    let text1 = "CoachMark 1"
    let text2 = "CoachMark 2"
    let text3 = "CoachMark 3"
    let text4 = "CoachMark 4"

    @IBOutlet var tapMeButton: UIButton!

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.coachMarksController.dataSource = self
        self.coachMarksController.delegate = self

        self.emailLabel?.layer.cornerRadius = 4.0
        self.postsLabel?.layer.cornerRadius = 4.0
        self.reputationLabel?.layer.cornerRadius = 4.0

        let skipView = CoachMarkSkipDefaultView()
        skipView.setTitle("Skip", for: .normal)

        self.coachMarksController.skipView = skipView
        self.coachMarksController.overlay.isUserInteractionEnabled = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    @IBAction func performButtonTap(_ sender: AnyObject) {
        self.coachMarksController.stop(immediately: true)
        self.coachMarksController.start(in: .window(over: self))
    }

    // MARK: - Protocol Conformance | CoachMarksControllerDelegate
    func coachMarksController(_ coachMarksController: CoachMarksController,
                              willLoadCoachMarkAt index: Int) -> Bool {
        print("willLoadCoachMarkAt: \(index)")
        return true
    }

    func coachMarksController(_ coachMarksController: CoachMarksController,
                              willShow coachMark: inout CoachMark,
                              afterSizeTransition: Bool,
                              at index: Int) {
        print("[DEPRECATED] willShow at: \(index), afterSizeTransition: \(afterSizeTransition)")
    }

    func coachMarksController(_ coachMarksController: CoachMarksController,
                              didShow coachMark: CoachMark,
                              afterSizeTransition: Bool,
                              at index: Int) {
        print("[DEPRECATED] didShow at: \(index), afterSizeTransition: \(afterSizeTransition)")
    }

    override func coachMarksController(_ coachMarksController: CoachMarksController,
                                       willShow coachMark: inout CoachMark,
                                       beforeChanging change: ConfigurationChange,
                                       at index: Int) {
        print("willShow at: \(index), beforeChanging: \(change)")
    }

    override func coachMarksController(_ coachMarksController: CoachMarksController,
                                       didShow coachMark: CoachMark,
                                       afterChanging change: ConfigurationChange,
                                       at index: Int) {
        print("didShow at: \(index), afterChanging: \(change)")
    }

    override func coachMarksController(_ coachMarksController: CoachMarksController,
                                       willHide coachMark: CoachMark,
                                       at index: Int) {
        print("willHide at: \(index)")
    }

    override func coachMarksController(_ coachMarksController: CoachMarksController,
                                       didHide coachMark: CoachMark,
                                       at index: Int) {
        print("didHide at: \(index)")
    }

    override func coachMarksController(_ coachMarksController: CoachMarksController,
                                       didEndShowingBySkipping skipped: Bool) {
        print("didEndShowingBySkipping: \(skipped)")
    }

    override func shouldHandleOverlayTap(in coachMarksController: CoachMarksController,
                                         at index: Int) -> Bool {
        print("shouldHandleOverlayTap at index: \(index)")

        if index >= 2 {
            print("Index greater than or equal to 2, skipping")
            coachMarksController.stop()
            return false
        } else {
            return true
        }
    }
}

// MARK: - Protocol Conformance | CoachMarksControllerDataSource
extension TestFlowViewController: CoachMarksControllerDataSource {
    func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {
        print("numberOfCoachMarksForCoachMarksController: \(String(describing: index))")
        return 4
    }

    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkAt index: Int) -> CoachMark {
        print("coachMarksForIndex: \(index)")
        switch index {
        case 0:
            return coachMarksController.helper.makeCoachMark(
                for: self.navigationController?.navigationBar,
                cutoutPathMaker: { (frame: CGRect) -> UIBezierPath in
                    return UIBezierPath(rect: frame)
                }
            )
        case 1:
            return coachMarksController.helper.makeCoachMark(for: self.handleLabel)
        case 2:
            var coachMark = coachMarksController.helper.makeCoachMark(for: self.tapMeButton)
            coachMark.isUserInteractionEnabledInsideCutoutPath = true

            return coachMark
        case 3:
            return coachMarksController.helper.makeCoachMark(for: self.reputationLabel)
        default:
            return coachMarksController.helper.makeCoachMark()
        }
    }

    func coachMarksController(
        _ coachMarksController: CoachMarksController,
        coachMarkViewsAt index: Int,
        madeFrom coachMark: CoachMark
    ) -> (bodyView: (UIView & CoachMarkBodyView), arrowView: (UIView & CoachMarkArrowView)?) {
        print("coachMarkViewsForIndex: \(index)")
        var coachViews: (bodyView: CoachMarkBodyDefaultView, arrowView: CoachMarkArrowDefaultView?)

        coachViews = coachMarksController.helper.makeDefaultCoachViews(
            withArrow: true,
            withNextText: false,
            arrowOrientation: coachMark.arrowOrientation
        )

        switch index {
        case 0:
            coachViews.bodyView.hintLabel.text = self.text1
            coachViews.bodyView.nextLabel.text = self.nextButtonText
        case 1:
            coachViews.bodyView.hintLabel.text = self.text2
            coachViews.bodyView.nextLabel.text = self.nextButtonText
        case 2:
            coachViews.bodyView.hintLabel.text = self.text3
            coachViews.bodyView.nextLabel.text = self.nextButtonText
        case 3:
            coachViews.bodyView.hintLabel.text = self.text4
            coachViews.bodyView.nextLabel.text = self.nextButtonText
        default: break
        }

        return (bodyView: coachViews.bodyView, arrowView: coachViews.arrowView)
    }
}
