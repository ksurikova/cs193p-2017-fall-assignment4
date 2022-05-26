//
//  SetCard.swift
//  cs193p-2017-fall-assignment4
//
//  Created by Ksenia Surikova on 25.02.2022.
//

import Foundation

struct SetCard : Equatable, CustomStringConvertible {

    private(set) var firstSign: Sign
    private(set) var secondSign: Sign
    private(set) var thirdSign: Sign
    private(set) var fourthSign: Sign
    
    init (_ firstSign: Sign, _ secondSign: Sign, _ thirdSign: Sign , _ fourthSign: Sign){
        self.firstSign = firstSign
        self.secondSign = secondSign
        self.thirdSign = thirdSign
        self.fourthSign = fourthSign
    }
    
    var description: String {
        return "\(firstSign)\(secondSign)\(thirdSign)\(fourthSign)"
    }
    
    static func == (lhs: SetCard, rhs: SetCard) -> Bool {
        return
            lhs.firstSign == rhs.firstSign && lhs.secondSign == rhs.secondSign && lhs.thirdSign == rhs.thirdSign && lhs.fourthSign == rhs.fourthSign
    }
    
    static func isSet(cardsToCheck: [SetCard]) throws  -> Bool {
        guard cardsToCheck.count == SetGame.cardsToDealAndCheckCount else {throw SetCardError.invalidCountOfCardsToCheckSet}
      let signsSum = [
        cardsToCheck.reduce(0, {$0 + $1.firstSign.rawValue}),
        cardsToCheck.reduce(0, {$0 + $1.secondSign.rawValue}),
        cardsToCheck.reduce(0, {$0 + $1.thirdSign.rawValue}),
        cardsToCheck.reduce(0, {$0 + $1.fourthSign.rawValue})
      ]
       return signsSum.reduce(true, {$0 && ($1 % 3 == 0)})
    }
}

enum  SetCardError: Error {
    case invalidCountOfCardsToCheckSet
}

enum Sign : Int, CaseIterable, CustomStringConvertible {
    case a = 1
    case b
    case c
    
    var i: Int {return (self.rawValue - 1)}
    
    var description: String {
       get {
         switch self {
           case .a:
             return "a"
           case .b:
             return "b"
           case .c:
             return "c"
         }
       }
    }
}

