//
//  CompilationEngine.swift
//  Exercises
//
//  Created by avital on 24/05/2023.
//

import Foundation

struct Token_4
{
    let type: String
    let value: String
}

class CompilqtionEngine_4 {
        
    private var outputFileHandle: FileHandle?
    private var tokensList: [Token_4] = []
//    private var treeRoot : XMLElement
//    private var treeDoc : XMLDocument
    private var currentTokenIndex = 0
    private var currentToken : Token_4
    
    
    /* Creates a new compilation engine with the given input and output.
     The next routine called (by the JackAnalyzer module) must be compile class */
    init(tokenFilePath: String, outputFilePath: String) {
        let tokensFileURL = URL(fileURLWithPath: tokenFilePath)
        
        guard let tokensData = try? Data(contentsOf: tokensFileURL) else {
            fatalError("Failed to read tokens file")
        }
        
        guard let tokensDoc = try? XMLDocument(data: tokensData, options: []) else {
            fatalError("Failed to create XML document")
            
        }
        let tokensRoot = tokensDoc.rootElement()!
        for child in tokensRoot.children ?? [] {
            if let childName = child.name, let childValue = child.stringValue?.trimmingCharacters(in: .whitespacesAndNewlines) {
                tokensList.append(Token_4(type: childName, value: childValue))
            }
        }
        
        /* open file to write the tree */
        if FileManager.default.fileExists(atPath: outputFilePath) {
            do {
                try FileManager.default.removeItem(atPath: outputFilePath)
            } catch {
                fatalError("Error removing file: \(outputFilePath)")
            }
        }
        /* create file for output: */
        FileManager.default.createFile(atPath: outputFilePath, contents: nil, attributes: nil)
        outputFileHandle = FileHandle(forWritingAtPath: outputFilePath)
        if (outputFileHandle == nil) {
            fatalError("Error open file: \(outputFilePath) for writing")
        }
        currentToken = Token_4(type: "", value: "")
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
    
    func checkNextToken() ->Token_4 {
        let token = tokensList[tokensList.index(tokensList.startIndex, offsetBy: currentTokenIndex)]
        return token
    }
    
    private func isOp(token : Token_4) -> Bool {
        if (token.type == "symbol" && (token.value == "+" || token.value == "-" || token.value == "*" || token.value == "/" || token.value == "&" || token.value == "|" || token.value == "<" || token.value == ">" || token.value == "=")) {
            return true
        }
        return false
    }
    
    private func isUnaryOp(token : Token_4) -> Bool {
        if (token.type == "symbol" && (token.value == "-" || token.value == "~")) {
            return true
        }
        return false
    }
    
    private func isKeywordConstant(token : Token_4) -> Bool {
        if (token.type == "keyword" && (token.value == "true" || token.value == "false" || token.value == "null" || token.value == "this")) {
            return true
        }
        return false
    }
    
    /* Compiles a complete class */
    func compileClass() {
        let treeRoot = XMLElement(name: "class")
        let treeDoc = XMLDocument(rootElement: treeRoot)
        advance()
        treeRoot.addChild(XMLElement(name: currentToken.type, stringValue: currentToken.value)) // class
        advance()
        treeRoot.addChild(XMLElement(name: currentToken.type, stringValue: currentToken.value)) // className
        advance()
        treeRoot.addChild(XMLElement(name: currentToken.type, stringValue: currentToken.value)) // {
        advance()
        while currentToken.value == "static" || currentToken.value == "field" {
            treeRoot.addChild(compileClassVarDec())
        }
        while currentToken.value == "constructor" || currentToken.value == "function" || currentToken.value == "method" {
            treeRoot.addChild(compileSubroutine())
        }
        treeRoot.addChild(XMLElement(name: currentToken.type, stringValue: currentToken.value)) // }
        outputFileHandle!.write(treeDoc.xmlData(options: XMLNode.Options.nodePrettyPrint))
        if(outputFileHandle != nil) {
            (outputFileHandle!).closeFile()
        }
    }
    
    /* Compiles a static variable declaration or a field declaration */
    func compileClassVarDec() -> XMLElement {
        let root = XMLElement(name: "classVarDec")
        root.addChild(XMLElement(name: currentToken.type, stringValue: currentToken.value)) // static or field
        advance()
        root.addChild(XMLElement(name: currentToken.type, stringValue: currentToken.value)) // type
        advance()
        root.addChild(XMLElement(name: currentToken.type, stringValue: currentToken.value)) // varName
        advance()
        while currentToken.value == "," {
                root.addChild(XMLElement(name: currentToken.type, stringValue: currentToken.value)) // ,
                advance()
                root.addChild(XMLElement(name: currentToken.type, stringValue: currentToken.value)) // varName
                advance()
        }
        root.addChild(XMLElement(name: currentToken.type, stringValue: currentToken.value)) // ;
        advance()
        return root
    }
    
    /* Compiles a complete method, function or constructor */
    func compileSubroutine() -> XMLElement {
        let root = XMLElement(name: "subroutineDec")
        root.addChild(XMLElement(name: currentToken.type, stringValue: currentToken.value)) // constructor or function or method
        advance()
        root.addChild(XMLElement(name: currentToken.type, stringValue: currentToken.value)) // void or type
        advance()
        root.addChild(XMLElement(name: currentToken.type, stringValue: currentToken.value)) // subroutineName
        advance()
        root.addChild(XMLElement(name: currentToken.type, stringValue: currentToken.value)) // (
        advance()
        root.addChild(compileParameterList())
        root.addChild(XMLElement(name: currentToken.type, stringValue: currentToken.value)) // )
        advance()
        root.addChild(compileSubroutineBody())
        return root
    }
    
    /* Compiles a (possibly empty) parameter list. Does not handle the enclosing parentheses tokens ( and ). */
    func compileParameterList() -> XMLElement {
        let root = XMLElement(name: "parameterList")
        while currentToken.value != ")" {
            root.addChild(XMLElement(name: currentToken.type, stringValue: currentToken.value)) // type or varName or ,
            advance()
        }
        return root
    }
    
    /* Compiles a subroutine's body. */
    func compileSubroutineBody() -> XMLElement {
        let root = XMLElement(name: "subroutineBody")
        root.addChild(XMLElement(name: currentToken.type, stringValue: currentToken.value)) // {
        advance()
        while currentToken.value == "var" {
            root.addChild(compileVarDec())
        }
        root.addChild(compileStatements())
        root.addChild(XMLElement(name: currentToken.type, stringValue: currentToken.value)) // }
        advance()
        return root
    }
    
    /* Compiles a var declaration. */
    func compileVarDec() -> XMLElement{
        let root = XMLElement(name: "varDec")
        while currentToken.value != ";" {
            root.addChild(XMLElement(name: currentToken.type, stringValue: currentToken.value)) // var or varName or ,
            advance()
        }
        root.addChild(XMLElement(name: currentToken.type, stringValue: currentToken.value)) // ;
        advance()
        return root
    }
    
    /* Compiles a sequence of statements. Does not handle the enclosing curly bracket tokens { and }. */
    func compileStatements() -> XMLElement{
        let root = XMLElement(name: "statements")
        while currentToken.value == "let" || currentToken.value == "if" || currentToken.value == "while" || currentToken.value == "do" || currentToken.value == "return" {
            if currentToken.value == "let" {
                root.addChild(compileLet())
            }
            else if currentToken.value == "if" {
                root.addChild(compileIf())
            }
            else if currentToken.value == "while" {
                root.addChild(compileWhile())
            }
            else if currentToken.value == "do" {
                root.addChild(compileDo())
            }
            else if currentToken.value == "return" {
                root.addChild(compileReturn())
            }
        }
        return root
    }
    
    /* Compiles a let statment. */
    func compileLet()  -> XMLElement {
        let root = XMLElement(name: "letStatement")
        root.addChild(XMLElement(name: currentToken.type, stringValue: currentToken.value)) // let
        advance()
        root.addChild(XMLElement(name: currentToken.type, stringValue: currentToken.value)) // varName
        advance()
        if currentToken.value == "[" {
            root.addChild(XMLElement(name: currentToken.type, stringValue: currentToken.value)) // [
            advance()
            root.addChild(compileExpression())
            root.addChild(XMLElement(name: currentToken.type, stringValue: currentToken.value)) // ]
            advance()
        }
        root.addChild(XMLElement(name: currentToken.type, stringValue: currentToken.value)) // =
        advance()
        root.addChild(compileExpression())
        root.addChild(XMLElement(name: currentToken.type, stringValue: currentToken.value)) // ;
        advance()
        return root
    }
    
    /* Compiles an if statements, possibly with a trailing else clause. */
    func compileIf()  -> XMLElement {
        let root = XMLElement(name: "ifStatement")
        root.addChild(XMLElement(name: currentToken.type, stringValue: currentToken.value)) // if
        advance()
        root.addChild(XMLElement(name: currentToken.type, stringValue: currentToken.value)) // (
        advance()
        root.addChild(compileExpression())
        root.addChild(XMLElement(name: currentToken.type, stringValue: currentToken.value)) // )
        advance()
        root.addChild(XMLElement(name: currentToken.type, stringValue: currentToken.value)) // {
        advance()
        root.addChild(compileStatements())
        root.addChild(XMLElement(name: currentToken.type, stringValue: currentToken.value)) // }
        advance()
        if currentToken.value == "else" {
            root.addChild(XMLElement(name: currentToken.type, stringValue: currentToken.value)) // else
            advance()
            root.addChild(XMLElement(name: currentToken.type, stringValue: currentToken.value)) // {
            advance()
            root.addChild(compileStatements())
            root.addChild(XMLElement(name: currentToken.type, stringValue: currentToken.value)) // }
            advance()
        }
        return root
    }
    
    /* Compiles a while statment. */
    func compileWhile()  -> XMLElement {
        let root = XMLElement(name: "whileStatement")
        root.addChild(XMLElement(name: currentToken.type, stringValue: currentToken.value)) // while
        advance()
        root.addChild(XMLElement(name: currentToken.type, stringValue: currentToken.value)) // (
        advance()
        root.addChild(compileExpression())
        root.addChild(XMLElement(name: currentToken.type, stringValue: currentToken.value)) // )
        advance()
        root.addChild(XMLElement(name: currentToken.type, stringValue: currentToken.value)) // {
        advance()
        root.addChild(compileStatements())
        root.addChild(XMLElement(name: currentToken.type, stringValue: currentToken.value)) // }
        advance()
        return root
    }
    
    /* Compiles a do statments. */
    func compileDo()  -> XMLElement {
        var root = XMLElement(name: "doStatement")
        root.addChild(XMLElement(name: currentToken.type, stringValue: currentToken.value)) // do
        advance()
        subroutineCall(root : &root)
        root.addChild(XMLElement(name: currentToken.type, stringValue: currentToken.value)) // ;
        advance()
        return root
    }
    
    private func subroutineCall(root : inout XMLElement) {
        root.addChild(XMLElement(name: currentToken.type, stringValue: currentToken.value)) // subroutineName or className or varName
        advance()
        if (currentToken.value == ".") {
            root.addChild(XMLElement(name: currentToken.type, stringValue: currentToken.value)) // .
            advance()
            root.addChild(XMLElement(name: currentToken.type, stringValue: currentToken.value)) // subroutineName
            advance()
        }
        root.addChild(XMLElement(name: currentToken.type, stringValue: currentToken.value)) // (
        advance()
        root.addChild(compileExpressionList())
        root.addChild(XMLElement(name: currentToken.type, stringValue: currentToken.value)) // )
        advance()
    }
    
    /* Compiles a return statments. */
    func compileReturn()  -> XMLElement {
        let root = XMLElement(name: "returnStatement")
        root.addChild(XMLElement(name: currentToken.type, stringValue: currentToken.value)) // return
        advance()
        if currentToken.value != ";" {
            root.addChild(compileExpression())
        }
        root.addChild(XMLElement(name: currentToken.type, stringValue: currentToken.value)) // ;
        advance()
        return root
    }
    
    /* Compiles an expression. */
    func compileExpression()  -> XMLElement {
        let root = XMLElement(name: "expression")
        root.addChild(compileTerm())
        while(isOp(token: currentToken)) {
            root.addChild(XMLElement(name: currentToken.type, stringValue: currentToken.value)) // op
            advance()
            root.addChild(compileTerm())
        }
        return root
    }
    
    /* Compiles a term. If the current token is an identifier, the routine must resolve it into a variable' an array entry' or a subroutine call. A single lookahead token' which may be [' (, or ., suffices to distinguish between the possibilities. Any other token is not part of this term and should not be advanced over. */
    func compileTerm()  -> XMLElement {
        var root = XMLElement(name: "term")
        if(currentToken.type == "identifier" && (checkNextToken().value == "(" || checkNextToken().value == ".")){
            subroutineCall(root: &root)
        }
        else if currentToken.value == "(" {
            root.addChild(XMLElement(name: currentToken.type, stringValue: currentToken.value)) // (
            advance()
            root.addChild(compileExpression())
            root.addChild(XMLElement(name: currentToken.type, stringValue: currentToken.value)) // )
            advance()
        }
        else if isUnaryOp(token: currentToken) {
            root.addChild(XMLElement(name: currentToken.type, stringValue: currentToken.value)) // unaryOp
            advance()
            root.addChild(compileTerm())
        }
        else {
            root.addChild(XMLElement(name: currentToken.type, stringValue: currentToken.value)) // integerConstant or stringConstant or keywordConstant or varName
            advance()
            if currentToken.value == "[" {
                root.addChild(XMLElement(name: currentToken.type, stringValue: currentToken.value)) // [
                advance()
                root.addChild(compileExpression())
                root.addChild(XMLElement(name: currentToken.type, stringValue: currentToken.value)) // ]
                advance()
            }
        }
        return root
    }
    
    /* Compiles a (possibly empty) comma-separated list of expressions. Returns the number of expressions in the list. */
    // ????????????????????????????????????
    func compileExpressionList() -> XMLElement {
        let root = XMLElement(name: "expressionList")
        while currentToken.value != ")" {
            root.addChild(compileExpression())
            if currentToken.value == "," {
                root.addChild(XMLElement(name: currentToken.type, stringValue: currentToken.value)) // ,
                advance()
            }
        }
        return root
    }
}
