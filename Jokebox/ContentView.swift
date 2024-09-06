//
//  ContentView.swift
//  Jokebox (formerly Jokester)
//
//  Created by Sohum Berry on 6/7/23.
//

import SwiftUI

let screenSize = UIScreen.main.bounds
let screenWidth = screenSize.width
let screenHeight = screenSize.height

class HapticManager {
    static let instance = HapticManager()
    
    func notification(type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
    func impact(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
    func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
}


// MARK: ContentView
struct ContentView: View {
    @State var response: String = ""
    @State var selector: Int = 0
    @State var favorited: Bool = false
    @State var item: FavoriteItem = FavoriteItem(prompt: "", joke: "", jokeType: "")
    @State var favorites: [FavoriteItem] = []
//    @State var favorites: [FavoriteItem] = [FavoriteItem(prompt: "Prompt", joke: "Hahahaahahaha, this is super funny", jokeType: "Dad Joke")]
    @State var showLike: Bool = false
    @State var showDislike: Bool = false
    
    func fetch() {
        if let data = UserDefaults.standard.data(forKey: "SavedData") {
            if let decoded = try? JSONDecoder().decode([FavoriteItem].self, from: data) {
                print("fetching...")
                favorites = decoded
                return
            }
        }
        favorites = []
    }
    
    func save() {
        if let encoded = try? JSONEncoder().encode(favorites) {
            UserDefaults.standard.set(encoded, forKey: "SavedData")
        }
    }
    
    var body: some View {
        ZStack {
            Group {
                TabView(selection: $selector) {
                    Group {
                        SmileView(joke: $response, favorited: $favorited, item: $item, showLike: $showLike, showDislike: $showDislike, favorites: $favorites)
                            .tabItem {
                                Label("Jokes", systemImage: "face.smiling")
//                                    .padding(.top, 10)
                            }
                            .tag(0)
                            .onAppear() {
                                fetch()
                            }
                            
                        FavoritesView(favorites: $favorites)
                            .tabItem {
                                Label("Favorites", systemImage: "heart")
//                                    .padding(.top, 10)
                            }
                            .tag(1)
                    }
                    .toolbarBackground(.visible, for: .tabBar)
                    .toolbarBackground(Color.theme.black, for: .tabBar)
                }
                .onChange(of:   favorites.count) { _ in
                    save()
                    print("saving...")
                }
            }
            .ignoresSafeArea(.keyboard)
            
            VStack {
                Spacer()
                if showLike {
                    notification(message: "Joke has been added to favorites", size: 17)
                        .padding(.bottom, -7)
                    let _ = Timer.scheduledTimer(withTimeInterval: 1.3, repeats: false) { (timer) in
                        withAnimation {
                            showLike = false
                        }
                    }
                }
                if showDislike {
                    notification(message: "Joke has been removed from favorites", size: 15)
                        .padding(.bottom, -7)
                    let _ = Timer.scheduledTimer(withTimeInterval: 1.3, repeats: false) { (timer) in
                        withAnimation {
                            showDislike = false
                        }
                    }
                }
            }
        }
    }
}


////MARK: Favorites
struct FavoriteItem: Identifiable, Codable {
    var id = UUID()
    let prompt: String
    var joke: String
    let jokeType: String
}

struct FavoriteItemView: View {
    @State var prompt: String
    @State var joke: String
    var body: some View {
        Text("\(joke)")
            .frame(width: screenWidth * 0.85)
            .font(Font.custom("Orbit-Regular", size: 24))
            .multilineTextAlignment(.center)
            .minimumScaleFactor(0.35)
            .foregroundColor(Color.theme.fg)
            .textSelection(.enabled)
            .padding(.top, 40)
            .padding(.bottom, 30)
            .padding(.horizontal, 20)
            .background(Color.theme.black)
            .cornerRadius(16)
            .frame(width: screenWidth * 0.94)
    }
}
// MARK: FavoritesView
struct FavoritesView: View {
//    @Binding var favorites: [FavoriteItem]
    @Binding var favorites: [FavoriteItem]
    @State var stillFav: Bool = true
    @State var showHelp: Bool = false
    
    var body: some View {
        let logo_width: CGFloat = screenWidth * 0.85
        let logo_height: CGFloat = logo_width * 0.7
        ZStack {
            Color.theme.bg
                .ignoresSafeArea()
            VStack {
                Image("logo")
                    .resizable()
                    .frame(width: logo_width, height: logo_height)
                    .padding(.top, 10)
                    .padding(.bottom, 50)
                    .overlay(alignment: .bottom) {
                        Text(favorites.isEmpty ? "" : "Favorites")
                            .padding(.bottom, 10)
                            .font(Font.custom("Orbit-Regular", size: 20))
                            .foregroundColor(Color.theme.black)
                    }
                Spacer()
                if favorites.isEmpty {
                    VStack {
                        Text("Your liked jokes will appear here")
                            .font(Font.custom("Staatliches-Regular", size: 31))
                            .foregroundColor(Color.theme.fg)
                            .multilineTextAlignment(.center)
                            .lineSpacing(13)
                            .padding(.horizontal, 20)
                            .padding(.top, 70)
                        Spacer()
                    }
                    Spacer()
                    VStack(spacing: 0) {
                        Spacer()
                        HStack {
                            Text("Powered by OpenAI")
                                .padding(.leading, 20)
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                            Spacer()
                            Text("Created by Sohum Berry")
                                .padding(.trailing, 20)
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                        }
                        .padding(.bottom, 20)
                        .foregroundColor(Color.theme.gray)
                        .font(Font.custom("Orbit-Regular", size: 14))
                        Rectangle()
                            .fill(Color.clear)
                            .frame(height: 0.5)
                            .background(Color.theme.fg)
                    }
                    .ignoresSafeArea(.keyboard, edges: .bottom)
                } else {
                    ScrollView(showsIndicators: true) {
                        VStack (spacing: 10) {
                            ForEach(favorites) { item in
                                FavoriteItemView(prompt: item.prompt, joke: item.joke)
                                    .overlay(alignment: .topTrailing) {
                                        Image(systemName: "heart.fill")
                                            .padding(.trailing, 25)
                                            .padding(.top, 20)
                                            .foregroundColor(Color.theme.fg)
                                            .font(.system(size: 20))
                                            .onTapGesture {
                                                withAnimation {
                                                    favorites.removeAll { value in
                                                        return value.id == item.id
                                                    }
                                                }
                                                HapticManager.instance.impact(style: .light)
                                            }
                                    }
                                    .padding(.bottom, 5)
                            }
                        }
                    }
                }
            }
            VStack {
                HStack {
                    Spacer()
                    Image(systemName: "questionmark.circle")
                        .padding(.trailing, 20)
                        .foregroundColor(Color.theme.fg)
                        .font(.system(size: 45))
                        .onTapGesture {
                            withAnimation {
                                showHelp = true
                            }
                        }
                }
                Spacer()
                VStack(spacing: 0) {
                    Spacer()
                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: 0.5)
                        .background(Color.theme.fg)
                }
                .ignoresSafeArea(.keyboard, edges: .bottom)
            }
            if showHelp {
                ZStack(alignment: .center) {
                    Rectangle()
                        .frame(width: screenWidth, height: screenHeight)
                        .edgesIgnoringSafeArea(.all)
                        .background(Color.theme.bg)
                        .opacity(0.001)
                        .layoutPriority(-1)
                        .onTapGesture {
                            withAnimation {
                                showHelp = false
                            }
                        }
                    
                    HelpView()
                }
            }
        }
    }
}

struct SmileView: View {
    @State var showHelp: Bool = false
    @State var generated: Bool = false
    @State var prompt: String = ""
    @State var jokeType: String = ""
    @State var response: String = ""
    @Binding var joke: String
    @Binding var favorited: Bool
    @Binding var item: FavoriteItem
    @Binding var showLike: Bool
    @Binding var showDislike: Bool
    @Binding var favorites: [FavoriteItem]
    
    var body: some View {
        let logo_width: CGFloat = screenWidth * 0.85
        let logo_height: CGFloat = logo_width * 0.7
        ZStack {
            Color.theme.bg
                .ignoresSafeArea()
            if generated {
                LinearGradient(stops: ([.init(color: Color.theme.light_gray, location: 0),
                                        .init(color: Color.theme.bg, location: 0.056)]), startPoint: .leading, endPoint: .trailing)
                                    .edgesIgnoringSafeArea(.all)
            }
            VStack {
                // MARK: Title Logo
                VStack {
                    Image("logo")
                        .resizable()
                        .frame(width: logo_width, height: logo_height)
                        .padding(.top, 10)
                        .padding(.bottom, 50)
                        .onTapGesture {
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                }
                .ignoresSafeArea(.keyboard)
                
                ZStack {
                    if generated {
                        JokeView(prompt: prompt, joke: response, jokeType: jokeType, generated: $generated, favorited: favorited, showLike: $showLike, showDislike: $showDislike, favorites: $favorites, item: $item)
                            .gesture(DragGesture(minimumDistance: 20, coordinateSpace: .global)
                                        .onEnded { value in
                                            let horizontalAmount = value.translation.width
                                            let verticalAmount = value.translation.height
                                            
                                            if abs(horizontalAmount) > abs(verticalAmount) && horizontalAmount > 0 {
                                                withAnimation {
                                                    generated = false
                                                }
                                            }
                                        })
                    }
                    // MARK: Input View
                    else {
                        InputView(response: $response, generated: $generated, prompt: $prompt, jokeTypeSend: $jokeType)
                            .minimumScaleFactor(0.8)
                    }
                }
                Spacer()
            }
            
            VStack {
                HStack {
                    if generated {
                        Image(systemName: "arrow.left")
                            .padding(.leading, 20)
                            .foregroundColor(Color.theme.fg)
                            .font(.system(size: 40))
                            .onTapGesture {
                                withAnimation {
                                    generated = false
                                }
                            }
                    }
                    Spacer()
                    Image(systemName: "questionmark.circle")
                        .padding(.trailing, 20)
                        .foregroundColor(Color.theme.fg)
                        .font(.system(size: 45))
                        .onTapGesture {
                            withAnimation {
                                showHelp = true
                            }
                        }
                }
                Spacer()
                VStack(spacing: 0) {
                    Spacer()
                    HStack {
                        Text("Powered by OpenAI")
                            .padding(.leading, 20)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                        Spacer()
                        Text("Created by Sohum Berry")
                            .padding(.trailing, 20)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                    .padding(.bottom, 20)
                    .foregroundColor(Color.theme.gray)
                    .font(Font.custom("Orbit-Regular", size: 14))
                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: 0.5)
                        .background(Color.theme.fg)
                }
                .ignoresSafeArea(.keyboard, edges: .bottom)
                
            }
            if showHelp {
                ZStack(alignment: .center) {
                    Rectangle()
                        .frame(width: screenWidth, height: screenHeight)
                        .edgesIgnoringSafeArea(.all)
                        .background(Color.theme.bg)
                        .opacity(0.001)
                        .layoutPriority(-1)
                        .onTapGesture {
                            withAnimation {
                                showHelp = false
                            }
                        }
                    
                    HelpView()
                }
            }
        }
        
    }
}

// MARK: Joke List
// List for each type of joke
struct ListItem: Identifiable {
    let id = UUID()
    let text: String
    let request: String
    
    static let preview: [ListItem] = [
        ListItem(text: "Puns", request: "pun"),
        ListItem(text: "Smooth Talk", request: "pickup lines"),
        ListItem(text: "Dad Jokes", request: "dad joke"),
        ListItem(text: "Sarcasm", request: "sarcastic joke"),
        ListItem(text: "Knock-Knock Jokes", request: "knock-knock joke"),
        ListItem(text: "One-Liners", request: "one liner joke")
    ]
}



// MARK: InputView
// The view to ask the user for an input, this view returns the DaVinci-003 result along with a bool signaling that the joke has been generated
struct InputView: View {
    let connector = OpenAIConnector()
    @State var jokeType: ListItem = ListItem(text: "Puns", request: "pun")
    @State var situation: String = ""
    // The two @Binding variables provide the values of the OpenAI generation and a bool
    @Binding var response: String
    @Binding var generated: Bool
    @Binding var prompt: String
    @Binding var jokeTypeSend: String
    
    enum ButtonState {
        case empty
        case idle
        case loading
        case badword
    }
    
    @State var currentButtonState: ButtonState = .idle
    // Declaring constant for width of the text field and it's background
    let width: CGFloat = screenWidth * 0.88
    
    var body: some View {
        VStack(alignment: .center) {
            // MARK: Text Field
            TextField("", text: $situation, prompt: Text("What's the situation?")
                .foregroundColor(Color.theme.fg_dull)
                .font(Font.custom("Orbit-Regular", size: 19)),
                        axis: .horizontal
            )
            .onChange(of: situation) { newValue in
                            if situation.count > 125 {
                                situation = String(situation.prefix(125))
                                HapticManager.instance.impact(style: .soft)
                            }
                        }
            .font(Font.custom("Orbit-Regular", size: 19))
            .multilineTextAlignment(.center)
            .frame(width: width, height: 50)
            .foregroundColor(Color.theme.fg)
            .background(Color.background)
            .cornerRadius(6)
            .shadow(color: Color.darkShadow, radius: 5, x: 2, y: 2)
            .shadow(color: Color.lightShadow, radius: 4, x: -2, y: -2)
            .padding(.bottom, 10)
            .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(.gray, lineWidth: 0.65)
                        .padding(.bottom, 10)
                )
                        
            // MARK: Joke Selection
            ScrollView(.horizontal, showsIndicators: false) {
                HStack (spacing: 10) {
                    // For each item in the list of jokes....
                    ForEach(ListItem.preview) { item in
                        // Create a text view of each item with a button-like background
                        Text(item.text)
                            .multilineTextAlignment(.center)
                            .minimumScaleFactor(0.5)
                            .font(Font.custom("Orbit-Regular", size: 19.2))
                            .frame(height: 42)
                            .padding(.horizontal)
                            .foregroundColor(Color.theme.fg)
                            // Highlight the selected option
                            .background(item.request == jokeType.request ? Color.gray : Color.theme.bg)
                            .cornerRadius(20)
                            // When tapped, set the jokeType to the request value of the item so that it can be formatted into the OpenAI prompt
                            .onTapGesture {
                                withAnimation {
                                    // If the item clicked isn't the same value of the jokeType...^
                                    if item.request != jokeType.request {
                                        jokeType = item
                                    }
                                }
                                HapticManager.instance.impact(style: .soft)
                            }
                    }
                }
            }
            .shadow(color: Color.darkShadow, radius: 5, x: 2, y: 2)
            .shadow(color: Color.lightShadow, radius: 3, x: -2, y: -2)
            .padding(.bottom, 20)
            .padding(.horizontal, 30)
            
            // MARK: Generation Button
            switch currentButtonState {
            case .empty:
                ButtonView(text: "Provide a situation", bgcolor: Color.theme.black, fgcolor: Color.theme.fg_dull, height: 90)
                let _ = Timer.scheduledTimer(withTimeInterval: 1.8, repeats: false) { (timer) in
                    withAnimation {
                        currentButtonState = .idle
                    }
                }

            case .idle:
                ButtonView(text: "Generate Joke", bgcolor: Color.theme.black, fgcolor: Color.theme.fg, height: 90)
                    .onTapGesture {
                        if situation != "" {
                            if containsSwearWord(text: situation) {
                                print("Thats a potty word")
                                withAnimation {
                                    currentButtonState = .badword
                                }
                                HapticManager.instance.notification(type: .error)
                            }
                            else {
                                // If generated is false AND the text view isn't empty....
                                if !generated && situation != "" {
                                    currentButtonState = .loading
                                    prompt = situation
                                    jokeTypeSend = jokeType.text
                                    // Create the prompt based on the situation and the type of joke
                                    var prompt_string = situation + ". Give me a " + jokeType.request + " specifically for this situation. Take your time and remember to breathe. I'll tip you if you make me laugh. Keep it short and sweet, less than 30 words."
                                    Task {
                                        HapticManager.instance.notification(type: .success)
                                        // Delay the function call for a fraction of a second so the screen can update to loading before generating
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                                            // Set generated to true and generate the response from the OpenAI Connector with the prompt, reutrning a random hardcoded joke if null is recieved
                                            if prompt_string.suffix(1) == " " {
                                                prompt_string = String(prompt_string.dropLast())
                                            }
                                            response = connector.processPrompt(prompt: prompt_string) ?? "Uh oh! Something went wrong. You'll have to work with this one:\n\n" + Constants.BackupJokes.randomElement()!
                                            if response == "nil" {
                                                response = "Uh oh! Something went wrong. You'll have to work with this one:\n\n" + Constants.BackupJokes.randomElement()!
                                            }
                                            // Content filtering
                                            if containsSwearWord(text: response) {
                                                response = "Uh oh! This joke had some potty words. You'll have to do with this one:\n\n" + Constants.BackupJokes.randomElement()!
                                            }
                                            withAnimation {
                                                generated = true
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        else {
                            withAnimation {
                                currentButtonState = .empty
                            }
                            HapticManager.instance.notification(type: .error)
                        }
                    }
            case .loading:
                ButtonView(text: "Loading...", bgcolor: Color.theme.black, fgcolor: Color.theme.fg, height: 90)
            case .badword:
                ButtonView(text: "No Naughty Words", bgcolor: Color.theme.black, fgcolor: Color.theme.fg_dull, height: 90)
                let _ = Timer.scheduledTimer(withTimeInterval: 1.8, repeats: false) { (timer) in
                    withAnimation {
                        currentButtonState = .idle
                    }
                }
            }
        }
    }
}

// MARK: Button View
struct ButtonView: View {
    @State var text: String
    @State var bgcolor: Color
    @State var fgcolor: Color
    @State var height: CGFloat
    var body: some View {
        Group {
            Rectangle()
                .fill(Color.clear)
                .frame(maxWidth: screenWidth * 0.7, maxHeight: height)
                .background(bgcolor)
                .cornerRadius(12)
                .shadow(color: Color.darkShadow, radius: 2)
                .overlay {
                    Text(text)
                        .font(Font.custom("Staatliches-Regular", size: 30))
                        .multilineTextAlignment(.center)
                        .fontWeight(.semibold)
                        .lineSpacing(10)
                        .frame(width: screenWidth * 0.55)
                        .minimumScaleFactor(0.7)
                        .foregroundColor(fgcolor)
            }
        }
        .ignoresSafeArea(.keyboard)
    }
}

// MARK: HelpView
struct HelpView: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 20)
            .frame(width: screenWidth * 0.85, height: screenHeight * 0.7)
            .foregroundColor(Color.gray)
            .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.theme.fg, lineWidth: 4)
                )
            .opacity(0.96)
            .overlay(alignment: .center) {
                Text("Jokebox uses OpenAI's API to generate a joke that is intended to be relevant to your situation. It works best with a specific input like \"I am struggling with my physics homework\"\n\n You can select a type of joke, but it will not be 100% accurate.\n\nThe jokes may not be as good as mine ;)")
                    .font(Font.custom("Orbit-Regular", size: 20))
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.5)
                    .padding(.horizontal, 22)
                    .padding(.top, -20)
                    .foregroundColor(Color.theme.black)
            }
    }
}

// MARK: JokeView
// Display the inputted joke from the input view along with a button to go back to the input view
struct JokeView: View {
    let connector = OpenAIConnector()
    @State var prompt: String
    @State var joke: String
    @State var full_joke = ""
    @State var jokeType: String
    @Binding var generated: Bool
    @State var favorited: Bool = false
    @Binding var showLike: Bool
    @Binding var showDislike: Bool
    @Binding var favorites: [FavoriteItem]
    @Binding var item: FavoriteItem
    @State var loading_joke: String = ""
    @State var reloaded: Bool = false
    @State var reload_count: Int = 0
    @State var showNotification: Bool = false
    
    
    enum RegenButtonState {
        case idle
        case loading
        case limit
    }
    
    @State var buttonState: RegenButtonState = .idle
    
    var body: some View {
        ZStack {
            VStack {
                Text(reloaded ? loading_joke: full_joke)
                    .font(Font.custom("Orbit-Regular", size: 28))
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.35)
                    .padding(.bottom, 50)
                    .padding(.horizontal)
                    .foregroundColor(Color.theme.fg)
                    .textSelection(.enabled)
                
                Spacer()
                
                HStack(spacing: 15) {
                    Spacer()
                    ShareLink(item: "https://apps.apple.com/us/app/jokebox/id6455461445\"" + (reloaded ? loading_joke: full_joke) + "\"\n-Jokebox", preview: SharePreview(prompt, image: "AppIcon"))
                        .labelStyle(.iconOnly)
                        .padding(.bottom, screenHeight * 0.08)
                        .foregroundColor(Color.theme.black)
                    Spacer()
                    
                    switch buttonState {
                    case .idle:
                        ButtonView(text: "Regenerate", bgcolor: Color.theme.fg, fgcolor: Color.theme.black, height: 70)
                            .padding(.bottom, screenHeight * 0.08)
                            .onTapGesture {
                                if prompt != "" {
                                    reload_count += 1
                                    showNotification = reload_count >= 4
                                    if reload_count < 3 {
                                        HapticManager.instance.notification(type: .success)
                                        buttonState = .loading
                                        
                                        Task {
                                            HapticManager.instance.notification(type: .success)
                                            // Delay the function call for a fraction of a second so the screen can update to loading before generating
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                                                // Set generated to true and generate the response from the OpenAI Connector with the prompt, reutrning a random hardcoded joke if null is recieved
                                                loading_joke = connector.processPrompt(prompt: prompt + " Make certain the new joke is different than " + full_joke) ?? "Uh oh! Something went wrong. You'll have to work with this one:\n\n" + Constants.BackupJokes.randomElement()!
                                                if loading_joke == "nil" {
                                                    loading_joke = "Uh oh! Something went wrong. You'll have to work with this one:\n\n" + Constants.BackupJokes.randomElement()!
                                                }
                                                // Content filtering
                                                if containsSwearWord(text: loading_joke) {
                                                    loading_joke = "Uh oh! This joke had some potty words. You'll have to do with this one:\n\n" + Constants.BackupJokes.randomElement()!
                                                }
                                                withAnimation {
                                                    buttonState = .idle
                                                    reloaded = true
                                                }
                                            }
                                        }
                                    }
                                    else {
                                        withAnimation() {
                                            buttonState = .limit
                                        }
                                        
                                    }
                                    favorited = false
                                }
                            }
                    case .limit:
                        ButtonView(text: "Limit", bgcolor: Color.theme.black, fgcolor: Color.theme.fg_dull, height: 70)
                            .padding(.bottom, screenHeight * 0.08)
                    case .loading:
                        ButtonView(text: "Loading...", bgcolor: Color.theme.black, fgcolor: Color.theme.fg, height: 70)
                            .padding(.bottom, screenHeight * 0.08)
                    }
                    Spacer()
                    Image(systemName: favorited ? "heart.fill" : "heart")
                        .padding(.bottom, screenHeight * 0.08)
                        .foregroundColor(Color.theme.black)
                        .onTapGesture {
                            if favorited == false {
                                HapticManager.instance.notification(type: .success)
                                if joke.prefix(upTo: joke.index(joke.startIndex, offsetBy: 6)) == "Uh oh!" {
                                    joke = String(joke.dropFirst(65))
                                }
                                item = FavoriteItem(prompt: prompt, joke: reloaded ? loading_joke : joke, jokeType: jokeType)
                                favorites.insert(item, at: 0)
                                
                                withAnimation {
                                    favorited = true
                                    showLike = true
                                }
                            } else {
                                HapticManager.instance.notification(type: .warning)
                                withAnimation {
                                    favorites.removeAll { value in
                                        return value.id == item.id
                                    }
                                    favorited = false
                                    showDislike = true
                                }
                            }
                        }
                    Spacer()
                }
                .padding(.horizontal, 10)
            }
            .onChange(of: favorites.count) { newValue in
                if favorites.contains(where: { FavoriteItem in
                    return FavoriteItem.id == item.id
                }) {
                    favorited = true
                } else {
                    favorited = false
                }
            }
            .onAppear() {
                full_joke = joke
            }
        }
    }
}

struct notification: View {
    let message: String
    let size: CGFloat
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .foregroundColor(Color.theme.black)
                .frame(width: screenWidth, height: 55)
            Text(message)
                .foregroundColor(Color.theme.fg)
                .font(Font.custom("Orbit-Regular", size: size))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
