#!/usr/bin/env swift

import Foundation

// MARK: - Configuration
let cwd = FileManager.default.currentDirectoryPath
let sourceFile = "Apple.ASM"

// 1. Assembler command: Use a symbolic name for Swift logic OR a full path for external tools
let assembleCommand: [String] = [
    "swift-assembler", // or "/usr/local/bin/ca65"
    "\(cwd)/\(sourceFile)",
    "-o", "\(cwd)/Apple.o"
]

// 2. Runner command
let runCommand: [String] = [
    "swift-runner",    // or "/usr/local/bin/ld65"
    "\(cwd)/Apple.o",
    "-o", "\(cwd)/Apple.bin"
]

// MARK: - Swift-based Hooks (Internal Logic)

func assembleSwiftASM(args: [String]) -> Int32 {
    // TODO: Integrate your Swift 6502 assembler logic here
    print("🛠️  Internal Swift Assembler: Processing \(args.joined(separator: " "))")
    return 0 // Return non-zero to trigger failure
}

func runSwiftBinary(args: [String]) -> Int32 {
    // TODO: Integrate your Swift 6502 emulator/runner here
    print("🚀 Internal Swift Runner: Executing \(args.joined(separator: " "))")
    return 0
}

// MARK: - Process Execution Engine

@discardableResult
func runProcess(_ command: [String]) throws -> Int32 {
    guard let executable = command.first else {
        throw NSError(domain: "SwiftRunner", code: 1, userInfo: [NSLocalizedDescriptionKey: "Empty command"])
    }

    print("→ Executing: \(executable) \(command.dropFirst().joined(separator: " "))")

    // ROUTING LOGIC: Switch between internal Swift functions and external binaries
    switch executable {
    case "swift-assembler":
        return assembleSwiftASM(args: Array(command.dropFirst()))
    case "swift-runner":
        return runSwiftBinary(args: Array(command.dropFirst()))
    default:
        // Handle as external system process
        return try runExternalProcess(executable: executable, args: Array(command.dropFirst()))
    }
}

func runExternalProcess(executable: String, args: [String]) throws -> Int32 {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: executable)
    process.arguments = args

    let pipe = Pipe()
    process.standardOutput = pipe
    process.standardError = pipe

    try process.run()
    process.waitUntilExit()

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    if let output = String(data: data, encoding: .utf8), !output.isEmpty {
        print(output)
    }

    return process.terminationStatus
}

// MARK: - Main Execution Flow

do {
    print("--- Starting Build Pipeline ---")
    
    let assembleStatus = try runProcess(assembleCommand)
    guard assembleStatus == 0 else {
        print("❌ Assembly failed with status \(assembleStatus)")
        exit(assembleStatus)
    }

    let runStatus = try runProcess(runCommand)
    guard runStatus == 0 else {
        print("❌ Run failed with status \(runStatus)")
        exit(runStatus)
    }

    print("--- Build Finished Successfully ---")
} catch {
    fputs("⚠️ Critical Error: \(error.localizedDescription)\n", stderr)
    exit(1)
}
