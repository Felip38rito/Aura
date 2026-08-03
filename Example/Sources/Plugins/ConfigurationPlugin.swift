import AuraKernel
import Foundation

@MainActor
final class ConfigurationPlugin: AuraKernelPlugin {
    let identifier = "configuration"
    let dependencies = ["logging"]

    private(set) var config: [String: String] = [:]

    func boot(kernel: AuraKernel) {
        config = [
            "api_url": "https://api.aura.app",
            "app_version": "1.0.0",
            "environment": "development"
        ]
    }
}