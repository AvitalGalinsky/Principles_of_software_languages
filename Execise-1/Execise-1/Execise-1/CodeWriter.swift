//
//  CodeWriter.swift
//  Execise-1
//
//  Created by avital on 22/03/2023.
//

import Foundation

class CodeWriter {
    var outputFileHandle: FileHandle?
    
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
    
}
