//
//  main.swift
//  CocoaLisp
//
//  Created by Rod Schmidt on 5/14/19.
//  Copyright © 2019 infiniteNIL. All rights reserved.
//

import Foundation
import CocoaLisp

private func readLine(prompt: String) -> String? {
    if shouldUseReadline() {
        guard let cString = readline(prompt) else { return nil }
        defer { free(cString) }
        add_history(cString)
        return String(cString: cString)
    }
    else {
        print(prompt, terminator: "")
        return readLine(strippingNewline: true)
    }
}

private func shouldUseReadline() -> Bool {
    if CommandLine.argc > 1 && CommandLine.arguments[1] == "--disable_readline" {
        return false
    }
    return true
}

do {
    try CocoaLisp.start()

    if CommandLine.argc > 1 && !CommandLine.arguments[1].hasPrefix("--") {
        try CocoaLisp.load(filename: CommandLine.arguments[1])
        exit(0)
    }
}
catch {
    print(error)
    exit(-1)
}

print("CocoaLisp v0.1 © infiniteNIL Software, 2019")
print("Press Ctrl+c to exit")

while true {
    print()
    do {
        if let input = readLine(prompt: "> ") {
            print(try CocoaLisp.readEvalAndPrint(input))
        }
    }
    catch let error as CocoaLispError {
        print(error.message)
    }
    catch {
        print(error)
    }
}
