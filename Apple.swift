#!/usr/bin/env swift

import Foundation

// Path to your source file
let sourceFile = "Apple.ASM"

// --- CONFIGURE THESE TWO COMMANDS ---

// 1. Assembler command: [executable, arg1, arg2, ...]
let assembleCommand: [String] = [
    "/usr/local/bin/ca65", // or "nasm", "vasm", etc.
    sourceFile,
    "-o", "Apple.o"
]

// 2. Runner command: e.g. linker, emulator, or your own tool
let runCommand: [String] = [
    "/usr/local/bin/ld65", // or your emulator
    "Apple.o",
    "-o", "Apple.bin"
    // add more args as needed
]

// --- PROCESS HELPER ---

@discardableResult
func runProcess(_ command: [String]) throws -> Int32 {
    guard let executable = command.first else {
        throw NSError(domain: "SwiftRunner", code: 1, userInfo: [NSLocalizedDescriptionKey: "Empty command"])
    }

    let args = Array(command.dropFirst())
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

// --- MAIN FLOW ---

do {
    print("Assembling \(sourceFile)...")
    let assembleStatus = try runProcess(assembleCommand)
    guard assembleStatus == 0 else {
        print("Assembly failed with status \(assembleStatus)")
        exit(assembleStatus)
    }

    print("Running output...")
    let runStatus = try runProcess(runCommand)
    guard runStatus == 0 else {
        print("Run failed with status \(runStatus)")
        exit(runStatus)
    }

    print("Done.")
} catch {
    fputs("Error: \(error)\n", stderr)
    exit(1)
}
