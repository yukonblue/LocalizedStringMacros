//
//  LocalizedStringMacrosInterface.swift
//  LocalizedStringMacrosInterface
//
//  Created by yukonblue on 2025-11-07.
//

@freestanding(expression)
public macro memberPath<T>(_ value: T) -> String = #externalMacro(
    module: "LocalizedStringMacros",
    type: "MemberPathMacro"
)
