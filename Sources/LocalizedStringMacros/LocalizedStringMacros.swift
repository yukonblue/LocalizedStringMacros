@freestanding(expression)
public macro memberPath<T>(_ value: T) -> String = #externalMacro(
    module: "LocalizedStringMacrosMacros",
    type: "MemberPathMacro"
)
