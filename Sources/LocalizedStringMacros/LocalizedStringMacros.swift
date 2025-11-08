@freestanding(declaration)
public macro memberPath<T>(_ value: T) = #externalMacro(
    module: "LocalizedStringMacrosMacros",
    type: "MemberPathMacro"
)
