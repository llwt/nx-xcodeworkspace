//
//  ContentView.swift
//  AppTwo
//
//  Created by Steven Nance on 06/11/2024!
//

import SwiftUI
import LibTwo

struct ContentView: View {
    @State private var people = LibTwoPeople(firstPersonName: "Bar", secondPersonName: "Baz")

    var body: some View {
        VStack {
            HStack {
                Image(systemName: "moon")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                Text("App Two")
            }
            .padding()

            people.NamesView
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
