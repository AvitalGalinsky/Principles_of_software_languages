//
//  main.swift
//  Exercises
//
//  Created by avital on 24/05/2023.
//

import Foundation
//read input:
print("Please enter the path of your folder:")
var folderPath = readLine()!
if (folderPath.last != "/") {
    folderPath = "\(folderPath)/"
}

Exercise5_main(folderPath: folderPath)
//Exercise1_main(folderPath: folderPath)


