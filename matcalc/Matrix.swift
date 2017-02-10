//
//  Matrix.swift
//  matcalc
//
//  Created by Jonas Frey on 03.02.17.
//  Copyright © 2017 Jonas Frey. All rights reserved.
//

import Foundation


/// Represents errors within the Matrix class
///
/// - IllegalArgumentError: error thrown when an invalid parameter has been passed to a function
enum MatrixError: Error {
    case IllegalArgumentError
}

/// Represents a quadratic matrix
class Matrix {
    
    // matrix will never be empty. matrix always has at least 1 element
    
    /// the matrix
    private var matrix: [[Double]]
    
    /// The size of the matrix
    public var size: Int {
        get {
            return matrix[0].count
        }
    }
    
    /// Creates an empty 1x1 matrix
    convenience init() {
        self.init(size: 1)
    }
    
    /// Creates an empty size x size matrix
    /// Every element of the created matrix is 0
    ///
    /// - Parameter size: the size of the matrix to create
    convenience init(size: Int) {
        if size <= 0 {
            self.init(matrix: [[0]])
        } else {
            self.init(matrix: [[Double]](repeating: [Double](repeating: 0.0, count: size), count: size))
        }
    }
    
    /// Creates a matrix from the given 2-dimensional Double array
    ///
    /// - Parameter matrix: the given matrix as array
    init(matrix: [[Double]]) {
        self.matrix = matrix
    }
    
    /// Gets an element of the matrix
    ///
    /// - Parameters:
    ///   - i: the row of the element
    ///   - j: the column of the element
    /// - Returns: The element at position i and j (`matrix[i][j]`)
    /// - Throws: `MatrixError.IllegalArgumentError` when the index i or j is out of bounds
    public func get(_ i: Int, _ j: Int) throws -> Double {
        guard i > 0 && i <= size && j > 0 && j <= size else {
            throw MatrixError.IllegalArgumentError
        }
        return matrix[i][j]
    }
    
    /// Gets an element of the matrix
    ///
    /// - Warning: Only do this, if you know, that i and j are not out of bounds (e.g. iterating i and j)
    /// - Parameters:
    ///   - i: the row of the element
    ///   - j: the column of the element
    /// - Returns: The element at position i and j (`matrix[i][j]`)
    public func getUnsafe(_ i: Int, _ j: Int) -> Double {
        return matrix[i][j]
    }
    
    /// Sets an element of the matrix
    ///
    /// - Parameters:
    ///   - i: the row of the element
    ///   - j: the column of the element
    ///   - newValue: the new value to set at the position
    /// - Throws: `MatrixError.IllegalArgumentError` when the index i or j is out of bounds
    public func set(_ i: Int, _ j: Int, newValue: Double) throws {
        guard i > 0 && i <= size && j > 0 && j <= size else {
            throw MatrixError.IllegalArgumentError
        }
        matrix[i][j] = newValue
    }
    
    /// Sets an element of the matrix
    ///
    /// - Warning: Only do this, if you known, that i and j are not out of bounds (e.g. iterating i and j)
    /// - Parameters:
    ///   - i: the row of the element
    ///   - j: the column of the element
    ///   - newValue: the new value to set at the position
    public func setUnsafe(_ i: Int, _ j: Int, newValue: Double) {
        matrix[i][j] = newValue
    }
    
    /// Sets an complete line of the matrix
    ///
    /// - Parameters:
    ///   - i: the row to override
    ///   - line: the line to put at the given row
    /// - Throws: `MatrixError.IllegalArgumentError` when the index i is out of bounds
    public func setLine(i: Int, line: [Double]) throws {
        guard line.count == size else {
            throw MatrixError.IllegalArgumentError
        }
        matrix[i] = line
    }
    
    /// Removes a complete line and a complete column from the matrix
    ///
    /// - Parameters:
    ///   - i: the row to remove
    ///   - j: the column to remove
    /// - Returns: a matrix of the size (`size - 1`)
    public func removeLineAndColumn(_ i: Int, _ j: Int) -> Matrix {
        let m = Matrix(size: self.size - 1)
        for line in 0..<self.size {
            for col in 0..<self.size {
                if line == i || col == j {
                    continue
                }
                m.matrix[(line < i ? line : line - 1)][(col < j ? col : col - 1)] = matrix[line][col]
            }
        }
        return m
    }
    
    /// Calculates the determinant of the matrix
    ///
    /// - Returns: the determinant of this matrix
    public func determinant() -> Double {
        
        if self.size == 1 {
            return self.matrix[0][0]
        } else if self.size == 2 {
            return self.matrix[0][0] * self.matrix[1][1] - self.matrix[1][0] * self.matrix[0][1]
        }
        
        // calculating after last column:
        var determinant: Double = 0
        let j = self.size - 1
        for i in 0..<size {
            // Laplace:
            determinant += ((i + j) % 2 == 0 ? 1 : -1) * self.matrix[i][j] * self.removeLineAndColumn(i, j).determinant()
            // 36
        }
        
        return determinant
        
    }
    
    /// <#Description#>
    ///
    /// - Returns: <#return value description#>
    func gauss() -> Matrix {
        let matrix = Matrix(matrix: self.matrix)
        var illegalBases = [Int]()
        for column in 0..<matrix.size {
            if matrix.isNullColumn(columnPosition: column) {
                continue
            }
            let positionCalculatorResult: (Int, [Int]) = matrix.baseLine(column: column, illegalBases: illegalBases)
            let positionCalculatorLine: Int = positionCalculatorResult.0
            illegalBases = positionCalculatorResult.1
            if positionCalculatorLine == -1 {
                continue
            }
            for line in 0..<matrix.size {
                if matrix.matrix[line][column] != 0 && line != positionCalculatorLine {
                    let multiplicator: Double = -( matrix.matrix[line][column]/matrix.matrix[positionCalculatorLine][column])
                    matrix.addLineToOtherLine(firstLine: positionCalculatorLine, lambda: multiplicator, secondLine: line)
                }
            }
        }
        for columnAndRow in 0..<matrix.size {
            if matrix.matrix[columnAndRow][columnAndRow] == 0 {
                continue
            } else {
                let multiplicator: Double = 1 / matrix.matrix[columnAndRow][columnAndRow]
                matrix.multiplyLine(line: columnAndRow, lambda: multiplicator)
            }
        }
        matrix.sort()
        return matrix
    }
    
    /// <#Description#>
    ///
    /// - Parameters:
    ///   - column: <#column description#>
    ///   - illegalBases: <#illegalBases description#>
    /// - Returns: <#return value description#>
    func baseLine(column: Int, illegalBases: [Int]) -> (Int, [Int]) {
        var newIllegalBase = illegalBases
        for row in 0..<matrix.count {
            if matrix[row][column] != 0 {
                if newIllegalBase.contains(row) {
                    continue
                } else {
                    newIllegalBase.append(row)
                    return (row, newIllegalBase)
                }
            }
        }
        return (-1, newIllegalBase)
    }
    
    /// <#Description#>
    ///
    /// - Parameter columnPosition: <#columnPosition description#>
    /// - Returns: <#return value description#>
    public func isNullColumn(columnPosition: Int) -> Bool {
        for row in 0..<self.size {
            if matrix[row][columnPosition] != 0 {
                return false
            }
        }
        return true
    }
    
    /// <#Description#>
    public func transpose() {
        var resultMatrix = [[Double]](repeating: [Double](repeating: 0, count: self.size), count: self.size)
        for row in 0..<self.size {
            for column in 0..<self.size {
                resultMatrix[column][row] = matrix[row][column]
            }
        }
        matrix = resultMatrix
    }
    
    /// <#Description#>
    func sort() {
        transpose()
        matrix.sort { (first, second) -> Bool in
            if zeroLine(line: first){
                return false
            }else if zeroLine(line: second){
                return true
            }
            for i in 0..<first.count {
                if first[i] > second[i] {
                    return true
                } else if first[i] < second[i] {
                    return false
                }
            }
            return true
        }
        transpose()
    }
    
    /// <#Description#>
    ///
    /// - Parameter line: <#line description#>
    /// - Returns: <#return value description#>
    func zeroLine(line: [Double])-> Bool {
        return line.elementsEqual([Double](repeating: 0.0, count: line.count))
    }
    
    
    /// <#Description#>
    ///
    /// - Parameters:
    ///   - first: <#first description#>
    ///   - second: <#second description#>
    func swapLines(first: Int, second: Int) {
        let firstLine = matrix[second]
        let secondLine = matrix[first]
        
        self.matrix[first] = firstLine
        self.matrix[second] = secondLine
    }
    
    
    /// <#Description#>
    ///
    /// - Parameters:
    ///   - firstLine: <#firstLine description#>
    ///   - lambda: <#lambda description#>
    ///   - secondLine: <#secondLine description#>
    func addLineToOtherLine(firstLine: Int, lambda: Double, secondLine: Int) {
        for i in 0..<self.size {
            matrix[secondLine][i] += lambda * matrix[firstLine][i]
        }
    }
    
    /// <#Description#>
    ///
    /// - Parameters:
    ///   - line: <#line description#>
    ///   - lambda: <#lambda description#>
    func multiplyLine(line: Int, lambda: Double){
        for i in 0..<self.size {
            matrix[line][i] *= lambda
        }
    }
    
    /// Returns the matrix as a padded string
    var description: String {
        var output = ""
        for row in matrix {
            for col in row {
                var entry = ""
                if col >= 0 {
                    entry += " "
                }
                if col < 10 && (col < 0 ? -col : col) < 10 {
                    entry += " "
                }
                entry += "\(col)  "
                output += entry
            }
            output = output.substring(to: output.index(output.startIndex, offsetBy: output.characters.count - 1))
            output += "\n"
        }
        return output
    }
    
}





















