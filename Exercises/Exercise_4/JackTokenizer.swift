//
//  JackTokenizer.swift
//  Exercises
//
//  Created by avital on 24/05/2023.
//

import Foundation

enum tokType {
    case T_NONE
    case T_KEYWORD
    case T_SYMBOL
    case T_IDENTIFIER
    case T_INT_CONST
    case T_STRING_CONST
}

enum kWord {
    case K_NONE
    case K_CLASS
    case K_METHOD
    case K_FUNCTION
    case K_CONSTRUCTOR
    case K_INT
    case K_BOOLEAN
    case K_CHAR
    case K_VOID
    case K_VAR
    case K_STATIC
    case K_FIELD
    case K_LET
    case K_DO
    case K_IF
    case K_ELSE
    case K_WHILE
    case K_RETURN
    case K_TRUE
    case K_FALSE
    case K_NULL
    case K_THIS
}

class JackTokenizer {

    /* Opens the input .jack file and gets ready to tokenize it*/
    init(jackFilePath: String) {
        
    }
    
    /* Are there more tokens in the input? */
    func hasMoreTokens() -> Bool {
        return true;
    }
    
    /* Gets the next token from the input, and makes it the current token.
     This method should be called only if hasMreTokens is true.
     Initially there is no current token.*/
    func advance() {
        
    }
    
    /* Returns the type of the current token, as a constant.*/
    func tokenType() -> tokType {
        return tokType.T_NONE
    }
    
    /* Returns the keyword which is current token, as a constant.
     This method should be called only if tokenType is KEYWORD.*/
    func keyWord() -> kWord {
        return kWord.K_NONE
    }
    
    /* Returns the character which is the current token. should be called only if tokenType is SYMBOL.*/
    func symbol() -> Character {
        return "a"
    }
    
    /* Returns the string which is the current token. should be called only if tokenType is IDENTIFIER. */
    func identifier() -> String {
        return ""
    }
    
    /* Returns the integer value of the current token. should be called only if tokenType is INT_CONST. */
    func intVal() -> Int {
        return 0
    }
    
    /* Returns the string value of the current token, without the opening and closing double quotes. should be called only if tokenType is STRING_CONST. */
    func stringVal() -> String {
        return ""
    }
    
}
