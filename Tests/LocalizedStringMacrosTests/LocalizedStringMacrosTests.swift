import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(LocalizedStringMacros)
import LocalizedStringMacros

let testMacros: [String: Macro.Type] = [
    "memberPath": MemberPathMacro.self,
]
#endif

final class LocalizedStringMacrosTests: XCTestCase {
    func testMacro() throws {
        #if canImport(LocalizedStringMacrosMacros)
        assertMacroExpansion(
            """
            enum Localization {
              enum App {
                 static var jaja: String {
                   #memberPath(Localization.App.jaja)
                 }
              }
            }
            """,
            expandedSource:
            """
            enum Localization {
              enum App {
                 static var jaja: String {
                   Localization.App.jaja
                 }
              }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
