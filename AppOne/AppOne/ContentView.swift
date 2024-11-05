//
//  ContentView.swift
//  AppOne
//
//  Created by Steven Nance on 05/11/2024.
//

import SwiftUI
import LibOne

struct ContentView: View {
    @State private var person = LibOnePerson(name: "Foo", age: 31)
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                Text("App One")
            }
            .padding()
            
            Text("Hello, " + person.fullName + "!")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
