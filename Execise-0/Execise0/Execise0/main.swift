//
//  main.swift
//  Execise0
//
//  Created by avital on 14/03/2023.
//

import Foundation

var totalBuy : Float = 0
var totalCell : Float = 0

func workOnFile(writeFileHandle:FileHandle, fileName:String, fileContent:String) {
    let partitionChar:Character = "."
    if let index = fileName.lastIndex(of: partitionChar) {
        let nameWithoutExe = (String(fileName.prefix(upTo: index)) + "\n").data(using: .utf8)
        writeFileHandle.write(nameWithoutExe!)
    }
    let lines = fileContent.split(separator: "\n")
    for line in lines {
        let words = line.split(separator: " ")
        if(words[0] == "buy") {
            HandleBuy(productName: String(words[1]), amount: Int(words[2])!, price: Float(words[3])!, writeFileHandle: writeFileHandle)
        }
        else if(words[0] == "cell") {
            HandleCell(productName: String(words[1]), amount: Int(words[2])!, price: Float(words[3])!, writeFileHandle: writeFileHandle)
        }
    }
}

func HandleBuy(productName:String, amount:Int, price:Float, writeFileHandle: FileHandle) {
    let buyText = ("### BUY \(productName) ###\n").data(using: .utf8)
    writeFileHandle.write(buyText!)
    let multi = (String(Float(amount) * price) + "\n").data(using: .utf8)
    writeFileHandle.write(multi!)
    
    totalBuy += Float(amount) * price
}

func HandleCell(productName:String, amount:Int, price:Float, writeFileHandle:FileHandle) {
    let cellText = ("$$$ CELL \(productName) $$$\n").data(using: .utf8)
    writeFileHandle.write(cellText!)
    let multi = (String(Float(amount) * price) + "\n").data(using: .utf8)
    writeFileHandle.write(multi!)
    
    totalCell += Float(amount) * price
}

func main() {
    //read input:
    print("Please enter the path of your file:")
    var folderPath = readLine()!
    if (folderPath.last != "/") {
        folderPath += "/"
    }
    print(folderPath)
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
        
        //open file to write:
        if FileManager.default.fileExists(atPath: writeFilePath) {
            do {
                try FileManager.default.removeItem(atPath: writeFilePath)
            } catch {}
        }
        /* create file for output: */
        FileManager.default.createFile(atPath: writeFilePath, contents: nil, attributes: nil)
        
        if let writeFileHandle = FileHandle(forWritingAtPath: writeFilePath) {
            for fileName in raedFilesNames {
                do{
                    /* read files one by one: */
                    let contents = try String(contentsOfFile: folderPath + fileName)
                    workOnFile(writeFileHandle: writeFileHandle, fileName: fileName, fileContent: contents)
                } catch {
                    print("Error: \(error.localizedDescription)")
                }
            }
            let totalBuyStr = ("TOTAL BUY: \(totalBuy)\n").data(using: .utf8)
            let totalCellStr = ("TOTAL CELL: \(totalCell)\n").data(using: .utf8)
            
            writeFileHandle.write(totalBuyStr!)
            writeFileHandle.write(totalCellStr!)
            print("TOTAL BUY: \(totalBuy)")
            print("TOTAL CELL: \(totalCell)")
            
            //close the file
            writeFileHandle.closeFile()
            
        } else {
            print("Unable to open file for writing")
        }
        
    } catch {
        print("Error")
    }
}
main()





