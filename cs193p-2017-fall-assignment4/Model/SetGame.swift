//
//  SetGame.swift
//  cs193p-2017-fall-assignment4
//
//  Created by Ksenia Surikova on 25.02.2022.
//

import Foundation

struct SetGame {
    
    static let startFacedUpCardsCount = 12
    static let cardsToDealAndCheckCount = 3
    static let setQuessPoint = 5
    static let setNoQuessPenaltyPoint = 3
    static let removeChoisePenaltyPoint = 1
    
    private(set) var deck = [SetCard]()
    private(set) var cardsChosen = [SetCard]()
    private(set) var cardsOnView = [SetCard]()
    private(set) var cardsRemoved = [SetCard]()
    private(set) var cardsJustDeal = [SetCard]()
    private(set) var cardsChangedSelection = [SetCard]()
    private(set) var score = 0
    
    private func getDeck() -> [SetCard] {
        var deck = [SetCard]()
        for i in Sign.allCases {
            for j in Sign.allCases {
                for k in Sign.allCases {
                    for l in Sign.allCases {
                        let card = SetCard(i,j,k,l)
                        deck.append(card)
                    }
                }
            }
        }
        return deck.shuffled()
    }
    
    init (){
        deck = getDeck()
        for _ in 0..<SetGame.startFacedUpCardsCount {
            cardsOnView.append(deck.removeFirst())
        }
    }
    
    func canDealMoreCards(countToDeal : Int = SetGame.cardsToDealAndCheckCount) -> Bool {
        return deck.count >= countToDeal
    }

    mutating func dealCards()
    {
        cardsJustDeal = [SetCard]()
        if canDealMoreCards()
        {
            for _ in 0..<SetGame.cardsToDealAndCheckCount {
                cardsJustDeal.append(deck.removeFirst())
            }
            cardsOnView.append(contentsOf: cardsJustDeal)
        }
    }
    
    private mutating func clearCardsState() {
        cardsChangedSelection.removeAll()
        cardsJustDeal.removeAll()
        cardsRemoved.removeAll()
    }

    mutating func chooseCard(card: SetCard) throws {
        guard cardsOnView.contains(card) else {return }
        clearCardsState()
        switch cardsChosen.count {
        case 0..<SetGame.cardsToDealAndCheckCount-1:
            cardsChangedSelection.append(card)
            let wasAppend = cardsChosen.appendOrRemoveIfContains(card)
            if !wasAppend { score = score-SetGame.removeChoisePenaltyPoint }
        case SetGame.cardsToDealAndCheckCount-1:
            let wasAppend = cardsChosen.appendOrRemoveIfContains(card)
            if !wasAppend {
                score = score-SetGame.removeChoisePenaltyPoint
                cardsChangedSelection.append(card)
            }
            else {
                let setHappens = try SetCard.isSet(cardsToCheck: cardsChosen)
                score = setHappens ? score+SetGame.setQuessPoint: score-SetGame.setNoQuessPenaltyPoint
                if setHappens {
                    for element in cardsChosen {
                        cardsRemoved.append(element)
                        _ = cardsOnView.removeIfContains(element)
                    }
                    cardsChosen.removeAll()
                    cardsChangedSelection.append(contentsOf: cardsChosen)
                    dealCards()
                }
                else {
                    cardsChangedSelection.append(card)
                }
            }
            
        case SetGame.cardsToDealAndCheckCount:
            cardsChangedSelection.append(contentsOf: cardsChosen)
            cardsChangedSelection.append(card)
            cardsChosen.removeAll()
            cardsChosen.append(card)
            //else do nothing
        default:
            break
        }
    }
    
    func getCountSetsOnView()  throws -> Int{
        var count = 0
        guard cardsOnView.count > 3 else { return count }
        for index1 in 0...cardsOnView.count - 3 {
            for index2 in (index1+1)...cardsOnView.count - 2 {
                for index3 in (index2+1)...cardsOnView.count - 1 {
                    if try SetCard.isSet(cardsToCheck: [cardsOnView[index1], cardsOnView[index2], cardsOnView[index3]]){
                    count+=1
                    }
                }
            }
        }
        return count
    }
}

extension Array where Element : Equatable {
    mutating func removeIfContains(_ element: Element) -> Bool{
        if let index = self.firstIndex(of: element) {
            self.remove(at: index)
            return true
        }
        else {
            return false
        }
    }
    
    
    mutating func appendOrRemoveIfContains(_ element: Element) -> Bool{
        if removeIfContains(element) {
            return false
        }
        else {
            self.append(element)
            return true
        }
    }
}
