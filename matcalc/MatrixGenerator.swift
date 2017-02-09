//
//  MatrixGenerator.swift
//  matcalc
//
//  Created by Jonas Frey on 03.02.17.
//  Copyright © 2017 Jonas Frey. All rights reserved.
//

import Foundation

/// Represents a generator for matrices with a given operation
class MatrixGenerator {
    
    /// The operation that returns the element at a given index of the matrix
    var operation: (Int, Int) -> Double
    
    /// Initializes the generator with a operation
    ///
    /// - Parameter operation: The operation returning the element at a given position of the matrix
    init(operation: @escaping (Int, Int) -> Double) {
        self.operation = operation
    }
    
    /// Returns a matrix with the given size
    ///
    /// - Parameter n: the size of the return matrix
    /// - Returns: a matrix where each element is described by the operation given in the initializer
    public func getMatrix(n: Int) -> Matrix {
        return MatrixGenerator.generate(n: n, operation: operation)
    }
    
    /// Generates a matrix from the given operation with the given size
    ///
    /// - Parameters:
    ///   - n: the size of the return matrix
    ///   - operation: the operations that returns the element at a given position
    /// - Returns: a matrix created from the operation with size nxn
    public class func generate(n: Int, operation: (Int, Int) -> Double) -> Matrix {
        
        var matrix = [[Double]](repeating: [Double](repeating: 0, count: n), count: n)
        
        for i in 0..<n {
            for j in 0..<n {
                matrix[i][j] = operation(i, j)
            }
        }
        
        return Matrix(matrix: matrix)
        
    }
}
