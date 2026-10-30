import Foundation

class ProcessRunner {
    static func execute(path: String, arguments: [String]) -> String {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: path)
        process.arguments = arguments
        
        var env = ProcessInfo.processInfo.environment
        env["PATH"] = "/var/jb/usr/bin:/var/jb/bin:/usr/bin:/bin"
        env["SDKROOT"] = "/var/jb/SDKs/iPhoneOS.sdk"
        process.environment = env
        
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe
        
        do {
            try process.run()
            process.waitUntilExit()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            return String(data: data, encoding: .utf8) ?? ""
        } catch {
            return "执行失败: \(error.localizedDescription)"
        }
    }
}