//
//  ContentView.swift
//  Jokester
//
//  Created by Sohum Berry on 6/7/23.
//

import SwiftUI

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
    
    var body: some View {
        ZStack {
            Group {
                
                TabView(selection: $selector) {
                    Group {
                        SmileView(joke: $response, favorited: $favorited, item: $item, showLike: $showLike, showDislike: $showDislike, favorites: $favorites)
                            .tabItem {
                                Label("Jokes", systemImage: "face.smiling")
                                    .padding(.top, 5)
                            }
                            .tag(0)
                            .onChange(of: favorited) { _ in
                                if favorited == true {
                                    favorites.append(item)
                                }
                                else {
                                    favorites.removeAll { value in
                                        return value.id == item.id
                                    }
                                }
                            }
                        FavoritesView(favorites: $favorites)
                            .tabItem {
                                Label("Favorites", systemImage: "heart")
                                    .padding(.top, 5)
                            }
                            .tag(1)
                    }
                    .toolbarBackground(.visible, for: .tabBar)
                    .toolbarBackground(Color.theme.black, for: .tabBar)
                    
                }
            }
            .ignoresSafeArea(.keyboard)
            
            VStack {
                Spacer()
                if showLike {
                    favoriteConfirm(isLiking: true)
                        .padding(.bottom, -7)
                    let _ = Timer.scheduledTimer(withTimeInterval: 1.3, repeats: false) { (timer) in
                        withAnimation {
                            showLike = false
                        }
                    }
                }
                if showDislike {
                    favoriteConfirm(isLiking: false)
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
//MARK: Favorites
struct FavoriteItem: Identifiable {
    let id = UUID()
    let prompt: String
    var joke: String
    let jokeType: String
}

struct FavoriteItemView: View {
    @State var prompt: String
    @State var joke: String
    var body: some View {
        Text("\(joke)")
            .frame(width: UIScreen.main.bounds.width * 0.85)
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
            .frame(width: UIScreen.main.bounds.width * 0.94)
    }
}
// MARK: FavoritesView
struct FavoritesView: View {
    @Binding var favorites: [FavoriteItem]
    @State var stillFav: Bool = true
    @State var showHelp: Bool = false
    
    var body: some View {
        let logo_width: CGFloat = UIScreen.main.bounds.width * 0.85
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
                            .font(Font.custom("PressStart2P-Regular", size: 31))
                            .foregroundColor(Color.theme.fg)
                            .multilineTextAlignment(.center)
                            .lineSpacing(13)
                            .padding(.horizontal, 20)
                            .padding(.top, 70)
                        Spacer()
                    }
                    Spacer()
                } else {
                    ScrollView(showsIndicators: true) {
                        VStack (spacing: 15) {
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
                                            }
                                    }
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
//                    Rectangle()
//                        .fill(Color.clear)
//                        .frame(height: 13)
//                        .background(Color.theme.black)
                }
                .ignoresSafeArea(.keyboard, edges: .bottom)
            }
            if showHelp {
                ZStack(alignment: .center) {
                    Rectangle()
                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
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
        let logo_width: CGFloat = UIScreen.main.bounds.width * 0.85
        let logo_height: CGFloat = logo_width * 0.7
        ZStack {
            Color.theme.bg
                .ignoresSafeArea()
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
//                            .onAppear() {
//                                if response.prefix(upTo: response.index(response.startIndex, offsetBy: 6)) == "Uh oh!" {
//                                    print("has uh oh!")
//                                    joke = String(response.dropFirst(65))
//                                }
//                                item = FavoriteItem(prompt: prompt, joke: joke, jokeType: jokeType)
//                            }
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
                        
                        Spacer()
                        Text("Created by Sohum Berry")
                            .padding(.trailing, 20)
                    }
                    .padding(.bottom, 20)
                    .foregroundColor(Color.theme.gray)
                    .font(Font.custom("Orbit-Regular", size: 14))
                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: 0.5)
                        .background(Color.theme.fg)
//                    Rectangle()
//                        .fill(Color.clear)
//                        .frame(height: 13)
//                        .background(Color.theme.black)
                }
                .ignoresSafeArea(.keyboard, edges: .bottom)
                
            }
            if showHelp {
                ZStack(alignment: .center) {
                    Rectangle()
                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
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
        ListItem(text: "Dad Jokes", request: "dad joke"),
        ListItem(text: "Puns", request: "pun"),
        ListItem(text: "Knock-Knock Jokes", request: "knock-knock joke"),
        ListItem(text: "One-Liners", request: "one liner joke")
    ]
}

// MARK: InputView
// The view to ask the user for an input, this view returns the DaVinci-003 result along with a bool signaling that the joke has been generated
struct InputView: View {
    let connector = OpenAIConnector()
    @State var jokeType: ListItem = ListItem(text: "Dad Jokes", request: "dad joke")
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
    
    // Hard coded backup jokes in case the generation fails
    let backupJokes: [String] = [
        "What does a tick and the Eiffel Tower have in common?\n\nThey're both Paris sites.",
        "What did the janitor say when he jumped out of the closet?\n\nSupplies!",
        "Why do seagulls fly over the ocean?\nBecause if they flew over the bay, we'd call them bagels.",
        "How does the moon cut his hair?\n\nEclipse it.",
        "Why couldn't the bicycle stand up by itself?\n\nIt was two tired",
        "What time did the man go to the dentist?\n\nTooth hurt-y.",
        "I used to be addicted to soap, but I'm clean now.",
        "I ordered a chicken and an egg from Amazon. I'll let you know...",
        "Did you hear about the guy who invented the knock-knock joke?\nHe won the 'no-bell' prize.",
        "What do you call a belt made of watches?\n\nA waist of time.",
        "Why do we tell actors to break a leg? Because every play has a cast.",
        "Did you hear about the guy who lost his left side? He's all right now.",
        "How does an octopus go into battle? Well-armed.",
        "I tried to catch fog yesterday. Mist.",
        // My personal favorite
        "When does a joke become a dad joke?\n\nWhen it becomes apparent!"
    ]
    // Declaring constant for width of the text field and it's background
    let width: CGFloat = UIScreen.main.bounds.width * 0.88
    
    var body: some View {
        VStack(alignment: .center) {
            // MARK: Text Field
            TextField("", text: $situation, prompt: Text("What's the situation?")
                .foregroundColor(Color.theme.fg_dull)
                .font(Font.custom("Orbit-Regular", size: 19)),
                        axis: .horizontal
            )
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
//                                HapticManager.instance.impact(style: .soft)
                            }
                    }
                }
//                        .frame(minWidth: geometry.size.width)
//                        .frame(width: geometry.size.width, height: geometry.size.height)
            }
//                    .frame(width: geometry.size.width, height: 42)
            .shadow(color: Color.darkShadow, radius: 5, x: 2, y: 2)
            .shadow(color: Color.lightShadow, radius: 3, x: -2, y: -2)
            .padding(.bottom, 20)
            .padding(.horizontal, 30)
            
            // MARK: Generation Button
            switch currentButtonState {
            case .empty:
                ButtonView(text: "Input a Situation", bgcolor: Color.theme.black, fgcolor: Color.theme.fg_dull, height: 90)
                let _ = Timer.scheduledTimer(withTimeInterval: 1.8, repeats: false) { (timer) in
                    withAnimation {
                        currentButtonState = .idle
                    }
                }

            case .idle:
                ButtonView(text: "Generate Joke", bgcolor: Color.theme.black, fgcolor: Color.theme.fg, height: 90)
                    .onTapGesture {
                        if containsSwearWord(text: situation) {
                            print("Thats a potty word")
                            withAnimation {
                                currentButtonState = .badword
                            }
//                            HapticManager.instance.notification(type: .warning)
                        }
                        else {
                            // If generated is false AND the text view isn't empty....
                            if !generated && situation != "" {
                                currentButtonState = .loading
                                prompt = situation
                                jokeTypeSend = jokeType.text
                                // Create the prompt based on the situation and the type of joke
                                let prompt_string = situation + ". Give me a " + jokeType.request + " specifically for this situation."
                                Task {
//                                    HapticManager.instance.notification(type: .success)
                                    // Delay the function call for a fraction of a second so the screen can update to loading before generating
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                                        // Set generated to true and generate the response from the OpenAI Connector with the prompt, reutrning a random hardcoded joke if null is recieved
                                        response = connector.processPrompt(prompt: prompt_string) ?? "Uh oh! Something went wrong. You'll have to work with this one:\n\n" + backupJokes.randomElement()!
                                        if response == "nil" {
                                            response = "Uh oh! Something went wrong. You'll have to work with this one:\n\n" + backupJokes.randomElement()!
                                        }
                                        // Content filtering
                                        if containsSwearWord(text: response) {
                                            response = "Uh oh! This joke had some potty words. You'll have to do with this one:\n\n" + backupJokes.randomElement()!
                                        }
                                        withAnimation {
                                            generated = true
                                        }
                                    }
                                }
                            }
                            else {
                                withAnimation {
                                    currentButtonState = .empty
                                }
//                                HapticManager.instance.notification(type: .warning)
                            }
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
        Rectangle()
            .fill(Color.clear)
            .frame(maxWidth: UIScreen.main.bounds.width * 0.7, maxHeight: height)
            .background(bgcolor)
            .cornerRadius(12)
            .shadow(color: Color.darkShadow, radius: 2)
            .overlay {
                Text(text)
                    .font(Font.custom("PressStart2P-Regular", size: 18))
                    .multilineTextAlignment(.center)
                    .fontWeight(.semibold)
                    .lineSpacing(10)
                    .frame(width: UIScreen.main.bounds.width * 0.55)
                    .minimumScaleFactor(0.7)
                    .foregroundColor(fgcolor)
            }
    }
}

// MARK: HelpView
struct HelpView: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 20)
            .frame(width: UIScreen.main.bounds.width * 0.85, height: UIScreen.main.bounds.height * 0.7)
            .foregroundColor(Color.gray)
            .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.theme.fg, lineWidth: 4)
                )
            .opacity(0.96)
            .overlay(alignment: .center) {
                Text("Jokebox uses OpenAI's API to generate a joke that is intended to be relevant to your situation. It works best with a specific input like \"I am struggling with my physics homework\"\n\n You can select a type of joke, but it will not be 100% accurate.\n\nNOTE:\nThe jokes may not be as good as mine ;)")
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
//    @State var joke: String
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
    
    var body: some View {
        VStack {
            Text(full_joke)
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
                ShareLink(item: joke, preview: SharePreview("Jokebox", image: "AppIcon"))
                    .labelStyle(.iconOnly)
                    .padding(.bottom, UIScreen.main.bounds.height * 0.08)
                    .foregroundColor(Color.theme.black)
                Spacer()
                ButtonView(text: "New Prompt", bgcolor: Color.theme.fg, fgcolor: Color.theme.black, height: 70)
                    .padding(.bottom, UIScreen.main.bounds.height * 0.08)
                    .onTapGesture {
                        withAnimation {
                            generated = false
                        }
                }
                Spacer()
                Image(systemName: favorited ? "heart.fill" : "heart")
                    .padding(.bottom, UIScreen.main.bounds.height * 0.08)
                    .foregroundColor(Color.theme.black)
                    .onTapGesture {
                        if favorited == false {
                            if joke.prefix(upTo: joke.index(joke.startIndex, offsetBy: 6)) == "Uh oh!" {
                                    print("has uh oh!")
                                    joke = String(joke.dropFirst(65))
                                }
                            item = FavoriteItem(prompt: prompt, joke: joke, jokeType: jokeType)
                            favorites.append(item)
                            withAnimation {
                                favorited = true
                                showLike = true
                            }
                        } else {
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


struct favoriteConfirm: View {
    @State var isLiking: Bool
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .foregroundColor(Color.theme.black)
                .frame(width: UIScreen.main.bounds.width, height: 55)
            Text(isLiking ? "Joke has been added to favorites" : "Joke has been removed from favorites")
                .foregroundColor(Color.theme.fg)
                .font(Font.custom("Orbit-Regular", size: isLiking ? 17 : 15))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
