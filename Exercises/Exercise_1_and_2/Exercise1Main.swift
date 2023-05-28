//
//  main.swift
//  Execise-1
//
//  Created by avital on 20/03/2023.
//
import Foundation

func Exercise1_main() {
    //read input:
    print("Please enter the path of your folder:")
    var folderPath = readLine()!
    if (folderPath.last != "/") {
        folderPath += "/"
    }
    let extensionType = "vm"
    
    do {
        /* get list of all files in a folder who ends with specific extension:*/
        let folderURL = URL(fileURLWithPath: folderPath)
        let readFilesURLs = try FileManager.default.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil)
        let filteredFiles = readFilesURLs.filter{($0.pathExtension == extensionType)}
        let raedFilesNames = filteredFiles.map {$0.lastPathComponent}
        
        /* name of write file: */
        let folderName = folderURL.lastPathComponent
        let writeFilePath = folderPath + folderName + ".asm"
        
        let codeWriter = try CodeWriter(outputFilePath: writeFilePath)
        
        for fileName in raedFilesNames {
            /* read files one by one: */
            let parser = try Parser(inputFilePath: folderPath + fileName)
            //work on file
            let index = fileName.lastIndex(of: ".")!
            codeWriter.SetFileName(fileName: String(fileName.prefix(upTo: index)) + "\n")
            while(parser.hasMoreLines()) {
                parser.advance()
                switch (parser.commandType()) {
                case cmdType.c_arithmetic:
                    codeWriter.WriteArithmetic(command: parser.arg1())
                case cmdType.c_push, cmdType.c_pop:
                    codeWriter.WritePushPop(cType: parser.commandType(), segment: parser.arg1(), index: parser.arg2())
                case cmdType.c_label:
                    codeWriter.WriteLabel(label: parser.arg1())
                case cmdType.c_goto:
                    codeWriter.WriteGoto(label: parser.arg1())
                case cmdType.c_if:
                    codeWriter.WriteIf(label: parser.arg1())
                case cmdType.c_call:
                    codeWriter.WriteCall(functionName: parser.arg1(), nArgs: parser.arg2())
                case cmdType.c_function:
                    codeWriter.WriteFunction(functionName: parser.arg1(), nVars: parser.arg2())
                case cmdType.c_return:
                    codeWriter.WriteReturn()
                default:
                    continue
                }
            }
        }
        codeWriter.Close()
        
    } catch {print(error.localizedDescription)}
}
