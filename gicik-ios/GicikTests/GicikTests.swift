import Testing
@testable import Gicik

struct GicikTests {
    @Test("Configuration bundle id default")
    func bundleIdDefault() {
        #expect(Configuration.bundleID.contains("gicik"))
    }
}
