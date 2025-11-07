import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

struct MacroExpansionError: Error {
    let message: String
    init(_ message: String) {
        self.message = message
    }
}

public struct AutoLocalizedMacro: AccessorMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {
//        guard let enumDecl = declaration.as(EnumDeclSyntax.self) else {
//                    fatalError("Expected an enum declaration")
//                }
//
//                guard let propertyDecl = enumDecl.memberBlock.members.first?.decl.as(VariableDeclSyntax.self) else {
//                    fatalError("Expected a property declaration")
//                }
//
//        guard let attributeName = propertyDecl.as(AttributeSyntax.self)?.attributeName else {
//            fatalError("Cannot determine attribute name")
//        }

        guard let VariableDeclSyntax = declaration.as(VariableDeclSyntax.self) else {
            fatalError("Expected a property declaration")
        }

        let attributeName = "jaja"

        // Extract arguments: value and comment
        guard let argumentList: SyntaxChildren = node.arguments?.children(
            viewMode: .sourceAccurate
        ) else {
            throw MacroExpansionError("@AutoLocalized requires 'value' and 'comment'")
        }

        guard let commentArg = argumentList.first(where: {
            guard let labelExprSyntax = $0.as(LabeledExprSyntax.self) else {
                return false
            }
            return labelExprSyntax.label?.text == "comment"
        })?.as(LabeledExprSyntax.self) else {
            throw MacroExpansionError("@AutoLocalized requires 'comment' argument")
        }

        let comment: String
        if let stringLiteralExprSyntax = commentArg.expression.as(StringLiteralExprSyntax.self) {
            comment = stringLiteralExprSyntax.segments.map { $0.description }.joined(separator: "")
        } else {
            comment = ""
        }

        guard let valueArg = argumentList.first(where: {
            guard let labelExprSyntax = $0.as(LabeledExprSyntax.self) else {
                return false
            }
            return labelExprSyntax.label?.text == "value"
        })?.as(LabeledExprSyntax.self) else {
            throw MacroExpansionError("@AutoLocalized requires 'value' argument")
        }

        let value: String
        if let stringLiteralExprSyntax = valueArg.expression.as(StringLiteralExprSyntax.self) {
            value = stringLiteralExprSyntax.segments.map { $0.description }.joined(separator: "")
        } else {
            value = ""
        }

        // Get the full dotted name path (e.g., Localization.App.appName)
        let key = makeQualifiedName(for: declaration)

        // Build the accessor body
//        let accessor: AccessorDeclSyntax = """
//        get {
//            NSLocalizedString("\(raw: key)", bundle: .main, value: \(raw: value), comment: \(raw: comment))
//        }
//        """
//
//        return [accessor]

        return [
            AccessorDeclSyntax("""
                   static var \(raw: attributeName): String {
                       NSLocalizedString(key: "\(raw: key)", bundle: .main, value: "\(raw: value)", comment: "\(raw: comment)")
                   }
                   """)
               ]
    }

    private static func makeQualifiedName(for decl: some DeclSyntaxProtocol) -> String {
        // Walk up through parent scopes collecting names
        var components: [String] = []

        var current: Syntax? = Syntax(decl)
        while let node = current {
            if let varDecl = node.as(VariableDeclSyntax.self),
               let name = varDecl.bindings.first?.pattern.as(IdentifierPatternSyntax.self)?.identifier.text {
                components.insert(name, at: 0)
            } else if let enumDecl = node.as(EnumDeclSyntax.self) {
                components.insert(enumDecl.name.text, at: 0)
            }
//            else if let structDecl = node.as(StructDeclSyntax.self) {
//                components.insert(structDecl.identifier.text, at: 0)
//            }
            current = node.parent
        }

        return components.joined(separator: ".")
    }
}


//@main
//struct LocalizedStringMacrosPlugin: CompilerPlugin {
//    let providingMacros: [Macro.Type] = [
//        AutoLocalizedMacro.self,
//    ]
//}
