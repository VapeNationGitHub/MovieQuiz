//
//  MovieQuizTests.swift
//  MovieQuizTests
//
//  Created by Никита Пономарев on 11.03.2025.
//


// Не удалил этот файл, т.к. оставил для себя, как шаблон тестов


import XCTest

struct ArithmeticOperations {
    func addition(num1: Int, num2: Int, handler: @escaping (Int) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            handler(num1 + num2)
        }
    }
    
    func subtraction(num1: Int, num2: Int, handler: @escaping (Int) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            handler(num1 - num2)
        }
    }
    
    func multiplication(num1: Int, num2: Int, handler: @escaping (Int) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            handler(num1 * num2)
        }
    }
}

/*
 struct ArithmeticOperations {
 func addition(num1: Int, num2: Int) -> Int {
 return num1 + num2
 }
 
 func subtraction(num1: Int, num2: Int) -> Int {
 return num1 - num2
 }
 
 func multiplication(num1: Int, num2: Int) -> Int {
 return num1 * num2
 }
 }
 */

class MovieQuizTests: XCTestCase {
    func testAddition() throws {
        // Given
        let arithmeticOperations = ArithmeticOperations()
        let num1 = 1
        let num2 = 2
        
        // When
        let expectation = expectation(description: "Addition function expectation")
        
        arithmeticOperations.addition(num1: num1, num2: num2) { result in
            // Then
            XCTAssertEqual(result, 3)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 2)
        
        /*
         let arithmeticOperations = ArithmeticOperations()
         let result = arithmeticOperations.addition(num1: 1, num2: 2)
         XCTAssertEqual(result, 3) // сравниваем результат выполнения функции и наши ожидания
         */
    }
}
