//
//  ClipKeepUITestsLaunchTests.swift
//  ClipKeepUITests
//
//  Created by Bhargav Murki on 8/8/24.
//

import XCTest

final class ClipKeepUITestsLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        throw XCTSkip("UI launch tests not yet implemented for the menu-bar–only experience.")
    }

    func testLaunch() throws {
        // Marked as skipped in setUp.
    }
}
