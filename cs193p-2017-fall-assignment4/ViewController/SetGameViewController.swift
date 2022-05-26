//
//  ViewController.swift
//  cs193p-2017-fall-assignment4
//
//  Created by Ksenia Surikova on 25.02.2022.
//

import UIKit

class SetGameViewController: UIViewController {
    
    static let delayToDrop = 2.0
    static let delayBetweenCards = 0.5
    
    private var game: SetGame!
    
    @IBOutlet var containerView: UIView!
   
    @IBOutlet weak var scoreLabel: UILabel!
    
    @IBOutlet weak var deckView: DeckView!{
        didSet {
                        let tap = UITapGestureRecognizer(
                            target: self,
                            action: #selector(tapDeck))
                        tap.numberOfTapsRequired = 1
                        tap.numberOfTouchesRequired = 1
                        deckView.addGestureRecognizer(tap)
                    }
    }

    @IBOutlet weak var dropView: DeckView!{
        didSet {
            dropView.alpha = 0
        }
    }
    @IBOutlet weak var setCountLabel: UILabel! {
        didSet {
            try! updateSetCountLabel()
        }
    }
    
    private var deckCenter: CGPoint {
        return containerView.convert(deckView.center, to: setCardsView)
    }
    
    private var dropCenter: CGPoint {
        return containerView.convert(dropView.center, to: setCardsView)
    }
    
    @IBOutlet weak var setCardsView: SetCardAreaView! {
        didSet {
            getReadyToStart()
        }
    }
    
    var tmpCards = [SetCardView]()
    var droppedCards = [SetCardView]()
    
    //     MARK: Dynamic Animator
    lazy var animator = UIDynamicAnimator(referenceView: setCardsView)
    lazy var cardBehavior = CardBehavior(in: animator)
    
    
    @objc func tapDeck() {
        game.dealCards()
        addToDeal()
        dealCards()
        try! updateSetCountLabel()
        updateDealCardsButtonState()
    }
    
    //     MARK:    ViewController lifecycle methods
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // animate first cards dealing
        dealCards()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        droppedCards.forEach {
            $0.center = dropCenter
        }
    }

    @IBAction func playAgain(_ sender: UIButton) {
        clearDrop()
        getReadyToStart()
        // animate first cards dealing
        dealCards()
        updateScore()
        try! updateSetCountLabel()
        updateDealCardsButtonState()
    }
    
    private func clearDrop(){
        droppedCards.forEach{$0.removeFromSuperview()}
        droppedCards.removeAll()
    }
    
    private func getReadyToStart(){
        game = SetGame()
        resetCardViews()
    }
    
    private func resetCardViews(){
        setCardsView.cardViews = getCardViewsForCards(game.cardsOnView)
    }
    
    private func addToDeal() {
        setCardsView.addCardViews(getCardViewsForCards(game.cardsJustDeal))
    }
    
    private func getCardViewsForCards(_ cards:[SetCard]) -> [SetCardView]
    {
        var newCardViews = [SetCardView]()
        for i in 0..<cards.count {
             let button = SetCardView(with: cards[i])
             button.alpha = 0.0
             addTapGestureRecognizer(for: button)
            newCardViews.append(button)
         }
        return newCardViews
    }
    
    private func addTapGestureRecognizer(for cardView: SetCardView) {
        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(tapCard(recognizedBy: )))
        tap.numberOfTapsRequired = 1
        tap.numberOfTouchesRequired = 1
        cardView.addGestureRecognizer(tap)
    }
    
    @objc private func tapCard(recognizedBy recognizer: UITapGestureRecognizer) throws {
        if recognizer.state == .ended {
            if  let cardView = recognizer.view! as? SetCardView {
                try game.chooseCard(card: cardView.card)
                updateCardViewsFromModel()
                updateScore()
                try updateSetCountLabel()
                updateDealCardsButtonState()
            }
        }
    }

    private func updateDealCardsButtonState(){
        deckView.isHidden = !game.canDealMoreCards()
    }
    
    private func updateSetCountLabel() throws {
        let setsCount = try game.getCountSetsOnView()
        setCountLabel.text = "Sets on view: \(setsCount)"
    }
    
    private func updateScore()
    {
        scoreLabel.text = "Score: \(game.score)"
    }
    
    private func updateCardViewsFromModel(){
        // mismatch or select, or deal cards by tap
        if game.cardsRemoved.isEmpty {
            // add cards to deal board
            addToDeal()
            // set mismatch border
            if game.cardsChosen.count == SetGame.cardsToDealAndCheckCount {
                setCardsView.cardViews.filter{ game.cardsChosen.contains($0.card)}.forEach {
                    $0.isMatched = false
                }
            }
            // else set selected border or deselect
            else {
                setCardsView.cardViews.filter{ game.cardsChangedSelection.contains($0.card)}.forEach {
                    $0.isSelected =  !$0.isSelected
                }
                // set select border for already mismatched card, but chose again
                if game.cardsChangedSelection.count > SetGame.cardsToDealAndCheckCount {
                    setCardsView.cardViews.filter{ game.cardsChosen.contains($0.card)}.forEach {
                        $0.isSelected =  true
                    }
                }
            }
        }
        // match
        else {
            // do push and collide removed card views
            let changedCards = setCardsView.cardViews.filter{ game.cardsRemoved.contains($0.card)}
            for index in 0..<changedCards.count {
                moveCardToCollide(changedCards[index])
            }
            
            // if there are not card to deal, remove old card views from board
            if game.cardsJustDeal.isEmpty {
                setCardsView.removeCardViews(changedCards)
            }
            // there are cards to deal, so change removed to deal
            else {
                for index in 0..<changedCards.count {
                    // we append new dealed cards at the end of cardsOnView array, so we can find it there
                    changedCards[index].card = game.cardsJustDeal[index]
                    changedCards[index].isSelected = false
                    changedCards[index].alpha = 0.0
                }
            }
        }
        dealCards()
        if (tmpCards.count == SetGame.cardsToDealAndCheckCount){
            dropCards()
        }
    }
    
    private func moveCardToCollide(_ card: SetCardView){
        let newCard = SetCardView(with: card.card)
        newCard.isMatched = true
        newCard.frame = card.frame
        setCardsView.addSubview(newCard)
        tmpCards.append(newCard)
        cardBehavior.addItem(newCard)
    }
    
    //MARK: animation
    private func dealCards(){
        var delay: TimeInterval = 0.0
        for hiddenCard in setCardsView.cardViews.filter({$0.alpha == 0.0}){
            hiddenCard.dealAndFlip(from: deckCenter, width: deckView.calcAspectWidth, height: deckView.calcAspectHeight, with: delay)
            delay += SetGameViewController.delayBetweenCards
        }
    }

    private func dropCards() {
        Timer.scheduledTimer(withTimeInterval: SetGameViewController.delayToDrop, repeats: false) { [self] (timer) in
            var delay = 0.0
            for droppedCard in self.tmpCards {
                droppedCard.notifyCardIsDropped = { [weak self] in  self?.droppedCards.append(droppedCard)}
                self.cardBehavior.removeItem(droppedCard)
                droppedCard.dropAndFaceDown(to: self.dropCenter, width: self.deckView.calcAspectWidth, height: self.deckView.calcAspectHeight, with: delay)
                delay += SetGameViewController.delayBetweenCards
            }
            tmpCards.removeAll()
        }
    }
    
    
}



