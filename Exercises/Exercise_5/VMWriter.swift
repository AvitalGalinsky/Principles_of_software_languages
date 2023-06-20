//
//  VMWriter.swift
//  Exercises
//
//  Created by avital on 16/06/2023.
//

import Foundation

enum segmentType : CustomStringConvertible {
    case ARGUMENT
    case CONSTANT
    case LOCAL
    case STATIC
    case THIS
    case THAT
    case POINTER
    case TEMP
    
    var description: String {
        switch self {
        case .ARGUMENT:
            return "argument"
        case .CONSTANT:
            return "constant"
        case .LOCAL:
            return "local"
        case .STATIC:
            return "static"
        case .THIS:
            return "this"
        case .THAT:
            return "that"
        case .POINTER:
            return "pointer"
        case .TEMP:
            return "temp"
        }
    }
}

enum commandType : CustomStringConvertible {
    case ADD
    case SUB
    case NEG
    case EQ
    case GT
    case LT
    case AND
    case OR
    case NOT
    
    var description: String {
        switch self {
        case .ADD:
            return "add"
        case .SUB:
            return "sub"
        case .NEG:
            return "neg"
        case .EQ:
            return "eq"
        case .GT:
            return "gt"
        case .LT:
            return "lt"
        case .AND:
            return "and"
        case .OR:
            return "or"
        case .NOT:
            return "not"
        }
    }
}

class VMWriter {
    private var outputFileHandle: FileHandle?
    
    init(outputFilePath: String) {
        
        /* open file to write the vm code */
        if FileManager.default.fileExists(atPath: outputFilePath) {
            do {
                try FileManager.default.removeItem(atPath: outputFilePath)
            } catch {
                fatalError("Error removing file: \(outputFilePath)")
            }
        }
        /* create file for output: */
        FileManager.default.createFile(atPath: outputFilePath, contents: nil, attributes: nil)
        outputFileHandle = FileHandle(forWritingAtPath: outputFilePath)
        if (outputFileHandle == nil) {
            fatalError("Error open file: \(outputFilePath) for writing")
        }
    }
    
    func writePush(segment: segmentType, index: Int) {
        let command = """
        push \(segment) \(index)
        
        """
        outputFileHandle!.write(command.data(using: .utf8)!)
    }
    
    func writePop(segment: segmentType, index: Int) {
        let command = """
        pop \(segment) \(index)
        
        """
        outputFileHandle!.write(command.data(using: .utf8)!)
    }
    
    func writeArithmetic(command: commandType) {
        let command = """
        \(command)
        
        """
        outputFileHandle!.write(command.data(using: .utf8)!)
    }
    
    func writeLabel(label: String) {
        let command = """
        label \(label)
        
        """
        outputFileHandle!.write(command.data(using: .utf8)!)
    }
    
    func writeGoto(label: String) {
        let command = """
        goto \(label)
        
        """
        outputFileHandle!.write(command.data(using: .utf8)!)
    }
    
    func writeIf(label: String) {
        let command = """
        if-goto \(label)
        
        """
        outputFileHandle!.write(command.data(using: .utf8)!)
    }
    
    func writeCall(name: String, nArgs: Int) {
        let command = """
        call \(name) \(nArgs)
        
        """
        outputFileHandle!.write(command.data(using: .utf8)!)
    }
    
    func writeFunction(name: String, nVars: Int) {
        let command = """
        function \(name) \(nVars)
        
        """
        outputFileHandle!.write(command.data(using: .utf8)!)
    }
    
    func writeReturn() {
        let command = """
        return
        
        """
        outputFileHandle!.write(command.data(using: .utf8)!)
    }
    
    func Close() {
        if(outputFileHandle != nil) {
            (outputFileHandle!).closeFile()
        }
    }
}
