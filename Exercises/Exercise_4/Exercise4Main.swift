//
//  Exercise4Main.swift
//  Exercises
//
//  Created by avital on 24/05/2023.
//

import Foundation

func Exercise4_main() {
    //read input:
    print("Please enter the path of your folder:")
    var folderPath = readLine()!
    if (folderPath.last != "/") {
        folderPath = "\(folderPath)/"
    }
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
            let tokenFliePath = "\(folderPath)/MyFiles/\(nameWithoutExtension)T.xml"
            let treeFilePath = "\(folderPath)/MyFiles/\(nameWithoutExtension).xml"
            try FileManager.default.createDirectory(atPath: "\(folderPath)/MyFiles/", withIntermediateDirectories: true, attributes: nil)

            
            try analyzer.createTokenFile(jackFile: "\(folderPath)/\(fileName)", outputTokensFile: tokenFliePath)
            analyzer.createTreeFile(tokensFile: tokenFliePath, outputTreeFile: treeFilePath)
        }
        
    } catch {print(error.localizedDescription)}
}
