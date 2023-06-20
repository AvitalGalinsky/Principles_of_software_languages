//
//  SymbolTable.swift
//  Exercises
//
//  Created by avital on 16/06/2023.
//

import Foundation

enum varKind {
    case STATIC
    case FIELD
    case ARG
    case VAR
    case NONE
    
    var description: String {
        switch self {
        case .STATIC:
            return "static"
        case .FIELD:
            return "field"
        case .ARG:
            return "arg"
        case .VAR:
            return "var"
        case .NONE:
            return "none"
        }
        }
}

// tuple : (type, kind, index)
typealias Values = (String, varKind, Int)

class SymbolTable {
    private var table: [String : Values]
    private var  staticIndex = 0
    private var fieldIndex = 0
    private var argIndex = 0
    private var varIndex = 0
    
    init() {
        table = [:]
    }
    
    func reset() {
        staticIndex = 0
        fieldIndex = 0
        argIndex = 0
        varIndex = 0
        table = [:]
    }
    
    func define(name: String, type: String, kind: varKind) {
        var hashIndex = 0
        if kind == varKind.STATIC {
            hashIndex = staticIndex
            staticIndex += 1
        }
        if kind == varKind.FIELD {
            hashIndex = fieldIndex
            fieldIndex += 1
        }
        if kind == varKind.ARG {
            hashIndex = argIndex
            argIndex += 1
        }
        if kind == varKind.VAR {
            hashIndex = varIndex
            varIndex += 1
        }
        table[name] = (type, kind, hashIndex)
    }
    
    func varCount(kind: varKind) -> Int {
        var count = 0
        for (_, value) in table {
            let (_, v_kind, _) = value
            if v_kind == kind {
                count += 1
            }
        }
        return count
    }
    
    func kindOf(name: String) -> varKind {
        if let (_, kind, _) = table[name] {
            return kind
        }
        return varKind.NONE
    }
    
    func typeOf(name: String) -> String {
        if let (type, _, _) = table[name] {
            return type
        }
        return ""
    }
    
    func indexOf(name: String) -> Int {
        if let (_, _, index) = table[name] {

            return index
        }
        return -1
    }
}
