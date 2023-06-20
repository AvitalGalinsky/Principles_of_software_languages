//
//  CompilationEngine.swift
//  Exercises
//
//  Created by avital on 16/06/2023.
//

import Foundation


class CompilationEngine {
        
    private var outputFileHandle: FileHandle?
    private var tokensList: [Token] = []
    private var currentTokenIndex = 0
    private var currentToken : Token
    private var classTable : SymbolTable
    private var subroutineTable : SymbolTable
    private var methodsList: [String] = []
    private var vmWriter : VMWriter
    private var className : String
    private var ifIndex = 0
    private var whileIndex = 0
    
    
    /* Creates a new compilation engine with the given input and output.
     The next routine called (by the JackAnalyzer module) must be compile class */
    init(tokensList_: [Token], methodsList_ : [String], outputFilePath: String) {
        
        tokensList = tokensList_
        methodsList = methodsList_
        vmWriter = VMWriter(outputFilePath: outputFilePath)
        classTable = SymbolTable()
        subroutineTable = SymbolTable()
        className = ""
        currentToken = Token(type: "", value: "")
        
    }
    
    /* Are there more tokens in the input? */
    func hasMoreTokens() -> Bool {
        if currentTokenIndex < tokensList.count {
            return true
        }
        return false
    }
    
    func advance() {
        currentToken = tokensList[tokensList.index(tokensList.startIndex, offsetBy: currentTokenIndex)]
        currentTokenIndex += 1
    }
    
    func checkNextToken() ->Token {
        let token = tokensList[tokensList.index(tokensList.startIndex, offsetBy: currentTokenIndex)]
        return token
    }
    
    private func isOp(token : Token) -> Bool {
        if (token.type == "symbol" && (token.value == "+" || token.value == "-" || token.value == "*" || token.value == "/" || token.value == "&" || token.value == "|" || token.value == "<" || token.value == ">" || token.value == "=")) {
            return true
        }
        return false
    }
    
    private func isUnaryOp(token : Token) -> Bool {
        if (token.type == "symbol" && (token.value == "-" || token.value == "~")) {
            return true
        }
        return false
    }
    
    private func isKeywordConstant(token : Token) -> Bool {
        if (token.type == "keyword" && (token.value == "true" || token.value == "false" || token.value == "null" || token.value == "this")) {
            return true
        }
        return false
    }
    
    private func varKindToSegmentType(kind : varKind) -> segmentType {
        if kind == varKind.STATIC {
            return segmentType.STATIC
        }
        if kind == varKind.FIELD {
            return segmentType.THIS
        }
        if kind == varKind.ARG {
            return segmentType.ARGUMENT
        }
        return segmentType.LOCAL
    }
    
    private func varNameToIndex(name : String) -> Int {
        let index = subroutineTable.indexOf(name: name)
        if index != -1 {
            return index
        }
        return classTable.indexOf(name: name)
    }
    
    private func getKind(varName : String) -> varKind {
        var kind = subroutineTable.kindOf(name: varName)
        if kind != varKind.NONE {
            return kind
        }
        kind = classTable.kindOf(name: varName)
        return kind
    }
    
    private func getType(varName : String) -> String {
        var type = subroutineTable.typeOf(name: varName)
        if type != "" {
            return type
        }
        type = classTable.typeOf(name: varName)
        return type
    }
    
    /* Compiles a complete class */
    func compileClass() {
        classTable.reset()
        advance()// to class
        advance()// to className
        className = currentToken.value
        advance()// to {
        advance()
        while currentToken.value == "static" || currentToken.value == "field" {
            compileClassVarDec()
        }
        while currentToken.value == "constructor" || currentToken.value == "function" || currentToken.value == "method" {
            compileSubroutine()
        }

        if(outputFileHandle != nil) {
            (outputFileHandle!).closeFile()
        }
    }
    
    /* Compiles a static variable declaration or a field declaration */
    func compileClassVarDec() {
        // name: String, type: String, kind: varType
        var kind : varKind
        if(currentToken.value == "static") {
            kind = varKind.STATIC
        }
        else { //field
            kind = varKind.FIELD
        }
        advance() // to type
        let type = currentToken.value
        advance() // to varName
        if currentToken.value == "<" {// for arrays
            advance() //skip <
            advance() // skip type TO_DO: save in symbol table?
            advance() // skip >
        }
        classTable.define(name: currentToken.value, type: type, kind: kind)
        advance()
        while currentToken.value == "," {
                advance()// skip ,
                classTable.define(name: currentToken.value, type: type, kind: kind) // varName
                advance()
        }
        advance()// skip ;
    }
    
    /* Compiles a complete method, function or constructor */
    func compileSubroutine() {
        subroutineTable.reset()
        if currentToken.value == "method" {
            subroutineTable.define(name: "this", type: className, kind: varKind.ARG)
        }
        let funcType = currentToken.value // constructor or function or method
        advance()
        let returnType = currentToken.value // void or type
        advance()
        let funcName = "\(className).\(currentToken.value)" // subroutineName
        advance()
        advance() // skip (
        compileParameterList()
        advance() // skip )
        compileSubroutineBody(funcType: funcType, returnType: returnType, funcName: funcName)
    }
    
    /* Compiles a (possibly empty) parameter list. Does not handle the enclosing parentheses tokens ( and ). */
    func compileParameterList() {
        let kind = varKind.ARG
        while currentToken.value != ")" {
            let type = currentToken.value
            advance() // to varName
            subroutineTable.define(name: currentToken.value, type: type, kind: kind)//varName
            advance()
            if currentToken.value == "," {
                advance() // skip ,
            }
        }
    }
    
    /* Compiles a subroutine's body. */
    func compileSubroutineBody(funcType: String, returnType: String, funcName: String) {
        advance() // skip {
        while currentToken.value == "var" {
            compileVarDec()
        }
        vmWriter.writeFunction(name: funcName, nVars: subroutineTable.varCount(kind: varKind.VAR))
        if funcType == "constructor" {
            vmWriter.writePush(segment: segmentType.CONSTANT, index: classTable.varCount(kind: varKind.FIELD))
            vmWriter.writeCall(name: "Memory.alloc", nArgs: 1)
            vmWriter.writePop(segment: segmentType.POINTER, index: 0)
        }
        else if funcType == "method" {
            vmWriter.writePush(segment: segmentType.ARGUMENT, index: 0)
            vmWriter.writePop(segment: segmentType.POINTER, index: 0)
        }
        compileStatements()
        advance() // skip }
    }
    
    /* Compiles a var declaration. */
    func compileVarDec() {
        advance() //skip var
        let kind = varKind.VAR
        let type = currentToken.value
        advance()// to varName
        while currentToken.value != ";" {
            if currentToken.value == "<" {// for arrays
                advance() //skip <
                advance() // skip type TO_DO: save in symbol table?
                advance() // skip >
            }
            subroutineTable.define(name: currentToken.value, type: type, kind: kind)
            advance()
            if currentToken.value == ","{
                advance()
            }
        }
        advance()// skip ;
    }
    
    /* Compiles a sequence of statements. Does not handle the enclosing curly bracket tokens { and }. */
    func compileStatements() {
        while currentToken.value == "let" || currentToken.value == "if" || currentToken.value == "while" || currentToken.value == "do" || currentToken.value == "return" {
            if currentToken.value == "let" {
                compileLet()
            }
            else if currentToken.value == "if" {
                compileIf()
            }
            else if currentToken.value == "while" {
                compileWhile()
            }
            else if currentToken.value == "do" {
                compileDo()
            }
            else if currentToken.value == "return" {
                compileReturn()
            }
        }
    }
    
    /* Compiles a let statment. */
    func compileLet() { // TODO: handle array
        var isArray = false
        advance() // skip let
        let varName = currentToken.value
        advance() // skip varName
        if currentToken.value == "[" { //if var is array - calculate address
            isArray = true
            let kind = getKind(varName: varName)
            vmWriter.writePush(segment: varKindToSegmentType(kind: kind), index: varNameToIndex(name: varName))
            advance() // skip [
            compileExpression()
            advance()// skip ]
            vmWriter.writeArithmetic(command: commandType.ADD)
        }
        advance() // skip =
        compileExpression()
        if isArray {
            vmWriter.writePop(segment: segmentType.TEMP, index: 0)
            vmWriter.writePop(segment: segmentType.POINTER, index: 1)
            vmWriter.writePush(segment: segmentType.TEMP, index: 0)
            vmWriter.writePop(segment: segmentType.THAT, index: 0)
        }
        else {
            let kind = getKind(varName: varName)
            if kind != varKind.NONE {
                vmWriter.writePop(segment: varKindToSegmentType(kind: kind), index: varNameToIndex(name: varName))
            }
        }
        advance()// skip ;
    }
    
    /* Compiles an if statements, possibly with a trailing else clause. */
    func compileIf() {
        let currentIfIndex = ifIndex
        ifIndex += 1
        advance() // skip if
        advance() // skip (
        compileExpression()
        advance() // skip )
        advance() // skip {
        vmWriter.writeArithmetic(command: commandType.NOT)
        vmWriter.writeIf(label: "IF_FALSE\(currentIfIndex)")
        compileStatements()
        vmWriter.writeGoto(label: "IF_TRUE\(currentIfIndex)")
        advance() //skip }
        vmWriter.writeLabel(label: "IF_FALSE\(currentIfIndex)")
        if currentToken.value == "else" {
            advance()// skip else
            advance() // skip {
            compileStatements()
            advance() // skip }
        }
        vmWriter.writeLabel(label: "IF_TRUE\(currentIfIndex)")
    }
    
    /* Compiles a while statment. */
    func compileWhile() {
        let currentWhileIndex = whileIndex
        whileIndex += 1
        advance() // skip while
        advance() // skip (
        vmWriter.writeLabel(label: "WHILE_TRUE\(currentWhileIndex)")
        compileExpression()
        advance() // skip )
        advance() // skip {
        vmWriter.writeArithmetic(command: commandType.NOT)
        vmWriter.writeIf(label: "WHILE_FALSE\(currentWhileIndex)")
        compileStatements()
        vmWriter.writeGoto(label: "WHILE_TRUE\(currentWhileIndex)")
        vmWriter.writeLabel(label: "WHILE_FALSE\(currentWhileIndex)")
        advance()// skip }
    }
    
    /* Compiles a do statments. */
    func compileDo() {
        advance() //skip do
        compileExpression()
        advance() //skip ;
        vmWriter.writePop(segment: segmentType.TEMP, index: 0)
    }
    
    private func subroutineCall() {
        var funcName = currentToken.value // subroutineName or className or varName
        var nArgs = 0
        advance()
         var kind = varKind.NONE
        if (currentToken.value == ".") {
            kind = getKind(varName: funcName)
            if kind != varKind.NONE {
                nArgs += 1
                let newFuncName = getType(varName: funcName)
                vmWriter.writePush(segment: varKindToSegmentType(kind: kind), index: varNameToIndex(name: funcName))
                funcName = newFuncName
            }
            funcName.append(".")
            advance() // skip .
            funcName.append(currentToken.value) // subroutineName
            advance()
        }
        else {
            if let _ = methodsList.firstIndex(of: funcName) { // method of the class
                nArgs += 1
                vmWriter.writePush(segment: segmentType.POINTER, index: 0)
            }
            funcName = "\(className).\(funcName)"
        }
        advance() // skip (
        nArgs += compileExpressionList()
        advance() // skip )
        vmWriter.writeCall(name: funcName, nArgs: nArgs)
    }
    
    /* Compiles a return statments. */
    func compileReturn() {
        advance()// skip return
        if currentToken.value == ";"{
            vmWriter.writePush(segment: segmentType.CONSTANT, index: 0)
        }
        else {
            compileExpression()
        }

        advance()// skip ;
        vmWriter.writeReturn()
    }
    
    /* Compiles an expression. */
    func compileExpression() {
        compileTerm()
        while(isOp(token: currentToken)) {
            let op = currentToken.value
            advance() //skip op
            compileTerm()
            if op == "+" {
                vmWriter.writeArithmetic(command: commandType.ADD)
            }
            else if op == "-" {
                vmWriter.writeArithmetic(command: commandType.SUB)
            }
            else if op == "*" {
                vmWriter.writeCall(name: "Math.multiply", nArgs: 2)
            }
            else if op == "/" {
                vmWriter.writeCall(name: "Math.divide", nArgs: 2)
            }
            else if op == "&" {
                vmWriter.writeArithmetic(command: commandType.AND)
            }
            else if op == "|" {
                vmWriter.writeArithmetic(command: commandType.OR)
            }
            else if op == "=" {
                vmWriter.writeArithmetic(command: commandType.EQ)
            }
            else if op == ">" {
                vmWriter.writeArithmetic(command: commandType.GT)
            }
            else if op == "<" {
                vmWriter.writeArithmetic(command: commandType.LT)
            }
        }
    }
    
    /* Compiles a term. If the current token is an identifier, the routine must resolve it into a variable' an array entry' or a subroutine call. A single lookahead token' which may be [' (, or ., suffices to distinguish between the possibilities. Any other token is not part of this term and should not be advanced over. */
    func compileTerm() {
        if(currentToken.type == "identifier" && (checkNextToken().value == "(" || checkNextToken().value == ".")){
            subroutineCall()
        }
        else if currentToken.value == "(" {
            advance() // skip (
            compileExpression()
            advance() // skip )
        }
        else if isUnaryOp(token: currentToken) {
            let unaryOp = currentToken.value
            advance()
            compileTerm()
            if unaryOp == "-" {
                vmWriter.writeArithmetic(command: commandType.NEG)
            }
            else if unaryOp == "~" {
                vmWriter.writeArithmetic(command: commandType.NOT)
            }
        }
        else {
            if currentToken.type == "integerConstant" {
                vmWriter.writePush(segment: segmentType.CONSTANT, index: Int(currentToken.value)!)
            }
            else if currentToken.type == "identifier" { //varName
                let kind = getKind(varName: currentToken.value)
                vmWriter.writePush(segment: varKindToSegmentType(kind: kind), index: varNameToIndex(name: currentToken.value))
            }
            else if currentToken.type == "keyword" {
                if currentToken.value == "true" {
                    vmWriter.writePush(segment: segmentType.CONSTANT, index: 1)
                    vmWriter.writeArithmetic(command: commandType.NEG)
                }
                else if currentToken.value == "false"  || currentToken.value == "null" {
                    vmWriter.writePush(segment: segmentType.CONSTANT, index: 0)
                }
                else if currentToken.value == "this" {
                    vmWriter.writePush(segment:segmentType.POINTER, index: 0)
                }
            }
            else if currentToken.type == "stringConstant" {
                vmWriter.writePush(segment: segmentType.CONSTANT, index: (currentToken.value).count)
                vmWriter.writeCall(name: "String.new", nArgs: 1)
                for c in currentToken.value {
                    let asciiValue = Int(c.asciiValue!)
                    vmWriter.writePush(segment: segmentType.CONSTANT, index: asciiValue)
                    vmWriter.writeCall(name: "String.appendChar", nArgs: 2)
                }
            }
            advance()
            if currentToken.value == "[" {
                advance() // skip [
                compileExpression()
                vmWriter.writeArithmetic(command: commandType.ADD)
                vmWriter.writePop(segment: segmentType.POINTER, index: 1)
                vmWriter.writePush(segment: segmentType.THAT, index: 0)
                advance() // skip ]
            }
        }
    }
    
    /* Compiles a (possibly empty) comma-separated list of expressions. Returns the number of expressions in the list. */

    func compileExpressionList() -> Int {
        var expressionsNum = 0
        while currentToken.value != ")" {
            compileExpression()
            expressionsNum += 1
            if currentToken.value == "," {
                advance() // skip ,
            }
        }
        return expressionsNum
    }
    
    func Close() {
        if(outputFileHandle != nil) {
            (outputFileHandle!).closeFile()
        }
    }
}
