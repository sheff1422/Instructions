// Copyright (c) 2016-present Frédéric Maquin <fred@ephread.com> and contributors.
// Licensed under the terms of the MIT License.

import XCTest
@testable import Instructions

class CoachMarkHelperTests: XCTestCase {

    let instructionsRootView = InstructionsRootView(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
    let flowManager = MockedFlowManager(coachMarksViewController: CoachMarksViewController())

    lazy var coachMarkHelper: CoachMarkHelper = {
        return CoachMarkHelper(instructionsRootView: self.instructionsRootView,
                               flowManager: self.flowManager)
    }()

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testThatDefaultCoachMarkIsReturnedWhenViewIsNil() {

        let coachMark1 = coachMarkHelper.makeCoachMark()
        let coachMark2 = coachMarkHelper.makeCoachMark(for: nil)

        XCTAssertTrue(coachMark1 == CoachMark())
        XCTAssertTrue(coachMark2 == CoachMark())
    }

    func testThatReturnedCoachMarkContainsPointOfInterest() {
        let coachMark1 = coachMarkHelper.makeCoachMark(for: UIView(), pointOfInterest: CGPoint(x: 10, y: 20))
        var coachMark2 = CoachMark()

        coachMark2.pointOfInterest = CGPoint(x: 10, y: 20)

        XCTAssertTrue(coachMark1.pointOfInterest == coachMark2.pointOfInterest)
    }

    func testThatDefaultCutoutPathMakerIsUsed() {
        let frame = CGRect(x: 30, y: 30, width: 70, height: 20)
        let coachMark = coachMarkHelper.makeCoachMark(for: UIView(frame: frame))

        if let bezierPath = coachMark.cutoutPath {
            XCTAssertTrue(bezierPath.contains(frame.origin))
            XCTAssertTrue(bezierPath.contains(CGPoint(x: frame.origin.x + frame.size.width,
                                                      y: frame.origin.y)))
            XCTAssertTrue(bezierPath.contains(CGPoint(x: frame.origin.x,
                                                      y: frame.origin.y + frame.size.height)))
            XCTAssertTrue(bezierPath.contains(CGPoint(x: frame.origin.x + frame.size.width,
                                                      y: frame.origin.y + frame.size.height)))
        } else {
            XCTFail("Cutout Path is nil")
        }
    }

    func testThatCustomCutoutPathMakerIsUsed() {
        var control = false
        let frame = CGRect(x: 30, y: 30, width: 70, height: 20)

        _ = coachMarkHelper.makeCoachMark(for: UIView(frame: frame)) { frame in
            control = true
            return UIBezierPath(rect: frame)
        }

        XCTAssertTrue(control)
    }

    func testThatCoachMarkViewHasNoArrow() {
        let views1 = coachMarkHelper.makeDefaultCoachViews(withArrow: false)
        let views2 = coachMarkHelper.makeDefaultCoachViews(withArrow: false, arrowOrientation: .bottom)
        let views3 = coachMarkHelper.makeDefaultCoachViews(withArrow: false,
                                                           arrowOrientation: .bottom,
                                                           hintText: "", nextText: nil)

        XCTAssertTrue(views1.arrowView == nil)
        XCTAssertTrue(views2.arrowView == nil)
        XCTAssertTrue(views3.arrowView == nil)
    }

    func testThatCoachMarkBodyHasNextText() {
        let views = coachMarkHelper.makeDefaultCoachViews()

        XCTAssertTrue(views.bodyView.nextLabel.superview != nil)
    }

    func testThatCoachMarkBodyDoesNotHaveNextText() {
        let views = coachMarkHelper.makeDefaultCoachViews(withNextText: false)

        XCTAssertTrue(views.bodyView.nextLabel.isHidden)
    }

    func testThatCoachMarkBodyHasRightText() {
        let views = coachMarkHelper.makeDefaultCoachViews(hintText: "Hint", nextText: nil)
        let views2 = coachMarkHelper.makeDefaultCoachViews(hintText: "Hint", nextText: "Next")

        XCTAssertTrue(views.bodyView.hintLabel.text == "Hint")
        XCTAssertTrue(views.bodyView.nextLabel.text == nil)
        XCTAssertTrue(views.bodyView.nextLabel.isHidden)

        XCTAssertTrue(views2.bodyView.hintLabel.text == "Hint")
        XCTAssertTrue(views2.bodyView.nextLabel.text == "Next")
        XCTAssertFalse(views2.bodyView.nextLabel.isHidden)
    }

    func testThatUpdateDidNotOccur() {
        flowManager.isPaused = true
        flowManager.currentCoachMark = CoachMark()

        coachMarkHelper.updateCurrentCoachMark()

        XCTAssertTrue(flowManager.currentCoachMark == CoachMark())

        flowManager.isPaused = false
        flowManager.currentCoachMark = nil

        coachMarkHelper.updateCurrentCoachMark()

        XCTAssertTrue(flowManager.currentCoachMark == nil)

        flowManager.isPaused = false
        flowManager.currentCoachMark = CoachMark()

        coachMarkHelper.updateCurrentCoachMark()

        XCTAssertTrue(flowManager.currentCoachMark ==  CoachMark())
    }
}

class MockedFlowManager: FlowManager {
    private var _pause = false

    override var isPaused: Bool {
        get {
            return _pause
        }

        set {
            _pause = newValue
        }
    }
}
