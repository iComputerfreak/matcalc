//
//  main.swift
//  matcalc
//
//  Created by Jonas Frey on 03.02.17.
//  Copyright © 2017 Jonas Frey, Marcus Schilling. All rights reserved.
//

import Foundation
var matrix = Matrix(matrix: [[1,0,0],[4,1,0],[1,2,1]])
var s = Matrix(matrix: [[1,0,0],[1,1,0],[4,3,1]])

try print((s*matrix).description)
try print((matrix*s).description)
print(matrix.gauß().description)

UserInterface.start()




















