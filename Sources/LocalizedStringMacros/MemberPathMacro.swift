//
//  MemberPathMacro.swift
//  LocalizedStringMacros
//
//  Created by yukonblue on 2025-11-07.
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct MemberPathMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> ExprSyntax {
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
        } else if let identifier = expr.as(DeclReferenceExprSyntax.self) {
            return identifier.baseName.text
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
                components.insert(funcDecl.name.text, at: 0)
            case .variableDecl(let varDecl):
                if let name = varDecl.bindings.first?.pattern
                    .as(IdentifierPatternSyntax.self)?.identifier.text
                {
                    components.insert(name, at: 0)
                }
            case .enumDecl(let enumDecl):
                components.insert(enumDecl.name.text, at: 0)
            case .structDecl(let structDecl):
                components.insert(structDecl.name.text, at: 0)
            case .classDecl(let classDecl):
                components.insert(classDecl.name.text, at: 0)
            case .extensionDecl(let extDecl):
                if let type = extDecl.extendedType.as(
                    IdentifierTypeSyntax.self
                ) {
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

@main
struct LocalizedStringMacrosPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        MemberPathMacro.self,
    ]
}
