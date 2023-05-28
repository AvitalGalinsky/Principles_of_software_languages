//
//  JackAnalyzer.swift
//  Exercises
//
//  Created by avital on 24/05/2023.
//


/**
 - The top-most/ main module
 - Input: a single filleName.jack, or a folder containing 0 or more such files
 - For each file:
    1. Creates a JackTokenizer from fileName.jack
    2. Creates an output file named fileName.xml
    3. Creates a CompilationEngine, and calls the compileClass method.
 */
import Foundation
