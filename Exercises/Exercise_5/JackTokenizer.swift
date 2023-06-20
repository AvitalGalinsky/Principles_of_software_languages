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

struct Token
{
    let type: String
    let value: String
}

class JackTokenizer {
    
    private var recognizedWordsList: [String] = []
    private var tokensList: [Token] = []
    private var methodsList: [String] = [] // list of all the class methods names
    
    private var charIndex = 0 // for automat
    
    private var currentTokenIndex = 0
    private var currentToken = ""
    
    /* Opens the input .jack file and gets ready to tokenize it*/
    init(jackFilePath: String) throws {
        do{
            /* read the origin jack code */
            let jackCode = try String(contentsOfFile: jackFilePath)
            splitCodeToTokens(jackCodeContent: jackCode)
        } catch {
            fatalError("Error reading file: \(error.localizedDescription)")
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
        recognizedWordsList.append(token)
    }
    
    private func Q2(jackCodeContent : String) { //digits
        var token = ""
        var char = jackCodeContent[jackCodeContent.index(jackCodeContent.startIndex, offsetBy: charIndex)]
        while(char.isNumber && charIndex < jackCodeContent.count) {
            token.append(char)
            charIndex += 1
            char = jackCodeContent[jackCodeContent.index(jackCodeContent.startIndex, offsetBy: charIndex)]
        }
        recognizedWordsList.append(token)
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
        recognizedWordsList.append(token)
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
            recognizedWordsList.append("/")
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
                recognizedWordsList.append(String(char))
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
        if currentTokenIndex < recognizedWordsList.count {
            return true
        }
        return false
    }
    
    /* Gets the next token from the input, and makes it the current token.
     This method should be called only if hasMreTokens is true.
     Initially there is no current token.*/
    func advance() {
        currentToken = recognizedWordsList[currentTokenIndex]
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
    
    var isMethod = false //recognize if the keyword is method, if it is, append the next identifier to mthodsList
    /* Returns the keyword which is current token, as a constant.
     This method should be called only if tokenType is KEYWORD.*/
    func keyWord() {
        tokensList.append(Token(type: "keyword", value: currentToken))
        if currentToken == "method" {
            isMethod = true
        }
    }
    
    /* Returns the character which is the current token. should be called only if tokenType is SYMBOL.*/
    func symbol() {
        tokensList.append(Token(type: "symbol", value: currentToken))
    }
    
    /* Returns the string which is the current token. should be called only if tokenType is IDENTIFIER. */
    func identifier() {
        tokensList.append(Token(type: "identifier", value: currentToken))
        if isMethod {
            methodsList.append(currentToken)
            isMethod = false
        }
    }
    
    /* Returns the integer value of the current token. should be called only if tokenType is INT_CONST. */
    func intVal() {
        tokensList.append(Token(type: "integerConstant", value: currentToken))
    }
    
    /* Returns the string value of the current token, without the opening and closing double quotes. should be called only if tokenType is STRING_CONST. */
    func stringVal() {
        currentToken.removeFirst()
        currentToken.removeLast()
        tokensList.append(Token(type: "stringConstant", value: currentToken))
    }
    
    func GetTokensList() -> [Token] {
        return tokensList
    }
    
    func GetMethodsList() -> [String] {
        return methodsList
    }
    
}

