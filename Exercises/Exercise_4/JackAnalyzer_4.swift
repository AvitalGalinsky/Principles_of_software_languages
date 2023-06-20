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

class JackAnalyzer_4 {
    
    init() {
        
    }
    
    func createTokenFile(jackFile : String, outputTokensFile : String) throws {
        let tokenizer =  try JackTokenizer_4(jackFilePath: jackFile, outputTokensFile: outputTokensFile)
        while tokenizer.hasMoreTokens() {
            tokenizer.advance()
            switch (tokenizer.tokenType()) {
            case tokType_4.T_INT_CONST:
                tokenizer.intVal()
            case tokType_4.T_IDENTIFIER:
                tokenizer.identifier()
            case tokType_4.T_STRING_CONST:
                tokenizer.stringVal()
            case tokType_4.T_KEYWORD:
                tokenizer.keyWord()
            case tokType_4.T_SYMBOL:
                tokenizer.symbol()
            }
        }
        tokenizer.Close()
    }
    
    func createTreeFile(tokensFile : String, outputTreeFile : String) {
        let compilationEngine =  CompilqtionEngine_4(tokenFilePath: tokensFile, outputFilePath: outputTreeFile)
        compilationEngine.compileClass()
    }
    
}
