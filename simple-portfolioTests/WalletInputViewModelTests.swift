import Testing
@testable import simple_portfolio

struct WalletInputViewModelTests {

    @Test @MainActor
    func testValidAddress() {
        let vm = WalletInputViewModel()
        vm.address = "0x1234567890abcdef1234567890abcdef12345678"
        vm.validate()

        #expect(vm.isValid == true)
        #expect(vm.canSubmit == true)
        #expect(vm.validationError == nil)
    }

    @Test @MainActor
    func testInvalidAddress() {
        let vm = WalletInputViewModel()
        vm.address = "invalid"
        vm.validate()

        #expect(vm.isValid == false)
        #expect(vm.canSubmit == false)
        #expect(vm.validationError != nil)
    }
}
