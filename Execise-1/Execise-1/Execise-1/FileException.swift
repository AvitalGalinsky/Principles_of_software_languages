//
//  FileException.swift
//  Execise-1
//
//  Created by avital on 22/03/2023.
//

import Foundation

class FileException: Error {
    let message: String
    
    init(message: String) {
        self.message = message
    }
}
