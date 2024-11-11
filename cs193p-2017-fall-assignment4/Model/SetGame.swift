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
    private(set) var isTestMode = false

    private func getDeck() -> [SetCard] {
        var deck = [SetCard]()
        for i in Sign.allCases {
            for j in Sign.allCases {
                for k in Sign.allCases {
                    for l in Sign.allCases {
                        let card = SetCard(i, j, k, l)
                        deck.append(card)
                    }
                }
            }
        }
        return deck.shuffled()
    }

    init () {
        deck = getDeck()
        for _ in 0..<Self.startFacedUpCardsCount {
            cardsOnView.append(deck.removeFirst())
        }
    }

    func canDealMoreCards(countToDeal: Int = Self.cardsToDealAndCheckCount) -> Bool {
        deck.count >= countToDeal
    }

    mutating func toggleTestMode() {
        isTestMode = !isTestMode
        clearCardsState()
        if cardsChosen.count == Self.cardsToDealAndCheckCount {
            // change points because we turn on test mode, so right now we add set matching points and remove penalty points
            if isTestMode {
                score = score + Self.setQuessPoint + Self.setNoQuessPenaltyPoint
                matchAndDealCardsWhenSetHappens()
            }
        }
    }

    mutating func dealCards() {
        cardsJustDeal = [SetCard]()
        if canDealMoreCards() {
            for _ in 0..<Self.cardsToDealAndCheckCount {
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
        case 0..<Self.cardsToDealAndCheckCount-1:
            cardsChangedSelection.append(card)
            let wasAppend = cardsChosen.appendOrRemoveIfContains(card)
            if !wasAppend { score -= Self.removeChoisePenaltyPoint }
        case Self.cardsToDealAndCheckCount-1:
            let wasAppend = cardsChosen.appendOrRemoveIfContains(card)
            if !wasAppend {
                score -= Self.removeChoisePenaltyPoint
                cardsChangedSelection.append(card)
            } else {
                let setHappens = isTestMode ? true : try SetCard.isSet(cardsToCheck: cardsChosen)
                score = setHappens ? score+Self.setQuessPoint: score-Self.setNoQuessPenaltyPoint
                if setHappens {
                    matchAndDealCardsWhenSetHappens()
                } else {
                    cardsChangedSelection.append(card)
                }
            }

        case Self.cardsToDealAndCheckCount:
            cardsChangedSelection.append(contentsOf: cardsChosen)
            cardsChangedSelection.append(card)
            cardsChosen.removeAll()
            cardsChosen.append(card)
            // else do nothing
        default:
            break
        }
    }

    private mutating func matchAndDealCardsWhenSetHappens() {
        for element in cardsChosen {
            cardsRemoved.append(element)
            _ = cardsOnView.removeIfContains(element)
        }
        cardsChosen.removeAll()
        cardsChangedSelection.append(contentsOf: cardsChosen)
        dealCards()
    }
}

extension Array where Element: Equatable {
    mutating func removeIfContains(_ element: Element) -> Bool {
        if let index = self.firstIndex(of: element) {
            self.remove(at: index)
            return true
        } else {
            return false
        }
    }

    mutating func appendOrRemoveIfContains(_ element: Element) -> Bool {
        if removeIfContains(element) {
            return false
        } else {
            self.append(element)
            return true
        }
    }
}
