//
//  Exercise4Main.swift
//  Exercises
//
//  Created by avital on 24/05/2023.
//

import Foundation

func Exercise5_main(folderPath : String) {
    let extensionType = "jack"
    
    do {
        /* get list of all files in a folder who ends with specific extension:*/
        let folderURL = URL(fileURLWithPath: folderPath)
        let readFilesURLs = try FileManager.default.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil)
        let filteredFiles = readFilesURLs.filter{($0.pathExtension == extensionType)}
        let raedFilesNames = filteredFiles.map {$0.lastPathComponent}
        
        let analyzer = JackAnalyzer()
    
        for fileName in raedFilesNames {
            let index = fileName.lastIndex(of: ".")!
            let nameWithoutExtension = fileName[..<index]
            
            /* name for tokens and tree files: */
            let treeFilePath = "\(folderPath)/\(nameWithoutExtension).vm"
            
            try analyzer.createTokenList(jackFile: "\(folderPath)/\(fileName)")
            analyzer.createVMFile(outputVMFile: treeFilePath)
        }
        
    } catch {print(error.localizedDescription)}
}
