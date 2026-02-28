import XCTest
@testable import PhaseDrivenAnimations

final class PhaseMappingTests: XCTestCase {
    func testPhaseMathWrap() {
        XCTAssertEqual(PhaseMath.wrap(0.25), 0.25, accuracy: 0.000_001)
        XCTAssertEqual(PhaseMath.wrap(1.25), 0.25, accuracy: 0.000_001)
        XCTAssertEqual(PhaseMath.wrap(-0.75), 0.25, accuracy: 0.000_001)
    }

    func testClockHandPhaseDriverMapping() {
        let driver = ClockHandPhaseDriver(period: 20, referenceDate: Date(timeIntervalSince1970: 0))
        XCTAssertEqual(driver.phase(at: Date(timeIntervalSince1970: 5)), 0.25, accuracy: 0.000_001)
        XCTAssertEqual(driver.radians(at: Date(timeIntervalSince1970: 10)), .pi, accuracy: 0.000_001)
    }

    func testSpriteSheetFrameIndexMapping() {
        let mapper = SpriteSheetPhaseMapping(rows: 4, cols: 4, fps: 8)
        XCTAssertEqual(mapper.frameCount, 16)
        XCTAssertEqual(mapper.frameIndex(for: 0), 0)
        XCTAssertEqual(mapper.frameIndex(for: 0.5), 8)
        XCTAssertEqual(mapper.frameIndex(for: 0.999), 15)
    }

    func testImageSequenceFrameIndexMapping() {
        let mapper = ImageSequencePhaseMapping(frameCount: 10, fps: 20)
        XCTAssertEqual(mapper.frameIndex(for: 0), 0)
        XCTAssertEqual(mapper.frameIndex(for: 0.49), 4)
        XCTAssertEqual(mapper.frameIndex(for: 0.99), 9)
    }
}
