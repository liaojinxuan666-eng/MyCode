import SwiftUI

struct ContentView: View {
    @State private var sourceCode = "#include <stdio.h>\n\nint main() {\n    printf(\"Hello, iOS IDE!\\n\");\n    return 0;\n}"
    @State private var consoleOutput = "准备就绪..."
    
    var body: some View {
        VStack(spacing: 10) {
            TextEditor(text: $sourceCode)
                .font(.system(size: 14, design: .monospaced))
                .autocorrectionDisabled()
                .autocapitalization(.none)
                .border(Color.gray, width: 1)
                .frame(maxHeight: .infinity)
            
            Button(action: buildAndRun) {
                Text("编译并运行 (clang)")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            
            ScrollView {
                Text(consoleOutput)
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(.green)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(8)
            }
            .background(Color.black)
            .cornerRadius(8)
            .frame(height: 200)
        }
        .padding()
    }
    
    func buildAndRun() {
        consoleOutput = "正在编译..."
        let tempDir = FileManager.default.temporaryDirectory
        let sourceURL = tempDir.appendingPathComponent("main.c")
        let binaryURL = tempDir.appendingPathComponent("main")
        
        do {
            try sourceCode.write(to: sourceURL, atomically: true, encoding: .utf8)
        } catch {
            consoleOutput = "写入源码失败: \(error)"
            return
        }
        
        let compileArgs = [sourceURL.path, "-o", binaryURL.path]
        let compileResult = ProcessRunner.execute(path: "/var/jb/usr/bin/clang", arguments: compileArgs)
        
        if !compileResult.isEmpty {
            consoleOutput = "编译报错:\n\(compileResult)"
            return
        }
        
        _ = ProcessRunner.execute(path: "/var/jb/usr/bin/ldid", arguments: ["-S", binaryURL.path])
        
        consoleOutput = "编译成功，运行结果:\n"
        let runResult = ProcessRunner.execute(path: binaryURL.path, arguments: [])
        consoleOutput += runResult
    }
}