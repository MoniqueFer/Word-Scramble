//
//  ContentView.swift
//  Word Scramble
//
//  Created by Monique Ferrarini on 12/03/25.
//

import SwiftUI

struct ContentView: View {
	
	@State private var usedWords = [String]()
	@State private var newWord = ""
	@State private var rootWord = ""
	@State private var score = 0
	
	@State private var errorTitle = ""
	@State private var  errorMessage = ""
	@State private var showingError = false
	
		
    var body: some View {
        
		NavigationStack{
			
			List {
				
				Section {
					TextField("Enter your word", text: $newWord)
						.textInputAutocapitalization(.never)
					
					HStack {
						Text("Score:")
						Text("\(score)")
					}
				}
				
				
				
				Section {
					ForEach (usedWords, id: \.self ) { word in
						HStack {
							Image(systemName: "\(word.count).circle")
							Text(word)

						}
						
					}
				}
				
			}
			.navigationTitle(rootWord)
			.onSubmit (addNewWord)
			.onAppear(perform: startGame)
			.alert(errorTitle, isPresented: $showingError) {
				Button("OK") {}
			} message: {
				Text(errorMessage)
			}
			
			.toolbar {
				Button("Restart", action: startGame)
			}
			
		}
    } 
	
	func addNewWord() {
		let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
		
		guard answer.count >= 3 else {
			wordError(title: "Too short!", message: "We want at least 3 letters!")
			return }
		
		guard isOriginal(word: answer) else {
			wordError(title: "Word used already!" , message: "Choose another")
			return
		}
		guard isPossible(word: answer) else {
			wordError(title: "World not possible", message: "You can't speel that word from '\(rootWord)'!")
			return
		}
		
		guard isReal(word: answer) else {
			wordError(title: "Word not recognized", message: "You can't just make them up!")
			return
		}
		
		guard answer != rootWord else {
			wordError(title: "Same word!", message: "You cant use the same word we give you!")
			return
		}
		
		
		withAnimation {
			usedWords.insert(answer, at: 0)
		}
		score = score + 1
		newWord = ""
	}
	
	func startGame() {
		//try to load the start.text
		if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
			// if this works, try to load the file into a string
			if let startWords = try?String(contentsOf: startWordsURL, encoding: .utf8 ) {
				// if this works, get the string and transforms it into a array, the itens are divide by line break
				let allWords = startWords.components(separatedBy: "\n")
				
				//then get one word random and put it on rootword
				rootWord = allWords.randomElement() ?? "silkworm"
				return
				
			}
		}
		
		//if everything fails, throw a fatal error
		fatalError("Could not load the file start.txt")
		
	}
	
	func isOriginal(word: String) -> Bool {
		!usedWords.contains(word)
	}
	
	func isPossible(word: String) -> Bool {
		var tempWord = rootWord
		
		for letter in word {
			if let possible = tempWord.firstIndex(of: letter) {
				tempWord.remove(at: possible)
			} else {
				return false
			}
		}
		return true
	}
	
	func isReal(word: String) -> Bool {
		let checker = UITextChecker()
		let range = NSRange(location: 0, length: word.utf16.count)
		let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")

		return misspelledRange.location == NSNotFound

	}
	
	func wordError(title: String, message: String) {
		errorTitle = title
		errorMessage = message
		showingError = true
	}
	
}

#Preview {
    ContentView()
}
