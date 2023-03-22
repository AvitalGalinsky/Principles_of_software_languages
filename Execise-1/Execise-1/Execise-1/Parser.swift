//
//  Parser.swift
//  Execise-1
//
//  Created by avital on 22/03/2023.
//

import Foundation

enum cmdType {
    case c_arithmetic
    case c_push
    case c_pop
    case c_label
    case c_goto
    case c_if
    case c_function
    case c_return
    case c_call
}

class Parser {
    var inputFileContent: String
    
    init(inputFilePath: String) throws {
        do{
            /* read file */
            inputFileContent = try String(contentsOfFile: inputFilePath)
        } catch {
            throw FileException(message: "Error reading file: \(error.localizedDescription)")
        }
    }
    
    /* Are there more lines in the input? */
    func hasMoreLines() -> Bool {
        return true
    }
    
    /* Reads the next command from the input and makes it the current command.
     This method should be called only if hasMoreLines is true.
     Initially there is no current command */
    func advance() {
        
    }
    
    /* Returns a constant representing the type of the current command.
     If the current command is an arithmetic-logical command, returns c_arithmetic */
    func commandType() -> cmdType {
        return cmdType.c_arithmetic
    }
    
    /* Returns the first argument of the current command.
     In the case of c_arithmetic, the command itself (add, sub, etc.) is returned.
     Should not be called if the current command is c_return */
    func arg1() -> String {
        return ""
    }
    
    /* Returns the second argument of the current command.
     Should be called only if the current command is c_push, c_pop, c_function or c_call */
    func arg2() -> Int {
        return 0
    }
}
