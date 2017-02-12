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
    
    /// The size of the matrix first value = line second value = columns
    public var size: (lines: Int, columns: Int) {
        get {
            return (matrix.count, matrix[0].count)
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
    
    /// Creates an empty size nxm matrix
    /// Every element of the created matrix is 0
    /// 
    /// - Parameter n = number of lines
    /// - Parameter m = number of columns
    init(n: Int, m: Int){
        self.matrix = [[Double]](repeating: [Double](repeating: 0.0, count: m), count: n)
    }
    
    /// Gets an element of the matrix
    ///
    /// - Parameters:
    ///   - i: the row of the element
    ///   - j: the column of the element
    /// - Returns: The element at position i and j (`matrix[i][j]`)
    /// - Throws: `MatrixError.IllegalArgumentError` when the index i or j is out of bounds
    public func get(_ i: Int, _ j: Int) throws -> Double {
        guard i > 0 && i <= size.lines && j > 0 && j <= size.columns else {
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
        guard i > 0 && i <= size.lines && j > 0 && j <= size.columns else {
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
        guard line.count == size.lines else {
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
        let m = Matrix(size: self.size.lines - 1)
        for line in 0..<self.size.lines {
            for col in 0..<self.size.columns {
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
        
        if self.size.lines == 1 && self.size.columns == 1 {
            return self.matrix[0][0]
        } else if self.size.lines == 2 && self.size.columns == 2 {
            return self.matrix[0][0] * self.matrix[1][1] - self.matrix[1][0] * self.matrix[0][1]
        }
        
        // calculating after last column:
        var determinant: Double = 0
        let j = self.size.lines - 1
        for i in 0..<size.lines {
            // Laplace:
            determinant += ((i + j) % 2 == 0 ? 1 : -1) * self.matrix[i][j] * self.removeLineAndColumn(i, j).determinant()
            // 36
        }
        
        return determinant
        
    }
    
    /// Operator overloading of + executes a component wise addition
    static func +(left: Matrix, right: Matrix) throws -> Matrix {
        guard left.matrix.count == right.matrix.count && right.matrix[0].count == left.matrix[0].count else {
            throw MatrixError.IllegalArgumentError
        }
        let result: Matrix = Matrix(n: left.size.columns, m: left.size.lines)
        for line in 0..<left.matrix.count{
            for column in 0..<left.matrix[0].count{
                result.matrix[line][column] = left.matrix[line][column] + right.matrix[line][column]
            }
        }
        return result
    }
    
    
    /// this method implements the matrix multiplication for nxm with mxk Matrixes this method is not commutative
    ///
    /// - Parameters:
    ///   - left: matrix
    ///   - right: matrix of the operation
    /// - Returns: the result of the matrix multiplication
    /// - Throws: an IllegalArgumentError if and only if there are is no multiplication of nxm*mxk
    static func *(left: Matrix, right: Matrix) throws -> Matrix{
        var result: Matrix = Matrix()
        guard left.matrix[0].count == right.matrix.count else{
            throw MatrixError.IllegalArgumentError
        }
        result = Matrix(matrix: [[Double]](repeating: [Double](repeating: 0.0, count: right.matrix[0].count), count: left.size.lines))
        for i in 0..<result.matrix.count{
            for k in 0..<result.matrix[0].count{
                result.matrix[i][k] = c(i: i, k: k, leftMatrix: left.matrix, rightMatrix: right.matrix)
            }
        }
        return result
    }
    
    /// Operator overolading of * with a scalar and a matrix
    static func*(λ: Double, left: Matrix)-> Matrix{
        let result: Matrix = Matrix(n: left.size.lines, m: left.size.columns)
        for line in 0..<left.matrix.count{
            for column in 0..<left.matrix[0].count{
                result.matrix[line][column] = λ * left.matrix[line][column]
            }
        }
        return result
    }
    
    ///calculates the result component on line i and column k of a matrix multiplication of leftMatrix * rightMatrix
    private static func c(i: Int, k: Int, leftMatrix: [[Double]], rightMatrix: [[Double]]) -> Double{
        var c: Double = 0
        for j in 0 ..< leftMatrix[0].count{
            c += leftMatrix[i][j] * rightMatrix[j][k]
        }
        return c
    }
    
    ///returns a after gauß in gauß normal form
    func gauß() -> Matrix{
        let matrix: Matrix = Matrix(matrix: self.matrix)
        var illegalBases: [Int] = [Int]()
        for column in 0..<matrix.matrix[0].count {
            if matrix.isNullColumn(columnPosition: column) {
                continue
            }
            let positionCalculatorResult: (Int, [Int]) = matrix.baseLine(column: column, illegalBases: illegalBases)
            let positionCalculatorLine: Int = positionCalculatorResult.0
            illegalBases = positionCalculatorResult.1
            if positionCalculatorLine == -1 {
                continue
            }
            for line in 0..<matrix.size.lines {
                if matrix.matrix[line][column] != 0 && line != positionCalculatorLine {
                    let multiplicator: Double = -( matrix.matrix[line][column]/matrix.matrix[positionCalculatorLine][column])
                    matrix.addLineToOtherLine(firstLine: positionCalculatorLine, lambda: multiplicator, secondLine: line)
                }
            }
        }
        for columnAndRow in 0..<matrix.size.lines {
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
    
    /// calculates the baseline from which out a specific
    ///
    /// - Parameters:
    ///   - column: of which the baseline is searched
    ///   - illegalBases: which cannot be a baseline because they already a baseline and would
    /// - Returns: a tuppel of the baseLine index and the newly illegalBases
    func baseLine(column: Int, illegalBases: [Int]) -> ( Int, [Int]){
        var newIllegalBase: [Int] = illegalBases
        for line in 0..<matrix.count {
            if matrix[line][column] != 0 {
                if newIllegalBase.contains(line) {
                    continue
                } else {
                    newIllegalBase.append(row)
                    return (row, newIllegalBase)
                }
            }
        }
        return (-1, newIllegalBase)
    }
    
    /// analyses a collumn whether it contains only 0 values
    ///
    /// - Parameter columnPosition: index of the column which should be analysed
    /// - Returns: true if the column contains only 0 values otherwise false
    public func isNullColumn(columnPosition: Int) -> Bool {
        for row in 0..<self.size.lines {
            if matrix[row][columnPosition] != 0 {
                return false
            }
        }
        return true
    }
    
    /// transposes the matrix which means lines are transformed to columns
    public func transpose() {
        var resultMatrix: [[Double]] = Array.init(repeating: Array.init(repeating: 0, count: size.columns), count: size.columns)
        for line in 0..<size.lines{
            for column in 0..<size.columns{
                resultMatrix[column][line] = matrix[line][column]
            }
        }
        matrix = resultMatrix
    }
    
    /// sorts the matrix after the criteria which element in the columns are higher read from left
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
    
    /// indicates whether a specific line contains only null elements
    ///
    /// - Parameter line: the line given as a array of double elements
    /// - Returns: true if all elements of line equal 0
    func zeroLine(line: [Double])-> Bool {
        return line.elementsEqual([Double](repeating: 0.0, count: line.count))
    }
    
    
    /// swaps to lines of this matrix
    ///
    /// - Parameters:
    ///   - first: index of the first line which gets swapped
    ///   - second: index of the second line which gets swapped
    func swapLines(first: Int, second: Int) {
        let firstLine = matrix[second]
        let secondLine = matrix[first]
        
        self.matrix[first] = firstLine
        self.matrix[second] = secondLine
    }
    
    
    /// adds a lambda multiple of the firstline to the second line
    ///
    /// - Parameters:
    ///   - firstLine: index of first line
    ///   - lambda: multiplicator for the first line
    ///   - secondLine: which should be added
    func addLineToOtherLine(firstLine: Int, lambda: Double, secondLine: Int) {
        for i in 0..<self.size.lines {
            matrix[secondLine][i] += lambda * matrix[firstLine][i]
        }
    }
    
    /// Gauß operation multiplies all elements on the line with a λ
    func multiplyLine(line: Int, λ: Double){
        for i in 0..<matrix[0].count {
            matrix[line][i] *= λ
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





















