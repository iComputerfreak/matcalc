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
enum UIError: Error {
    case NumberInputError
    case LineLengthError
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
                print("[ERROR] This function has not been implemented yet")
                continue
            } else {
                print("[ERROR] Please enter 'literal' or 'formula'")
                continue
            }
            
            if m != nil {
                print("")
                print("The determinant of the matrix")
                print(m!.description)
                print("is \(m!.determinant())")
                print("")
                print("")
            } else {
                // Error already printed in sub method
            }
        }
        
    }
    
    
    /// Reads a literal matrix from the console
    ///
    /// - Returns: the read matrix or nil, if there were any errors
    private static func readLiteralMatrix() -> Matrix? {
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
                    } catch UIError.NumberInputError {
                        // Error already printed in submethod
                        return nil
                    } catch UIError.LineLengthError {
                        // Error already printed in submethod
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
            print("[ERROR] Please enter exactly \(size) elements for this row!")
            throw UIError.LineLengthError
        }
        for i in 0..<size {
            let d = Double(components[i])
            if d == nil {
                print("[ERROR] Wrong input: '\(components[i])' is not a number.")
                throw UIError.NumberInputError
            }
            returnValue[i] = d!
        }
        return returnValue
    }
    
}















