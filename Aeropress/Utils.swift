//
//  Utils.swift
//  Aeropress
//
//  Created by Dan Weiner on 10/23/21.
//

import Foundation
import SwiftyBeaver

let log = SwiftyBeaver.self

func setUpLogging() {
    log.addDestination(ConsoleDestination())

    let fileDestination = FileDestination()
    fileDestination.format = "$J"
    log.addDestination(fileDestination)
    log.info("Logging to file at \(logURL)")
}

func dwFatalError(_ message: String) -> Never {
    log.error("Fatal error: \(message)")
    fatalError(message)
}
