//
//  File.swift
//  LocalizedStringMacros
//
//  Created by Y on 2025-11-07.
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros


public struct MemberPathMacro: ExpressionMacro {
    public static func expansion(of node: some SwiftSyntax.FreestandingMacroExpansionSyntax, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> SwiftSyntax.ExprSyntax {

//        // Find where this macro is called
//        guard let parentDecl = node.enclosingDecl() else {
//            return "\"<unknown>\""
//        }
//
//        // Compute dotted path
//        let path = computeQualifiedName(for: parentDecl)
//
//        // Return a string literal expression
//        return ExprSyntax(stringLiteral: path)

        // Get the expression passed into the macro
        guard let argument = node.arguments.first?.expression else {
                    throw MacroExpansionErrorMessage("Expected one argument")
                }

                // Use syntax tree to reconstruct the full dotted path
                let path = extractMemberPath(from: argument)

        
                // Return it as a string literal expression
                return ExprSyntax(stringLiteral: path)
    }

    private static func extractMemberPath(from expr: ExprSyntax) -> String {
            if let memberAccess = expr.as(MemberAccessExprSyntax.self) {
                // Recursively build the path: Base.Member
                let base = memberAccess.base.map { extractMemberPath(from: $0) + "." } ?? ""
                return base + memberAccess.declName.baseName.text
            } else if let identifier = expr.as(IdentifierExprSyntax.self) {
                return identifier.identifier.text
            } else {
                return expr.description
            }
        }

    // MARK: - Helpers

    /// Compute dotted path like App.Level1.myFunction
    private static func computeQualifiedName(for node: DeclSyntax) -> String {
        var components: [String] = []

        var current: Syntax? = Syntax(node)
        while let syntax = current {
            switch syntax.as(SyntaxEnum.self) {
            case .functionDecl(let funcDecl):
                components.insert(funcDecl.identifier.text, at: 0)
            case .variableDecl(let varDecl):
                if let name = varDecl.bindings.first?.pattern.as(IdentifierPatternSyntax.self)?.identifier.text {
                    components.insert(name, at: 0)
                }
            case .enumDecl(let enumDecl):
                components.insert(enumDecl.identifier.text, at: 0)
            case .structDecl(let structDecl):
                components.insert(structDecl.identifier.text, at: 0)
            case .classDecl(let classDecl):
                components.insert(classDecl.identifier.text, at: 0)
            case .extensionDecl(let extDecl):
                if let type = extDecl.extendedType.as(SimpleTypeIdentifierSyntax.self) {
                    components.insert(type.name.text, at: 0)
                }
            default:
                break
            }
            current = syntax.parent
        }

        return components.joined(separator: ".")
    }
}

// MARK: - Syntax helper

private extension SyntaxProtocol {
    /// Walk upward until we find the nearest enclosing declaration
    var parentDeclSyntax: DeclSyntax? {
        var current = self.parent
        while let c = current {
            if let decl = c.as(DeclSyntax.self) {
                return decl
            }
            current = c.parent
        }
        return nil
    }

    func enclosingDecl() -> DeclSyntax? {
            var current: Syntax? = Syntax(self)
            while let node = current {
                if let decl = node.as(DeclSyntax.self) {
                    return decl
                }
                current = node.parent
            }
            return nil
        }
}

@main
struct LocalizedStringMacrosPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        MemberPathMacro.self,
    ]
}
