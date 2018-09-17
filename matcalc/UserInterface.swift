    
//
//  UserInterface.swift
//  matcalc
//
//  Created by Jonas Frey on 04.02.17.
//  Copyright © 2017 Jonas Frey. All rights reserved.
//

import Foundation


/// UserInterface Errors
///
/// - NumberInputError: parsing error, when a number is expected, but something else given to parse
/// - LineLengthError: parsing error, when the number of elements in the input string doesn't match the expected size
/// - InvalidFormulaError: parsing error, the given formula is invalid. (e.g. `a(3)` or `a(3,)`
enum UIError: Error {
    case NumberInputError(String)
    case LineLengthError(String)
    case InvalidFormulaError(String)
    case InvalidArgumentError(String)
}

/// Represents the user interface
class UserInterface {
    
    
    /// Starts the user interface and waits for an input
    public static func start() {
        
        while (true) {
            print("Please select the type of matrix you want to enter (literal/formula): ", terminator: "")
            
            let method = readLine()
            let m: Matrix?
            if method != nil && method! == "literal" {
                m = readLiteralMatrix()
            } else if method != nil && method! == "formula" {
                m = readFormulaMatrix()
            } else {
                print("[ERROR] Please enter 'literal' or 'formula'")
                continue
            }
            
            if m != nil {
                print("")
                print("The determinant of the matrix")
                print(m!.description)
                print("is \(m!.determinant())")
                print("After Gauß transition the result Matrix is:")
                print("\(m!.gauß().description)")
                print("")
                print("Matrix is symmetrical: \(m!.isSymmetrical())")
                print("")
            } else {
                // Error already printed in sub method
            }
        }
        
    }
    
    
    /// Reads a literal matrix from the console
    ///
    /// - Returns: the read matrix or nil, if there were any errors
    public static func readLiteralMatrix() -> Matrix? {
        print("Please enter the first line of the matrix separated by spaces. This line defines the size of the nxn matrix.")
        
        if let line1 = readLine() {
            let size = line1.components(separatedBy: " ").count
            let m = Matrix(size: size)
            
            do {
                try m.setLine(i: 0, line: parseLine(line: line1, size: size))
            } catch MatrixError.IllegalArgumentError {
                print("[ERROR] The entered line has to be of length \(size)")
                return nil
            } catch let error {
                print("[ERROR] \(error.localizedDescription)")
                return nil
            }
            
            for i in 1..<size {
                if let line = readLine() {
                    do {
                        try m.setLine(i: i, line: parseLine(line: line, size: size))
                    } catch MatrixError.IllegalArgumentError {
                        print("[ERROR] The entered line has to be of length \(size)")
                        return nil
                    } catch UIError.NumberInputError(let description) {
                        print("[ERROR] \(description)")
                        return nil
                    } catch UIError.LineLengthError(let description) {
                        print("[ERROR] \(description)")
                        return nil
                    } catch let error {
                        print("[ERROR] \(error.localizedDescription)")
                        return nil
                    }
                } else {
                    print("[ERROR] Reading line failed.")
                    return nil
                }
            }
            return m
        } else {
            print("[ERROR] Error reading first line")
            return nil
        }
    }
    
    /// Reads a matrix defined by a formula from the console
    ///
    /// - Returns: The matrix or nil if there was an error
    public static func readFormulaMatrix() -> Matrix? {
        print("Please enter the size of the matrix: ", terminator: "")
        if let readInt = readLine() {
            if let size = Int(readInt) {
                
                print("Do you want to enter multiple formulas (y/N): ", terminator: "")
                let answer = readLine()
                if answer?.lowercased() == "y" {
                    // Multiple formulas
                    print("[ERROR] This function has not been implemented yet.")
                    return nil
                } else if answer?.lowercased() == "n" || answer?.lowercased() == "" {
                    // One single formula
                    print("Please enter the formla for the entry. You can use the following patterns: i, j, n, a(Int, Int)")
                    print("  formula: ", terminator: "")
                    let formula = readLine()
                    if formula != nil && !formulaInputIsValid(formula!) {
                        print("[ERROR] Formula not valid.")
                    }
                    
                    var expression: NSExpression? = nil
                    // If the formula doesnt contain an expression of the type 'a(Int, Int)', its parsed right here
                    if formula!.contains("a") {
                        do {
                            expression = try formulaExpression(formula: formula!, m: Matrix())
                        } catch UIError.InvalidFormulaError(let description) {
                            print("[ERROR] \(description)")
                            return nil
                        } catch let error {
                            print("Unknown error! \(error.localizedDescription)")
                            return nil
                        }
                    }
                    // else the expression stays nil and has to be parsed every step!
                    
                    let matrix = Matrix(size: size)
                    for i in 0..<size {
                        for j in 0..<size {
                            do {
                                if expression != nil {
                                    matrix.setUnsafe(i, j, newValue: try evaluateFormulaExpression(expression!, i: i, j: j, n: size))
                                } else {
                                    let realExpression = try formulaExpression(formula: formula!, m: matrix)
                                    let value = try evaluateFormulaExpression(realExpression, i: i, j: j, n: size)
                                    matrix.setUnsafe(i, j, newValue: value)
                                }
                            } catch UIError.InvalidFormulaError(let description) {
                                print("[ERROR] \(description)")
                                return nil
                            } catch let error {
                                print("Unknown Error! \(error.localizedDescription)")
                                return nil
                            }
                        }
                    }
                    return matrix
                }
                
            } else {
                print("[ERROR] Wrong input: '\(readInt)' is not an integer number.")
            }
        } else {
            print("[ERROR] Reading line failed.")
        }
        return nil
    }
    
    // MARK: - Private helping functions
    
    /// Parses a line of numbers as a line of a matrix
    ///
    /// - Parameters:
    ///   - line: the input string to parse
    ///   - size: the size of the matrix
    /// - Returns: A correct line of a matrix parsed from the input string
    /// - Throws: `UIError.LineLengthError` when the number of elements in the input string are not matching the expected size
    ///           `UIError.NumberInputError` when some element of the line is not a number
    private static func parseLine(line: String, size: Int) throws -> [Double] {
        
        var returnValue = [Double](repeating: 0, count: size)
        let components = line.components(separatedBy: " ")
        if components.count != size {
            throw UIError.LineLengthError("Please enter exactly \(size) elements for this row")
        }
        for i in 0..<size {
            let d = Double(components[i])
            if d == nil {
                throw UIError.NumberInputError("Wrong input: '\(components[i])' is not a number.")
            }
            returnValue[i] = d!
        }
        return returnValue
    }
    
    
    /// Checks if the formula is valid, meaning only contains these characters:
    /// `['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', ',', '(', ')', 'a', 'i', 'j', 'n', ' ', '+', '-', '*', '/', '^']`
    ///
    /// - Parameter formula: The formula string to check
    /// - Returns: true, if the formula is valid
    private static func formulaInputIsValid(_ formula: String) -> Bool {
        return String(formula.characters.filter { !"01234567890,()aijn+-*/^ ".characters.contains($0) }).characters.count == 0
    }
    
    /// Calculates the result of the given NSExpression
    ///
    /// - Parameters:
    ///   - formulaExpression: the expression to calculate
    ///   - i: the current row of the matrix
    ///   - j: the current column of the matrix
    ///   - n: the size of the current matrix
    /// - Returns: the result of the expression
    /// - Throws: `UIError.InvalidFormulaError` when there is an error in calculating the expression
    private static func evaluateFormulaExpression(_ formulaExpression: NSExpression, i: Int, j: Int, n: Int) throws -> Double {
        
        let intDictionary = ["i": i, "j": j, "n": n]
        if let result = formulaExpression.expressionValue(with: intDictionary, context: nil) as? Double {
            return result
        } else {
            throw UIError.InvalidFormulaError("Formula could not be expressed!")
        }
    }
    
    /// Generates an NSExpression from a formula string
    ///
    /// - Parameters:
    ///   - formula: formula input from the console. Must be checked with `isFormulaInputValid` first
    ///   - m: the current matrix or nil of none is needed for the expression
    /// - Returns: an expression generated from the formula
    /// - Throws: `UIError.InvalidArgumentError` when `matrix` is nil, but a matrix is needed for calculation
    ///           `UIError.InvalidFormulaError` when something with the formula is wrong
    private static func formulaExpression(formula: String, m: Matrix?) throws -> NSExpression {
        var correctedFormula = formula.replacingOccurrences(of: " ", with: "")
        
        if correctedFormula.contains("a") {
            if m == nil {
                throw UIError.InvalidArgumentError("No matrix given, but needed for generating expression!")
            }
            // replace a(i,j) with real number
            let scanner = Scanner(string: formula.replacingOccurrences(of: " ", with: ""))
            while !scanner.isAtEnd {
                scanner.scanUpTo("a(", into: nil)
                scanner.scanString("a(", into: nil)
                var iString: NSString?
                scanner.scanUpTo(",", into: &iString)
                scanner.scanString(",", into: nil)
                var jString: NSString?
                scanner.scanUpTo(")", into: &jString)
                if iString == nil || jString == nil {
                    // Error parsing -> Formula invalid
                    throw UIError.InvalidFormulaError("The given formula is invalid.")
                }
                
                // parse input as integers i and j
                if let i = Int(iString as! String) {
                    if let j = Int(jString as! String) {
                        do {
                            try correctedFormula = correctedFormula.replacingOccurrences(of: "a(\(i),\(j))", with: String(m!.get(i, j)))
                        } catch MatrixError.IllegalArgumentError {
                            throw UIError.InvalidFormulaError("The expression 'a(\(i),\(j))' is invalid, because i or j is out of the bounds of the matrix")
                        }
                    } else {
                        throw UIError.InvalidFormulaError("The given formula is invalid. '\(jString as! String)' is not a number.")
                    }
                } else {
                    throw UIError.InvalidFormulaError("The given formula is invalid. '\(iString as! String)' is not a number.")
                }
            }
        }
        
        // The matrix now should only contains the expressions 'i', 'j' and 'n'
        if correctedFormula.contains(",") || correctedFormula.contains("a") {
            throw UIError.InvalidFormulaError("The formula contains the characters 'a' or ',' in a not valid expression. Please only use these for 'a(Int, Int)'")
        }
        
        return NSExpression(format: correctedFormula)
    }
    
}















