////
////  Carousel.swift
////
////  Created by Abdullah Kardaş on 12.03.2023.
////
//
//import SwiftUI
//
//import SwiftUI
//import Combine
//
//
//struct Carousel<Content:View>: View {
//    
//    @State private var snappedItem = 0.0
//    @State private var draggingItem = 0.0
//    @State var activeIndex: Int = 0
//    let items:[MusicFileEntity]
//    
//    let content:(MusicFileEntity) -> Content
//
//    
//    init(items:[MusicFileEntity],duration:Double, @ViewBuilder content: @escaping (MusicFileEntity) -> Content) {
//        self.items = items
//        self.content = content
//    }
//    
//   
//    var body: some View {
//            ZStack {
//                ForEach(items) { item in
//                    RoundedRectangle(cornerRadius: 16)
//                        .shadow(color: .black, radius: items.firstIndex(of:item) == activeIndex ? 8:4,y:items.firstIndex(of:item) == activeIndex ? 8:0)
//                        .overlay(content: {
//                            content(item)
//                        })
//                        .frame(width: UIScreen.main.bounds.width - 50, height: UIScreen.main.bounds.height / 2.5)
//                    .scaleEffect(1.0 - abs(distance(item.id)) * 0.28)
//                    .opacity(1.0 - abs(distance(item.id)) * 0.05 )
//                    .offset(x: myXOffset(item.id), y: 0)
//                    .zIndex(1.0 - abs(distance(item.id)) * 0.1).animation(.spring(), value: item.id)
//                    
//                }
//            }
//            .gesture(
//                DragGesture()
//                    .onChanged { value in
//                        draggingItem = snappedItem + value.translation.width / 300
//                        print("\(draggingItem) -- \(snappedItem)")
//                    }
//                    .onEnded { value in
//                        withAnimation {
//                            draggingItem = snappedItem + value.predictedEndTranslation.width / 300
//                            draggingItem = round(draggingItem).remainder(dividingBy: Double(items.count))
//                            snappedItem = draggingItem
//
//                            //Get the active Item index
//                            self.activeIndex = items.count + Int(draggingItem)
//                            if self.activeIndex > items.count || Int(draggingItem) >= 0 {
//                                self.activeIndex = Int(draggingItem)
//                            }
//                            
//                        }
//                    }
//            )
//    }
//    
//    func distance(_ item: Int) -> Double {
//    
//        return (draggingItem + Double(item)).remainder(dividingBy: Double(items.count))
//    }
//    
//    func myXOffset(_ item: Int) -> Double {
//        let angle = Double.pi * 2 / Double(items.count) * distance(item)
//        return sin(angle) * 200
//    }
//}
//
//struct Carousel_Previews: PreviewProvider {
//   
//    static var previews: some View {
//                        Carousel(items: [MusicFileEntity]) { item in
//                            item.image
//        }
//
//    }
//}
