import Testing
@testable import Efso

struct EfsoTests {
    @Test("Configuration bundle id default")
    func bundleIdDefault() {
        #expect(Configuration.bundleID.contains("efso"))
    }
}
