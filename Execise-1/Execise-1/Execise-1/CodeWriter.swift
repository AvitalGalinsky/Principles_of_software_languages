//
//  CodeWriter.swift
//  Execise-1
//
//  Created by avital on 22/03/2023.
//

import Foundation

class CodeWriter {
    private var outputFileHandle: FileHandle?
    private var conditionsCounter = 0
    
    init(outputFilePath: String) throws {
        //open file to write:
        if FileManager.default.fileExists(atPath: outputFilePath) {
            do {
                try FileManager.default.removeItem(atPath: outputFilePath)
            } catch {
                throw FileException(message: "Error removing file: \(error.localizedDescription)")
            }
        }
        /* create file for output: */
        FileManager.default.createFile(atPath: outputFilePath, contents: nil, attributes: nil)
        outputFileHandle = FileHandle(forWritingAtPath: outputFilePath)
        if (outputFileHandle == nil) {
            throw FileException(message: "Error open file: \(outputFilePath) for writing")
        }
    }
    
    /* Writes to the output file the assembly code that implements the given arithmetic-logical command */
    func WriteArithmetic(command: String) {
        switch command {
        case "add", "sub", "and", "or":
            writeBinaryCommand(vmCommand: command)
        case "neg", "not":
            writeUnaryCommand(vmCommand: command)
        case "eq", "gt", "lt":
            writeComparisonCommand(vmCommand: command)
        default:
            return
        }
    }
    
    /* Writes to the output file the assembly code that implements the given push or pop command. */
    func WritePushPop(cType: cmdType, segment: String, index: Int) {
        
    }
    
    /* Closes the output file */
    func Close(){
        if(outputFileHandle != nil) {
            (outputFileHandle!).closeFile()
        }
    }
    
    private func writeBinaryCommand(vmCommand: String) {
        var op = ""
        switch vmCommand {
        case "add":
            op = "+"
        case "sub":
            op = "-"
        case "and":
            op = "&"
        case "or":
            op = "|"
        default:
            return
        }
        
        let hackCommand = """
        @SP
        A=M-1
        D=M
        A=A-1
        M=D\(op)M
        @SP
        M=M-1
        """
        outputFileHandle!.write(hackCommand.data(using: .utf8)!)
    }
    
    private func writeUnaryCommand(vmCommand: String) {
        var op = ""
        switch vmCommand {
        case "neg":
            op = "-"
        case "not":
            op = "!"
        default:
            return
        }
        
        let hackCommand = """
        @SP
        A=M-1
        M=\(op)M
        """
        outputFileHandle!.write(hackCommand.data(using: .utf8)!)
    }
    
    private func writeComparisonCommand(vmCommand: String) {
        var hackCondition = ""
        switch vmCommand {
        case "eq":
            hackCondition = "JEQ"
        case "gt":
            hackCondition = "JGT"
        case "lt":
            hackCondition = "JLT"
        default:
            hackCondition = ""
        }
        let hackCommand = """
        @SP
        A=M-1
        D=M
        A=A-1
        D=D-M
        @IF_TRUE\(conditionsCounter)
        D;\(hackCondition)
        D=0
        @IF_FALSE\(conditionsCounter)
        0;JMP
        (IF_TRUE\(conditionsCounter))
        D=-1
        (IF_FALSE\(conditionsCounter))
        @SP
        A=M-1
        A=A-1
        M=D
        @SP
        M=M-1
        """
        outputFileHandle!.write(hackCommand.data(using: .utf8)!)
        conditionsCounter += 1
    }
    
}
