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

class JackAnalyzer {
    
    private var tokensList: [Token] = []
    private var methodsList: [String] = []
    
    init() {
        
    }
    
    func createTokenList(jackFile : String) throws {
        let tokenizer =  try JackTokenizer(jackFilePath: jackFile)
        while tokenizer.hasMoreTokens() {
            tokenizer.advance()
            switch (tokenizer.tokenType()) {
            case tokType.T_INT_CONST:
                tokenizer.intVal()
            case tokType.T_IDENTIFIER:
                tokenizer.identifier()
            case tokType.T_STRING_CONST:
                tokenizer.stringVal()
            case tokType.T_KEYWORD:
                tokenizer.keyWord()
            case tokType.T_SYMBOL:
                tokenizer.symbol()
            }
        }
        tokensList = tokenizer.GetTokensList()
        methodsList = tokenizer.GetMethodsList()
    }
    
    func createVMFile(outputVMFile : String) {
        let compilationEngine = CompilationEngine(tokensList_: tokensList, methodsList_: methodsList, outputFilePath: outputVMFile)
        compilationEngine.compileClass()
        compilationEngine.Close()
    }
    
}
