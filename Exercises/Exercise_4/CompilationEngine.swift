//
//  CompilationEngine.swift
//  Exercises
//
//  Created by avital on 24/05/2023.
//

import Foundation

class CompilqtionEngine {
    
    /* Creates a new compilation engine with the given input and output.
     The next routine called (by the JackAnalyzer module) must be compile class */
    init(tokenFilePath: String, outputFilePath: String) {
    }
    
    /* Compiles a complete class */
    func compileClass() {
        
    }
    
    /* Compiles a static variable declaration or a field declaration */
    func compileClassVarDec() {
        
    }
    
    /* Compiles a complete method, function or constructor */
    func compileSubroutine() {
        
    }
    
    /* Compiles a (possibly empty) parameter list. Does not handle the enclosing parentheses tokens ( and ). */
    func compileParameterList() {
        
    }
    
    /* Compiles a subroutine's body. */
    func compileSubroutineBody() {
        
    }
    
    /* Compiles a var declaration. */
    func compileVarDec() {
        
    }
    
    /* Compiles a sequence of statements. Does not handle the enclosing curly bracket tokens { and }. */
    func compileStatements() {
        
    }
    
    /* Compiles a let statment. */
    func compileLet() {
        
    }
    
    /* Compiles an if statements, possibly with a trailing else clause. */
    func compileIf() {
        
    }
    
    /* Compiles a while statment. */
    func compileWhile() {
        
    }
    
    /* Compiles a do statments. */
    func compileDo() {
        
    }
    /* Compiles a return statments. */
    func compileReturn() {
        
    }
    
    /* Compiles an expression. */
    func compileExpression() {
        
    }
    
    /* Compiles a term. If the current token is an identifier, the routine must resolve it into a variable' an array entry' or a subroutine call. A single lookahead token' which may be [' (, or ., suffices to distinguish between the possibilities. Any other token is not part of this term and should not be advanced over. */
    func compileTerm() {
        
    }
    
    /* Compiles a (possibly empty) comma-separated list of expressions. Returns the number of expressions in the list. */
    func compileExpressionList() -> Int {
        return 0
    }
}
