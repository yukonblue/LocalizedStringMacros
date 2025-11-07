// The Swift Programming Language
// https://docs.swift.org/swift-book

//@attached(accessor)
//public macro AutoLocalized(value: String, comment: String) = #externalMacro(
//    module: "LocalizedStringMacrosMacros",
//    type: "AutoLocalizedMacro"
//)

@freestanding(expression)
public macro qualifiedPath() -> String = #externalMacro(
    module: "LocalizedStringMacrosMacros",
    type: "QualifiedPathMacro"
)
