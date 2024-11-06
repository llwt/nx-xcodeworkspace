//
//  Person.swift
//  LibTwo
//
//  Created by Steven Nance on 06/11/2024.
//

import SwiftUI
import LibOne

public struct LibTwoPeople {
    public var firstPerson: LibOnePerson
    public var secondPerson: LibOnePerson
    
    public var NamesView: AnyView {
        AnyView(VStack(alignment: .leading) {
            Text("Lib Two People: ")
            Text("   1. " + firstPerson.fullName)
            Text("   2. " + secondPerson.fullName)
        })
    }
    
    public init(firstPersonName: String, secondPersonName: String) {
        self.firstPerson = LibOnePerson(name: firstPersonName, age: 10)
        self.secondPerson = LibOnePerson(name: secondPersonName, age: 12)
    }
}
