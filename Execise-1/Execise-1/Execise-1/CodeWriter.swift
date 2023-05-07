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
    private var returnAddressCounter = 0
    private var currentFileName = ""
    
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
        
        let initCmd = """
        //init:
        @256
        D=A
        @SP
        M=D
        
        """
        outputFileHandle!.write(initCmd.data(using: .utf8)!)
        WriteCall(functionName: "Sys.init", nArgs: 0)
        
    }
    
    /* Writes to the output file the assembly code that implements the given arithmetic-logical command */
    func WriteArithmetic(command: String) {
        let vmCommand = """
        
        //\(command)
        
        """
        outputFileHandle!.write(vmCommand.data(using: .utf8)!)
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
        switch cType {
            case cmdType.c_push:
                writePush(segment: segment, index: index)
            case cmdType.c_pop:
                writePop(segment: segment, index: index)
            default:
                return
        }
    }
    
    func WriteLabel(label: String) {
        let hackCommand = """
        (\(currentFileName).\(label))
        
        """
        outputFileHandle!.write(hackCommand.data(using: .utf8)!)
    }
    
    func WriteGoto(label: String) {
        let hackCommand = """
        @\(currentFileName).\(label)
        0; JMP
        
        """
        outputFileHandle!.write(hackCommand.data(using: .utf8)!)
    }
    
    func WriteIf(label: String) {
        let hackCommand = """
        @SP
        M=M-1
        A=M
        D=M
        @\(currentFileName).\(label)
        D; JNE
        
        """
        outputFileHandle!.write(hackCommand.data(using: .utf8)!)
    }
    
    func WriteFunction(functionName: String, nVars: Int) {
//        WriteLabel(label: functionName)
        
        let hackCommand = """
        (\(functionName))
        
        """
        outputFileHandle!.write(hackCommand.data(using: .utf8)!)
        
        for _ in 0..<nVars {
            writePushConstant(index: 0)
        }
        
    }
    
    func WriteCall(functionName: String, nArgs: Int) {
        let returnLabel = "returnAddress_\(returnAddressCounter)"
        pushReturnAddress(returnLabel: "\(currentFileName).\(returnLabel)")
        saveSegmetsPointer(segment : "LCL")
        saveSegmetsPointer(segment : "ARG")
        saveSegmetsPointer(segment : "THIS")
        saveSegmetsPointer(segment : "THAT")
        repositionsARG(nArgs : nArgs)
        repositionsLCL()
        let hackCommand = """
        @\(functionName)
        0; JMP
        
        """
        outputFileHandle!.write(hackCommand.data(using: .utf8)!)
        
        WriteLabel(label: returnLabel)
        returnAddressCounter += 1;
    }
    
    func WriteReturn() {
        var hackCommand = """
        //endFrame = LCL | gets the address at the frame's end:
        @LCL
        D=M
        //RAM[13] = retAddr = *(FRAME-5) | gets the return address:
        @5
        A=D-A
        D=M
        @13
        M=D
        //*ARG=pop() | puts the return value for the caller:
        @SP
        M=M-1
        A=M
        D=M
        @ARG
        A=M
        M=D
        //SP = ARG+1 | repositions SP:
        @ARG
        D=M
        @SP
        M=D+1
        
        """
        outputFileHandle!.write(hackCommand.data(using: .utf8)!)
        
        updatePointer(pointer: "THAT")
        updatePointer(pointer: "THIS")
        updatePointer(pointer: "ARG")
        updatePointer(pointer: "LCL")
        
        hackCommand = """
        @13
        A=M
        0; JMP
        
        """
        outputFileHandle!.write(hackCommand.data(using: .utf8)!)
        
    }
    
    private func updatePointer(pointer : String){
        let hackCommand = """
        //restore \(pointer)
        @LCL
        M=M-1
        A=M
        D=M
        @\(pointer)
        M=D
        
        """
        outputFileHandle!.write(hackCommand.data(using: .utf8)!)
    }
    
    
//    private functions:
    
    private func pushReturnAddress(returnLabel : String){
        let hackCommand = """
        @\(returnLabel)
        D=A
        @SP
        A=M
        M=D
        @SP
        M=M+1
        
        """
        outputFileHandle!.write(hackCommand.data(using: .utf8)!)
    }
    
    private func  saveSegmetsPointer(segment : String){
        let hackCommand = """
        //push \(segment)
        @\(segment)
        D=M
        @SP
        A=M
        M=D
        @SP
        M=M+1
        
        """
        outputFileHandle!.write(hackCommand.data(using: .utf8)!)
    }

    private func repositionsARG(nArgs : Int){
        let hackCommand = """
        //ARG = SP - \(nArgs) - 5
        @SP
        D=M
        @\(nArgs + 5)
        D=D-A
        @ARG
        M=D
        
        """
        outputFileHandle!.write(hackCommand.data(using: .utf8)!)
    }
    private func repositionsLCL(){
        let hackCommand = """
        //LCL = SP
        @SP
        D=M
        @LCL
        M=D
        
        """
        outputFileHandle!.write(hackCommand.data(using: .utf8)!)
    }
    
    private func writePush(segment: String, index: Int) {
        let vmCommand = """
        
        //push \(segment) \(index)
        
        """
        outputFileHandle!.write(vmCommand.data(using: .utf8)!)
        switch segment {
            case "local", "argument", "this", "that":
                writePushSegmentType1(segment:segment, index:index)
            case "constant":
                writePushConstant(index:index)
            case "temp":
                writePushTemp(index:index)
            case "pointer":
                writePushPointer(index: index)
            case "static":
                writePushStatic(index: index)
            default:
                return
        }
    }
    
    private func writePop(segment: String, index: Int) {
        let vmCommand = """
        
        //pop \(segment) \(index)
        
        """
        outputFileHandle!.write(vmCommand.data(using: .utf8)!)
        switch segment {
            case "local", "argument", "this", "that":
                writePopSegmentType1(segment:segment, index:index)
            case "temp":
                writePopTemp(index:index)
            case "pointer":
                writePopPointer(index: index)
            case "static":
                writePopStatic(index: index)
            default:
                return
        }
    }
    
    func SetFileName(fileName: String) {
        currentFileName = fileName.trimmingCharacters(in: .newlines)
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
        //2+3
        let hackCommand = """
        @SP
        A=M-1
        D=M
        A=A-1
        M=M\(op)D
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
            return
        }
        let hackCommand = """
        @SP
        A=M-1
        D=M
        A=A-1
        D=M-D
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
    
    private func writePushConstant(index : Int) {
        let hackCommand = """
        @\(index)
        D=A
        @SP
        A=M
        M=D
        @SP
        M=M+1
        
        """
        outputFileHandle!.write(hackCommand.data(using: .utf8)!)
    }
    
    private func writePushSegmentType1(segment : String, index : Int) {
        var stackPtr = ""
        switch segment {
            case "local":
                stackPtr = "LCL"
            case "argument":
                stackPtr = "ARG"
            case "this":
                stackPtr = "THIS"
            case "that":
                stackPtr = "THAT"
            default:
                return
        }
        
        let hackCommand = """
        @\(index)
        D=A
        @\(stackPtr)
        A=M+D
        D=M
        @SP
        A=M
        M=D
        @SP
        M=M+1
        
        """
        outputFileHandle!.write(hackCommand.data(using: .utf8)!)
    }
    
    private func writePopSegmentType1(segment : String, index : Int) {
        var stackPtr = ""
        switch segment {
            case "local":
                stackPtr = "LCL"
            case "argument":
                stackPtr = "ARG"
            case "this":
                stackPtr = "THIS"
            case "that":
                stackPtr = "THAT"
            default:
                return
        }
        
        var hackCommand = """
        @SP
        A=M-1
        D=M
        @\(stackPtr)
        A=M
        
        """
        for _ in 0..<index {
            hackCommand += """
            A=A+1
            
            """
        }
        hackCommand += """
        M=D
        @SP
        M=M-1
        
        """
        outputFileHandle!.write(hackCommand.data(using: .utf8)!)
    }
    
    private func writePushTemp(index : Int) {
        let hackCommand = """
        @\(5+index)
        D=M
        @SP
        A=M
        M=D
        @SP
        M=M+1
        
        """
        outputFileHandle!.write(hackCommand.data(using: .utf8)!)
    }
    
    private func writePopTemp(index: Int) {
        let hackCommand = """
        @SP
        A=M-1
        D=M
        @\(5+index)
        M=D
        @SP
        M=M-1
        
        """
        outputFileHandle!.write(hackCommand.data(using: .utf8)!)
    }
    
    private func writePushPointer(index: Int) {
        var addr = ""
        if index == 0 {
            addr = "THIS"
        } else {
            addr = "THAT"
        }
        let hackCommand = """
        @\(addr)
        D=M
        @SP
        A=M
        M=D
        @SP
        M=M+1
        
        """
        outputFileHandle!.write(hackCommand.data(using: .utf8)!)
    }
    
    private func writePopPointer(index: Int) {
        var addr = ""
        if index == 0 {
            addr = "THIS"
        } else {
            addr = "THAT"
        }
        let hackCommand = """
        @SP
        A=M-1
        D=M
        @\(addr)
        M=D
        @SP
        M=M-1
        
        """
        outputFileHandle!.write(hackCommand.data(using: .utf8)!)
    }
    
    private func writePushStatic(index: Int) {
        let hackCommand = """
        @\(currentFileName).\(index)
        D=M
        @SP
        A=M
        M=D
        @SP
        M=M+1
        
        """
        outputFileHandle!.write(hackCommand.data(using: .utf8)!)
    }
    
    private func writePopStatic(index: Int) {
        let hackCommand = """
        @SP
        M=M-1
        A=M
        D=M
        @\(currentFileName).\(index)
        M=D
        
        """
        outputFileHandle!.write(hackCommand.data(using: .utf8)!)
    }
}
