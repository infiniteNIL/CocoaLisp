//
//  QuoteTests.swift
//  CocoaLispTests
//
//  Created by Rod Schmidt on 5/15/19.
//  Copyright © 2019 infiniteNIL. All rights reserved.
//

import XCTest
@testable import CocoaLisp

class QuoteTests: XCTestCase {

    override func setUp() {
        super.setUp()
        try! CocoaLisp.start()
    }

    func testConsFunction() {
        let tests = [
            ("(cons 1 (list))", "(1)"),
            ("(cons 1 (list 2))", "(1 2)"),
            ("(cons 1 (list 2 3))", "(1 2 3)"),
            ("(cons (list 1) (list 2 3))", "((1) 2 3)"),
            ("(def a (list 2 3))", "(2 3)"),
            ("(cons 1 a)", "(1 2 3)"),
            ("a", "(2 3)"),
        ]
        runTests(tests)
    }

    func testConcatFunction() {
        let tests = [
            ("(concat)", "()"),
            ("(concat (list 1 2))", "(1 2)"),
            ("(concat (list 1 2) (list 3 4))", "(1 2 3 4)"),
            ("(concat (list 1 2) (list 3 4) (list 5 6))", "(1 2 3 4 5 6)"),
            ("(concat (concat))", "()"),
            ("(concat (list) (list))", "()"),

            ("(def a (list 1 2))", "(1 2)"),
            ("(def b (list 3 4))", "(3 4)"),
            ("(concat a b (list 5 6))", "(1 2 3 4 5 6)"),
            ("a", "(1 2)"),
            ("b", "(3 4)"),
        ]
        runTests(tests)
    }

    func testRegularQuote() {
        let tests = [
            ("(quote 7)", "7"),
            ("(quote (1 2 3))", "(1 2 3)"),
            ("(quote (1 2 (3 4)))", "(1 2 (3 4))"),
        ]
        runTests(tests)
    }

    func testSimpleQuasiQuote() {
        let tests = [
            ("(quasiquote 7)", "7"),
            ("(quasiquote (1 2 3))", "(1 2 3)"),
            ("(quasiquote (1 2 (3 4)))", "(1 2 (3 4))"),
            ("(quasiquote (nil))", "(nil)"),
        ]
        runTests(tests)
    }

    func testUnquote() {
        let tests = [
            ("(quasiquote (unquote 7))", "7"),
            ("(def a 8)", "8"),
            ("(quasiquote a)", "a"),
            ("(quasiquote (unquote a))", "8"),
            ("(quasiquote (1 a 3))", "(1 a 3)"),
            ("(quasiquote (1 (unquote a) 3))", "(1 8 3)"),
            ("(def b (quote (1 \"b\" \"d\")))", "(1 \"b\" \"d\")"),
            ("(quasiquote (1 b 3))", "(1 b 3)"),
            ("(quasiquote (1 (unquote b) 3))", "(1 (1 \"b\" \"d\") 3)"),
            ("(quasiquote ((unquote 1) (unquote 2)))", "(1 2)"),
        ]
        runTests(tests)
    }

    func testSpliceUnquote() {
        let tests = [
            ("(def c (quote (1 \"b\" \"d\")))", "(1 \"b\" \"d\")"),
            ("(quasiquote (1 c 3))", "(1 c 3)"),
            ("(quasiquote (1 (splice-unquote c) 3))", "(1 1 \"b\" \"d\" 3)"),
        ]
        runTests(tests)
    }

    func testSymbolEquality() {
        let tests = [
            ("(= (quote abc) (quote abc))", "true"),
            ("(= (quote abc) (quote abcd))", "false"),
            ("(= (quote abc) \"abc\")", "false"),
            ("(= \"abc\" (quote abc))", "false"),
            ("(= \"abc\" (str (quote abc)))", "true"),
            ("(= (quote abc) nil)", "false"),
            ("(= nil (quote abc))", "false"),
        ]
        runTests(tests)
    }

    // Test quine
    // TODO: needs expect line length fix
    //((fn* [q] (quasiquote ((unquote q) (quote (unquote q))))) (quote (fn* [q] (quasiquote ((unquote q) (quote (unquote q)))))))
    //=>((fn* [q] (quasiquote ((unquote q) (quote (unquote q))))) (quote (fn* [q] (quasiquote ((unquote q) (quote (unquote q)))))))

    func testQuoteReaderMacro() {
        let tests = [
            ("'7", "7"),
            ("'(1 2 3)", "(1 2 3)"),
            ("'(1 2 (3 4))", "(1 2 (3 4))"),
        ]
        runTests(tests)
    }

    func testQuasiQuoteReaderMacro() {
        let tests = [
            ("`7", "7"),
            ("`(1 2 3)", "(1 2 3)"),
            ("`(1 2 (3 4))", "(1 2 (3 4))"),
            ("`(nil)", "(nil)"),
        ]
        runTests(tests)
    }

    func testUnquoteReaderMacro() {
        let tests = [
            ("`~7", "7"),
            ("(def a 8)", "8"),
            ("`(1 ~a 3)", "(1 8 3)"),
            ("(def b '(1 \"b\" \"d\"))", "(1 \"b\" \"d\")"),
            ("`(1 b 3)", "(1 b 3)"),
            ("`(1 ~b 3)", "(1 (1 \"b\" \"d\") 3)"),
        ]
        runTests(tests)
    }

    func testSpliceUnquoteReaderMacro() {
        let tests = [
            ("(def c '(1 \"b\" \"d\"))", "(1 \"b\" \"d\")"),
            ("`(1 c 3)", "(1 c 3)"),
            ("`(1 ~@c 3)", "(1 1 \"b\" \"d\" 3)"),
        ]
        runTests(tests)
    }

    func testVectorFuncs() {
        let tests = [
            ("(cons [1] [2 3])", "([1] 2 3)"),
            ("(cons 1 [2 3])", "(1 2 3)"),
            ("(concat [1 2] (list 3 4) [5 6])", "(1 2 3 4 5 6)"),
        ]
        runTests(tests)
    }

    func testUnquoteWithVectors() {
        let tests = [
            ("(def a 8)", "8"),
            ("`[1 a 3]", "(1 a 3)"),
            // TODO: fix this
            //;;;;=>[1 a 3]
        ]
        runTests(tests)
    }

    func testSpliceUnquoteWithVectors() {
        let tests = [
            ("(def c '(1 \"b\" \"d\"))", "(1 \"b\" \"d\")"),
            ("`[1 ~@c 3]", "(1 1 \"b\" \"d\" 3)"),
            //;;; TODO: fix this
            //;;;;=>[1 1 "b" "d" 3]
        ]
        runTests(tests)
    }

    func runTests(_ tests: [(String, String)]) {
        for (input, expected) in tests {
            do {
                let result = try readEvalAndPrint(input)
                XCTAssertEqual(result, expected)
            }
            catch let error as CocoaLispError {
                XCTAssertEqual(error.message, expected)
            }
            catch {
                XCTFail("\(input) != \(expected): \(error)")
            }
        }
    }

}
