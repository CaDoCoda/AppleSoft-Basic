import Foundation

// 1. The Logic (The Definition)
func runASM(_ code: String) {
    print("--- Executing Assembly ---")
    print(code)
}

// 2. The Execution (The Call)
if let fileURL = Bundle.main.url(forResource: "Apple", withExtension: "asm") {
    do {
        let assemblyCode = try String(contentsOf: fileURL, encoding: .utf8)
        runASM(assemblyCode)
    } catch {
        print("Error reading file: \(error)")
    }
} else {
    print("Apple.asm not found in the app bundle.")
}
