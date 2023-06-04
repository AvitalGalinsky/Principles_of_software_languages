//
//  JackTokenizer.swift
//  Exercises
//
//  Created by avital on 24/05/2023.
//

import Foundation

enum tokType {
    case T_KEYWORD
    case T_SYMBOL
    case T_IDENTIFIER
    case T_INT_CONST
    case T_STRING_CONST
}

class JackTokenizer {
    
    private var outputFileHandle: FileHandle?
    private var tokensList: [String] = []
    private var charIndex = 0 // for automat
    
    private var currentTokenIndex = 0
    private var currentToken = ""
    private let root : XMLElement
    private let xml : XMLDocument
    
    /* Opens the input .jack file and gets ready to tokenize it*/
    init(jackFilePath: String, outputTokensFile : String) throws {
        root = XMLElement(name: "tokens")
        xml = XMLDocument(rootElement: root)
        do{
            /* read the origin jack code */
            let jackCode = try String(contentsOfFile: jackFilePath)
            splitCodeToTokens(jackCodeContent: jackCode)
        } catch {
            fatalError("Error reading file: \(error.localizedDescription)")
        }
        
        /* open file to write the tokens */
        if FileManager.default.fileExists(atPath: outputTokensFile) {
            do {
                try FileManager.default.removeItem(atPath: outputTokensFile)
            } catch {
                fatalError("Error removing file: \(error.localizedDescription)")
            }
        }
        /* create file for output: */
        FileManager.default.createFile(atPath: outputTokensFile, contents: nil, attributes: nil)
        outputFileHandle = FileHandle(forWritingAtPath: outputTokensFile)
        if (outputFileHandle == nil) {
            fatalError("Error open file: \(outputTokensFile) for writing")
        }
    }
    
    private func Q1(jackCodeContent : String) { //letters
        var token = ""
        var char = jackCodeContent[jackCodeContent.index(jackCodeContent.startIndex, offsetBy: charIndex)]
        while((char.isLetter || char == "_" || char.isNumber) && charIndex < jackCodeContent.count) {
            token.append(char)
            charIndex += 1
            char = jackCodeContent[jackCodeContent.index(jackCodeContent.startIndex, offsetBy: charIndex)]
        }
        tokensList.append(token)
    }
    
    private func Q2(jackCodeContent : String) { //digits
        var token = ""
        var char = jackCodeContent[jackCodeContent.index(jackCodeContent.startIndex, offsetBy: charIndex)]
        while(char.isNumber && charIndex < jackCodeContent.count) {
            token.append(char)
            charIndex += 1
            char = jackCodeContent[jackCodeContent.index(jackCodeContent.startIndex, offsetBy: charIndex)]
        }
        tokensList.append(token)
    }
    
    private func Q3(jackCodeContent : String) { //string
        var token = "\""
        charIndex += 1
        var char = jackCodeContent[jackCodeContent.index(jackCodeContent.startIndex, offsetBy: charIndex)]
        while(char != "\"" && charIndex < jackCodeContent.count) {
            token.append(char)
            charIndex += 1
            char = jackCodeContent[jackCodeContent.index(jackCodeContent.startIndex, offsetBy: charIndex)]
        }
        token.append(char)
        charIndex += 1
        tokensList.append(token)
    }
    
    private func Q4(jackCodeContent : String) { //comments
        charIndex += 1
        var char = jackCodeContent[jackCodeContent.index(jackCodeContent.startIndex, offsetBy: charIndex)]
        if char == "/" {
            while char != "\n" && char != "\r\n" && charIndex < jackCodeContent.count {
                charIndex += 1
                char = jackCodeContent[jackCodeContent.index(jackCodeContent.startIndex, offsetBy: charIndex)]
            }
        }
        else if char == "*" {
            charIndex += 1
            var charNextIndex = charIndex + 1
            var char = jackCodeContent[jackCodeContent.index(jackCodeContent.startIndex, offsetBy: charIndex)]
            var char2 = jackCodeContent[jackCodeContent.index(jackCodeContent.startIndex, offsetBy: charNextIndex)]
            while !(char == "*" && char2 == "/") && charNextIndex < jackCodeContent.count {
                charIndex += 1
                charNextIndex += 1
                char = jackCodeContent[jackCodeContent.index(jackCodeContent.startIndex, offsetBy: charIndex)]
                char2 = jackCodeContent[jackCodeContent.index(jackCodeContent.startIndex, offsetBy: charNextIndex)]

            }
            charIndex = charNextIndex + 1
        }
        else {
            tokensList.append("/")
        }
        
    }
    
    private func isSymbol(token : String) -> Bool {
        if(token == "{" || token == "}" || token == "(" || token == ")" || token == "[" || token == "]"
           || token == "." || token == "," || token == ";" || token == "+" || token == "-" || token == "*"
           || token == "/" || token == "&" || token == "|" || token == "<" || token == ">" || token == "="
           || token == "~"){
            return true
        }
        return false
    }
    
    private func isKeyword(token : String) -> Bool {
        if(token == "class" || token == "constructor" || token == "function" || token == "method" || token == "field" || token == "static"
           || token == "var" || token == "int" || token == "char" || token == "boolean" || token == "void" || token == "true"
           || token == "false" || token == "null" || token == "this" || token == "let" || token == "do" || token == "if"
           || token == "else" || token == "while" || token == "return"){
            return true
        }
        return false
    }
    
    private func splitCodeToTokens(jackCodeContent : String) {
        while charIndex < jackCodeContent.count {
            let char = jackCodeContent[jackCodeContent.index(jackCodeContent.startIndex, offsetBy: charIndex)]
            
            if(char == "/") {
                Q4(jackCodeContent : jackCodeContent) //comments
            }
            else if (char.isLetter || char == "_") {
                Q1(jackCodeContent : jackCodeContent) //letters
            }
            else if(char.isNumber) {
                Q2(jackCodeContent : jackCodeContent) //digits
            }
            else if(isSymbol(token : String(char))){
                tokensList.append(String(char))
                charIndex += 1
            }
            else if(char == "\"") {
                Q3(jackCodeContent : jackCodeContent) //string
            }
            
            else if(char == " " || char == "\n" || char == "\t" || char == "\r" || char == "\r\n"){
                charIndex += 1
            }
            
            else {
                fatalError("Unrecognized charecter: \(char)")
            }
        }
    }
    
    /* Are there more tokens in the input? */
    func hasMoreTokens() -> Bool {
        if currentTokenIndex < tokensList.count {
            return true
        }
        return false
    }
    
    /* Gets the next token from the input, and makes it the current token.
     This method should be called only if hasMreTokens is true.
     Initially there is no current token.*/
    func advance() {
        currentToken = tokensList[currentTokenIndex]
        currentTokenIndex += 1
    }
    
    /* Returns the type of the current token, as a constant.*/
    func tokenType() -> tokType {
        if isSymbol(token: currentToken) {
            return tokType.T_SYMBOL
        }
        if isKeyword(token: currentToken) {
            return tokType.T_KEYWORD
        }
        if currentToken.first! == "\"" {
            return tokType.T_STRING_CONST
        }
        if Int(currentToken) != nil {
            return tokType.T_INT_CONST
        }
        return tokType.T_IDENTIFIER
    }
    
    /* Returns the keyword which is current token, as a constant.
     This method should be called only if tokenType is KEYWORD.*/
    func keyWord() {
        root.addChild(XMLElement(name: "keyword", stringValue: currentToken))
    }
    
    /* Returns the character which is the current token. should be called only if tokenType is SYMBOL.*/
    func symbol() {
        root.addChild(XMLElement(name: "symbol", stringValue: currentToken))
    }
    
    /* Returns the string which is the current token. should be called only if tokenType is IDENTIFIER. */
    func identifier() {
        root.addChild(XMLElement(name: "identifier", stringValue: currentToken))
    }
    
    /* Returns the integer value of the current token. should be called only if tokenType is INT_CONST. */
    func intVal() {
        root.addChild(XMLElement(name: "integerConstant", stringValue: currentToken))
    }
    
    /* Returns the string value of the current token, without the opening and closing double quotes. should be called only if tokenType is STRING_CONST. */
    func stringVal() {
        currentToken.removeFirst()
        currentToken.removeLast()
        root.addChild(XMLElement(name: "stringConstant", stringValue: currentToken))
    }
    
    func Close() {
        outputFileHandle!.write(xml.xmlData(options: XMLNode.Options.nodePrettyPrint))
        if(outputFileHandle != nil) {
            (outputFileHandle!).closeFile()
        }
    }
    
}

