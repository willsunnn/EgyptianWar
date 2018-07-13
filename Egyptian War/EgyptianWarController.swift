//
//  ViewController.swift
//  Egyptian War
//
//  Created by william sun on 7/3/18.
//  Copyright © 2018 w|e.vxtn. All rights reserved.
//

import UIKit
import AVFoundation

class EgyptianWarViewController: UIViewController, AnimationDelegate {
    
    //MARK: IBOutlet Variables
    
    // the card back picture, card count label, and the turn indicator
    @IBOutlet weak var player1Controls: UIStackView!
    @IBOutlet weak var player2Controls: UIStackView!
    // the card back picture, and the card count label
    @IBOutlet weak var player1CardStack: UIStackView!
    @IBOutlet weak var player2CardStack: UIStackView!
    // the card count label
    @IBOutlet weak var player1CardCount: UILabel!
    @IBOutlet weak var player2CardCount: UILabel!
    // the card count back
    @IBOutlet weak var player1CardBack: UIImageView!
    @IBOutlet weak var player2CardBack: UIImageView!
    // the turn indicator
    @IBOutlet weak var player1TurnIndicator: UIButton!
    @IBOutlet weak var player2TurnIndicator: UIButton!
    
    // the center stack custom view
    @IBOutlet weak var centerStackView: CardStackView!
    
    //MARK: Game Variables
    var game: GameLogic!
    
    //MARK: UIViewController Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        newGame()
        
        // rotates the 2nd players control view by pi radians
        player2Controls.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
        
        // adds swiping gesture recognizers to centerStackView so that it can move the stack when done
        let centerSwipePlayer1Recognizer = UISwipeGestureRecognizer(target: self, action: #selector(player1Claim))
        centerSwipePlayer1Recognizer.direction = .down
        
        let centerSwipePlayer2Recognizer = UISwipeGestureRecognizer(target: self, action: #selector(player2Claim))
        centerSwipePlayer2Recognizer.direction = .up
        
        centerStackView.addGestureRecognizer(centerSwipePlayer1Recognizer)
        centerStackView.addGestureRecognizer(centerSwipePlayer2Recognizer)
        
        centerStackView.isUserInteractionEnabled = true
        
        // add gesture recognizers to the player stacks so that it will deal
        let player1DealRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(player1Deal))
        player1DealRecognizer.direction = .up
        player1CardStack.addGestureRecognizer(player1DealRecognizer)
        player1CardStack.isUserInteractionEnabled = true
        
        let player2DealRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(player2Deal))
        player2DealRecognizer.direction = .up
        player2CardStack.addGestureRecognizer(player2DealRecognizer)
        player2CardStack.isUserInteractionEnabled = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Deal Functions
    @objc func player1Deal() {
        playerDeal(playerNum: 1)
    }
    
    @objc func player2Deal() {
        playerDeal(playerNum: 2)
    }
    
    func playerDeal(playerNum: Int){
        game.playerDeal(playerNum: playerNum)
        checkLoss()
    }
    
    //MARK: Slap Functions
    @IBAction func player1Slap(_ sender: Any) {
        playerSlap(playerNum: 1)
    }
    
    @IBAction func player2Slap(_ sender: Any) {
        playerSlap(playerNum: 2)
    }
    
    func playerSlap(playerNum: Int) {
        game.playerSlap(playerNum: playerNum)
        checkLoss()
    }
    
    //MARK: Claim Functions
    @objc func player1Claim() {
        claimedBy(playerNum: 1)
    }
    
    @objc func player2Claim() {
        claimedBy(playerNum: 2)
    }
    
    func claimedBy(playerNum: Int) {
        if( playerNum == game.playerToWinDeck) {
            game.claimDeck()
        }
    }
    
    //MARK: Update State Functions
    func updateView() {
        updateCardCounts()
        updatePlayerTurnIndicators()
        updateCenterStackImages()
    }
    
    func updateCardCounts() {
        //updates card counts
        player1CardCount.text = "x\(game.gameDecks[1].cards.count)"
        player2CardCount.text = "x\(game.gameDecks[2].cards.count)"
    }
    
    func updatePlayerTurnIndicators() {
        //changes the images based on who's turn it is to deal
        let arrowImage = UIImage(named: "arrow")
        
        if(game.buttonsShouldBeHilighted == false) {    //if the stack should be claimed, and no cards should be dealt
            player1TurnIndicator.setImage(nil, for: .normal)
            player2TurnIndicator.setImage(nil, for: .normal)
        }
        else {
            if (game.turn%2 == 1) {         //if it is player 1's turn
                player1TurnIndicator.setImage(arrowImage, for: .normal)
                player2TurnIndicator.setImage(nil, for: .normal)
            }
            else {                          //if it is player 2's turn
                player1TurnIndicator.setImage(nil, for: .normal)
                player2TurnIndicator.setImage(arrowImage, for: .normal)
            }
        }
    }
    
    func updatePlayersStackImages() {
        //changes the images based on who's turn it is to deal
        let unhilightedBack = UIImage(named: "back")
        let hilightedBack = UIImage(named: "backHilighted")
        
        if(game.buttonsShouldBeHilighted == false) {    //if the stack should be claimed, and no cards should be dealt
            player1CardBack.image = unhilightedBack
            player2CardBack.image = unhilightedBack
        }
        else {
            if (game.turn%2 == 1) {         //if it is player 1's turn
                player1CardBack.image = hilightedBack
                player2CardBack.image = unhilightedBack
            }
            else {                          //if it is player 2's turn
                player1CardBack.image = unhilightedBack
                player2CardBack.image = hilightedBack
            }
        }
    }
    
    func updateCenterStackImages() {
        centerStackView.stack = game.gameDecks[0]
        centerStackView.updateImages()
    }
    
    //MARK: Restart Game Methods
    func checkLoss() {
        if(game.loss) {
            if(game.gameDecks[1].cards.count == 0) {
                print("player 2 wins")
            }
            else {
                print("player 1 wins")
            }
            sleep(2)
            newGame()
        }
    }
    
    func newGame() {
        game = GameLogic()
        game.addAnimationDelegate(self)
        centerStackView.stack = game.gameDecks[0]
        updateView()
    }
    
    //MARK: Animation Variables
    var playerStackFrames: [CGRect] {
        get {
            return [CGRect.zero,                //just an empty slot
                    (player1CardBack.superview?.convert(player1CardBack.frame, to: nil))!,      //player1's stack
                    (player2CardBack.superview?.convert(player2CardBack.frame, to: nil))!]      //player2's stack
        }
    }
    
    var slapAnimationDuration: Double = 0.3
    var burnAnimationDuration: Double = 0.6
    var claimAnimationDuration: Double = 0.3
    
    //MARK: Animation Methods
    func animate(card: Card, from: CGRect, to: CGRect, isOnTop: Bool, duration: Double) {
        // initialize the imageView
        let movingCard = UIImageView()
        movingCard.contentMode = .scaleAspectFit
        self.view.addSubview(movingCard)
        
        // moves the card to the bottom, if isOnTop is false
        if(!isOnTop) {
            self.view.sendSubview(toBack: movingCard)
        }
        
        // set the imageView's location
        movingCard.frame = from
        movingCard.layoutIfNeeded()
        
        // add the image and unhide the imageView
        movingCard.image = UIImage(named: card.name)
        movingCard.isHidden = false
        
        // move the imageView
        UIView.animate(withDuration: duration, animations: {
            movingCard.frame.origin = to.origin
            movingCard.frame.size.width = to.width
            movingCard.frame.size.height = to.height
        },  completion: { Bool -> Void in           //this is the completion handler, it removes the views
            movingCard.isHidden = true
            movingCard.removeFromSuperview()
            self.updateView()
        })
    }
    
    //MARK: Animation Delegate Protocol
    func cardDealt(card: Card, fromPlayer playerNum: Int) {
        let fromRect = playerStackFrames[playerNum]
        let toRect = centerStackView.topCardFrame
        
        // hides the actual card that is to be moved from the stack view
        updateView()
        centerStackView.cardViews[centerStackView.cardViews.count-1].isHidden = true
        
        // moves the card image to where the actual card is, and then removes the card image, and reshows the actual card
        animate(card: card, from: fromRect, to: toRect, isOnTop: true, duration: slapAnimationDuration)
    }
    
    func cardBurned(card: Card, fromPlayer playerNum: Int) {
        let fromRect = playerStackFrames[playerNum]
        let toRect = centerStackView.bottomCardFrame
        
        // moves the card image to where the actual card is, and updates centerStack
        animate(card: card, from: fromRect, to: toRect, isOnTop: false, duration: burnAnimationDuration)
    }
    
    func claimCards(toPlayer playerNum: Int) {
        let centerCards: [Card] = centerStackView.stack.cards
        let centerFrames: [CGRect] = centerStackView.cardFrames
        
        for cardView in centerStackView.cardViews {
            cardView.isHidden = true
        }
        
        for index in centerCards.count-centerStackView.numberOfCards ..< centerCards.count {
            if index >= 0 {
                let cardToMove: Card = centerCards[index]
                let fromRect: CGRect = centerFrames[index - centerCards.count + centerStackView.numberOfCards]
                animate(card: cardToMove, from: fromRect, to: playerStackFrames[playerNum], isOnTop: true, duration: claimAnimationDuration)
            }
        }
    }
    
}
