//
//  ContentView.swift
//  ChatSample
//
//  Created by  유 주연 on 10/23/24.
//

import SwiftUI

struct ContentView: View {
  @State private var chatContent: String = ""
  @State private var shouldScrollToBottom: Bool = false
  @State private var isFetchingMore: Bool = false
  @State private var chatContents: [Chat] = []
  
  let fetchCount: Int = 50
  var body: some View {
    VStack {
      ScrollViewReader { scrollViewProxy in
        List {
          GeometryReader { geometry in
            Color.clear.onAppear {
              if geometry.frame(in: .global).minY > 0 {
                fetchMoreChats(scrollViewProxy: scrollViewProxy, geometry: geometry)
              }
            }
          }
          .frame(height: 1)
          ForEach(chatContents) { chat in
            HStack(alignment: .top) {
              if chatContents.firstIndex(where: { $0.id == chat.id })! % 2 == 0 {
                Image(systemName: "person.circle")
                Text(chat.content)
              } else {
                Spacer()
                Text(chat.content)
              }
            }
            .id(chat.id)
          }
        }
        
        .onChange(of: chatContent, {
          scrollToLast(scrollViewProxy: scrollViewProxy, useAnimation: true)
        })
        .onAppear(perform: {
          fetchChat()
          shouldScrollToBottom = true
          scrollToLast(scrollViewProxy: scrollViewProxy, useAnimation: false)
          
        })
      }
      
      TextEditor(text: $chatContent)
        .frame(height: 100)
      HStack {
        Image.init(systemName: "photo")
        Spacer()
        Button(action: {
          chatContents.append(.init(content: chatContent))
          shouldScrollToBottom = true
          chatContent = ""
        }, label: {
          Text("전송")
        })
      }
    }
    .padding()
    
  }
  
  private func scrollToLast(scrollViewProxy: ScrollViewProxy, useAnimation: Bool) {
    if shouldScrollToBottom, let lastChatId = chatContents.last?.id {
      DispatchQueue.main.async {
        if useAnimation {
          withAnimation {
            scrollViewProxy.scrollTo(lastChatId, anchor: .bottom)
          }
        } else {
          scrollViewProxy.scrollTo(lastChatId, anchor: .bottom)
        }
        
        shouldScrollToBottom = false
        isFetchingMore = false
      }
    }
  }
  
  
  private func fetchChat() {
    isFetchingMore = true
    for i in chatContents.count ..< chatContents.count + fetchCount {
      chatContents.insert(.init(content: "test\(i)"), at: 0)
    }
  }
  private func fetchMoreChats(scrollViewProxy: ScrollViewProxy, geometry: GeometryProxy) {
    guard !isFetchingMore else { return }
    isFetchingMore = true
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
      for i in chatContents.count ..< chatContents.count + fetchCount {
        chatContents.insert(.init(content: "이전 메시지\(i)"), at: 0)
      }
      
      DispatchQueue.main.async {
        scrollViewProxy.scrollTo(chatContents[fetchCount].id, anchor: .center)
        isFetchingMore = false
      }
    }
  }
}

#Preview {
  ContentView()
}


struct Chat: Identifiable, Equatable {
  var id: UUID = UUID()
  let content: String
}
