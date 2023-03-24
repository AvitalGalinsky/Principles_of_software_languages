//
//  Parser.swift
//  Execise-1
//
//  Created by avital on 22/03/2023.
//

import Foundation

enum cmdType {
    case c_none
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
    private var inputFileLines: [String] = []
    private var currentLineIndex = 0
    private var currentCommand: [String] = []
    
    init(inputFilePath: String) throws {
        do{
            
            /* read file */
            let inputFileContent = try String(contentsOfFile: inputFilePath)
            let inputFileLines = inputFileContent.components(separatedBy: "\n").filter {!$0.isEmpty }
        } catch {
            throw FileException(message: "Error reading file: \(error.localizedDescription)")
        }
    }
    
    /* Are there more lines in the input? */
    func hasMoreLines() -> Bool {
        if(currentLineIndex < inputFileLines.count) {
            return true
        }
        return false
    }
    
    /* Reads the next command from the input and makes it the current command.
     This method should be called only if hasMoreLines is true.
     Initially there is no current command */
    func advance() {
        currentCommand = inputFileLines[currentLineIndex].split(separator: " ", omittingEmptySubsequences: true).map { String($0)}
        currentLineIndex += 1
    }
    
    /* Returns a constant representing the type of the current command.
     If the current command is an arithmetic-logical command, returns c_arithmetic */
    func commandType() -> cmdType {
        let commandName = currentCommand[0]
        switch commandName {
        case "add", "sub", "neg", "eq", "gt", "lt", "and", "or", "not":
            return cmdType.c_arithmetic
        case "push":
            return cmdType.c_push
        case "pop":
            return cmdType.c_pop
        default:
            return cmdType.c_none
        }
    }
    
    /* Returns the first argument of the current command.
     In the case of c_arithmetic, the command itself (add, sub, etc.) is returned.
     Should not be called if the current command is c_return */
    func arg1() -> String {
        if(commandType() == cmdType.c_none){
            return ""
        }
        if(commandType() == cmdType.c_arithmetic){
            return currentCommand[0]
        }
        else {
            return currentCommand[1]
        }
    }
    
    /* Returns the second argument of the current command.
     Should be called only if the current command is c_push, c_pop, c_function or c_call */
    func arg2() -> Int {
        return Int(currentCommand[2])!
    }
}
