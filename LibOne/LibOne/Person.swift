//
//  Person.swift
//  LibOne
//
//  Created by Steven Nance on 05/11/2024.
//

public struct LibOnePerson {
    public var name: String
    public var age: Int
    public var lastName: String
    public private(set) var dateCreated: Date
    
    public var fullName: String {
        "Lib One: " + (lastName.isEmpty ? name : name + " " + lastName)
    }
    
    public init(name: String, lastName: String = "", age: Int) {
        self.name = name
        self.lastName = lastName
        self.age = age
        self.dateCreated = Date.now
    }
}
