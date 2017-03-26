/*
ONO (English version)
(c)2011 YAU
The MIT License


OFFICIAL SITE
http://onohugou.sakura.ne.jp/en.html


RULES

Empty your cards earlier than the others.
Play stronger and the same count of cards.
You win if you survive 3 rounds.

Weaker A 2 3 4 5 6 7 8 9 10 J Q K Stronger

J: Revolution card. It reverses the card strength order.
3: Counterrevolution card. It restores the card strength order.
JOKER: You can play a joker in any case. Play jokers one by one.

DRAW: You can draw one card.
PLAY: You can play stronger and the same count of cards.
DISCARD: You can discard one unnecessary card.

*3 decks of playing cards are used.
*/

package {
    import flash.display.*
    import flash.events.UncaughtErrorEvent

    [SWF(backgroundColor=0xffffff, width=500, height=500, frameRate=12)]
    
    public class Ono extends Sprite {
        public static const version:String = '2.0.13.1_wonderflen'

        function Ono() {
            this.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, g.errorHandler)
            g.stage = this.stage
            new Game
        }
    }
}

import flash.display.*
import flash.events.*
import flash.text.*
import flash.geom.Rectangle
import flash.geom.Matrix
import flash.utils.Timer
import flash.net.*

class g {
    public static const testHandCount:int = 0
    public static const opened:Boolean = false
    public static const autoPlay:Boolean = false
    public static const skipConfirm:Boolean = false

    public static const normalSpeed:Number = 1
    public static const hiSpeed:Number = g.normalSpeed * 0.3
    public static var speed:Number = g.normalSpeed

    public static const font:String = '_sans'
    public static var lang:Object
    public static var stage:Stage
    public static var game:Game
    public static var players:Players
    public static var player:Player
    public static var stock:Stock
    public static var playPile:PlayPile
    public static var drawPile:DrawPile
    public static var discardPile:DiscardPile
    public static var revolution:Revolution
    public static var message:Message
    public static var commandButtons:CommandButtons

    public static function defaultable(value:*, defaultValue:*):* {
        if (value === null || value === undefined || value === '' || isNaN(value)) {
            return defaultValue
        }
        return value
    }

    public static function setTimeout(callback:Function, delay:int=0):void {
        var timer:Timer = new Timer(delay * g.speed, 1)
        timer.addEventListener(TimerEvent.TIMER, callback)
        timer.start()
    }

    public static var errored:Boolean = false
    public static function errorHandler(event:*):void {
        if (g.errored) {
            return
        }
        g.errored = true

        try {
            _DisplayObjectContainer.removeAllChildren(g.stage)
            var text:TextField = _TextField.newText('ERROR', {color: 0x777777, size: 20, letterSpacing: 5})
            g.stage.addChild(text)
            _DisplayObject.align(text, ['center', 'middle'])
        } catch (error:*) {
            trace('#failed to show error message')
        }
    }
}

class Game {
    private static var gameNo:int = 0
    private var roundNo:int
    private var turnNo:int

    function Game() {
        _DisplayObjectContainer.removeAllChildren(g.stage)
        Game.gameNo++
        this.roundNo = 0

        new Version
        g.lang = Lang.lang
        g.game = this
        g.players = new Players
        g.stock = new Stock
        g.commandButtons = new CommandButtons
        g.message = new Message
        g.revolution = new Revolution
        g.drawPile = new DrawPile
        g.playPile = new PlayPile
        g.discardPile = new DiscardPile

        this.initializeRound()
    }

    private function initializeRound():void {
        this.roundNo++
        this.turnNo = 0
        g.speed = g.normalSpeed

        g.commandButtons.drawMoveButtons()
        g.revolution.revolutionized = false
        g.drawPile.opened = false
        g.player = this.roundNo == 1 ? g.players.human : g.players.first
        g.players.resetRank()
        for each (var player:Player in g.players.array) {
            player.hand.opened = false
        }

        g.stock.deal()
        this.initializeTurn()
    }

    private function initializeTurn():void {
        this.turnNo++
        if (this.turnNo == 1 || g.drawPile.drawn) {
            this.turn()
        } else {
            g.player = g.players.next()
    
            if (g.player == g.playPile.player) {
                g.playPile.clear()
            }
    
            if (!g.player.hand.count()) {
                this.initializeTurn()

            } else {
                this.turn()
            }
        }
    }

    private function turn():void {
        g.setTimeout(function():void {
            g.player.inputter.input()
        }, g.player.human ? 0 : 1000)
    }

    public function terminateTurn():void {
        g.message.undraw()

        if (!g.player.hand.count()) {
            g.players.setRank(g.player)

            if (g.player.human || g.players.last) {
                g.drawPile.opened = true
                for each (var player:Player in g.players.array) {
                    player.hand.opened = true
                }
            }
            if (g.player.human) {
                g.speed = g.hiSpeed
            }
        }

        if (!g.players.last) {
            this.initializeTurn()

        } else {
            if (g.players.last.human) {
                g.message.draw(g.lang.lose)
                g.commandButtons.drawRetryButton()

            } else if (g.players.countWhoPlaying() == 2) {
                g.message.draw(g.lang.win)
                g.commandButtons.drawRetryButton()
    
            } else {
                g.players.last.playing = false
                g.commandButtons.drawNextRoundButton()
            }
        }
    }

    public function terminateRound():void {
        g.stock.collect()
        g.message.undraw()
        g.revolution.undraw()
        this.initializeRound()
    }

    public function terminateGame():void {
        new Game
    }
}

class Player {
    private static const HUMAN_PLAYER_ID:int = 0

    public var id:int
    public var playing:Boolean
    public var rank:Number
    public var human:Boolean
    public var inputter:*
    public var hand:Hand
    public var stage:Sprite

    private var STAGE_CONFS:Array = [
        {x: 0, y: 0, rotation: 0},
        {x: g.stage.stageWidth, y: 0, rotation: 90},
        {x: g.stage.stageWidth, y: g.stage.stageHeight, rotation: 180},
        {x: 0, y: g.stage.stageHeight, rotation: 270}
    ]

    function Player(id:int) {
        this.id = id
        this.playing = true
        this.human = id == HUMAN_PLAYER_ID
        this.stage = this.newStage()
        this.inputter    = this.human && !g.autoPlay ? new HumanInputter : new MachineInputter(this)
        this.hand = new Hand(this)
    }

    private function newStage():Sprite {
        var conf:Object = STAGE_CONFS[this.id]
        var stage:Sprite = new Sprite
        stage.rotation = conf.rotation
        stage.x = conf.x
        stage.y = conf.y
        g.stage.addChild(stage)
        return stage
    }
}

class Players {
    private static const COUNT:int = 4

    public var array:Array = []
    public var human:Player
    private var nextRank:Number

    function Players() {
        for (var id:int = 0; id < COUNT; id++) {
            var player:Player = new Player(id)
            if (player.human) {
                this.human = player
            }
            this.array.push(player)
        }
    }

    public function next():Player {
        return _Array.circularAt(this.array, g.player.id + 1)
    }

    public function setRank(player:Player):void {
        player.rank = this.nextRank++
    }
    
    public function resetRank():void {
        this.nextRank = 1
        for each (var player:Player in this.array) {
            player.rank = NaN
        }
    }

    public function get first():Player {
        var first:Player = null
        for each (var player:Player in this.array) {
            if (player.rank == 1) {
                first = player
                break
            }
        }
        return first
    }

    public function get last():Player {
        var last:Player = null
        if (this.countWhoHaveHand() == 1) {
            for each (var player:Player in this.array) {
                if (player.hand.count()) {
                    last = player
                }
            }
            if (!last) throw Error('last can not be null')
        }
        return last
    }

    public function minOtherHandCount():int {
        var counts:Array = []
        for each (var player:Player in this.array) {
            if (player != g.player && player.hand.count()) {
                counts.push(player.hand.count())
            }
        }
        return Math.min.apply(null, counts)
    }

    public function countWhoHaveHand():int {
        return this.array.filter(function(player:Player, i:int, array:Array):Boolean {
            return Boolean(player.hand.count())
        }).length
    }

    public function countWhoPlaying():int {
        return this.array.filter(function(player:Player, i:int, array:Array):Boolean {
            return player.playing
        }).length
    }
}

class Card extends Sprite {
    public static const WIDTH:Number = 30
    public static const HEIGHT:Number = 40

    public static const BORDER_WIDTH:int = 1
    private static const BORDER_COLOR:int = 0x777777

    public static const BACKGROUND_COLORS:Object = {3: 0xDDE6EE, 11: 0xeedddd}
    private static const DEFAULT_BACKGROUND_COLOR:int = 0xffffff

    private static const BACK_BACKGROUND_COLORS:Array = [0xE6E6E6, 0xE6E6E6, 0xE6E6E6]
    private static const RANK_TEXTS:Object = {1: 'A', 11: 'J', 12: 'Q', 13: 'K', 14: "JO\nKER"}

    private static const RED_SUIT_COLOR:int = 0xE68989
    public static const BLACK_SUIT_COLOR:int = BORDER_COLOR
    private static const SUIT_COLORS:Object = {heart: RED_SUIT_COLOR, diamond: RED_SUIT_COLOR, club: BLACK_SUIT_COLOR, spade: BLACK_SUIT_COLOR}

    public var rank:Number
    public var suit:String
    public var deckId:int
    public var opened:Boolean
    public var selected:Boolean
    public var select:Function

    function Card(conf:Object) {
            this.rank = conf.rank
            this.suit = conf.suit
            this.deckId = g.defaultable(conf.deckId, 0)
            this.opened = g.defaultable(conf.opened, true)
            this.selected = false
            if (g.defaultable(conf.draw, true)) this.draw()
    }

    public function draw():void {
            this.undraw()
            this.drawBackground()
            if (this.opened) {
                this.drawSuit()
                this.drawRank()
            }
            this.drawBorder()
    }

    public function undraw():void {
        if (this.parent) {
            this.parent.removeChild(this)
        }
        this.graphics.clear()
        _DisplayObjectContainer.removeAllChildren(this)
    }

    private function drawBackground():void {
        var color:int = this.opened ? BACKGROUND_COLORS[this.rank] || DEFAULT_BACKGROUND_COLOR : BACK_BACKGROUND_COLORS[this.deckId]
        this.graphics.beginFill(color)
        this.graphics.lineStyle(NaN)
        this.graphics.drawRect(0, 0, WIDTH, HEIGHT)
        this.graphics.endFill()
    }

    private function drawSuit():void {
        if (this.rank == Rank.JOKER) {
            return
        }
        var suitColor:int = SUIT_COLORS[this.suit]
        var suitSize:Number = WIDTH / 40 * 15

        this.graphics.beginFill(suitColor)
        this.graphics.lineStyle(BORDER_WIDTH, suitColor)

        this.graphics.moveTo(0, 0)
        this.graphics.lineTo(suitSize, 0)
        if (_Array.includes(['heart', 'club'], this.suit)) {
            var control:Number = suitSize * 1.05
            this.graphics.curveTo(control, control, 0, suitSize)
        } else {
            this.graphics.lineTo(0, suitSize)
        }
        this.graphics.endFill()
    }

    private function drawRank():void {
        var text:TextField = new TextField
        text.autoSize = TextFieldAutoSize.LEFT

        var format:TextFormat = new TextFormat
        format.font = g.font
        format.color = SUIT_COLORS[this.suit]

        if (this.rank == Rank.JOKER) {
            format.size = Math.ceil(WIDTH * 1.5 / 4)
            format.bold = true
        } else {
            format.size = Math.ceil(WIDTH * 3 / 4)
        }
        if (_Array.includes([6, 9], this.rank)) {
            format.underline = true
        }

        text.defaultTextFormat = format
        text.text = RANK_TEXTS[this.rank] || String(this.rank)

        var bitmapData:BitmapData = new BitmapData(text.width, text.height, true, 0)
        var rect:Rectangle = new Rectangle(0, 0, text.width, text.height)
        bitmapData.draw(text, null, null, null, rect, true)

        var bitmap:Bitmap = new Bitmap(bitmapData, 'auto', true)
        this.addChild(bitmap)
        _DisplayObject.align(bitmap, ['center', 'middle'])
    }

    private function drawBorder():void {
        this.graphics.lineStyle(BORDER_WIDTH, BORDER_COLOR)
        this.graphics.drawRect(0, 0, WIDTH, HEIGHT)
    }
}

class Cards {
    public var array:Array

    function Cards(array:Array=null) {
        this.array = array || []
    }

    public function shuffle():void {
        _Array.shuffle(this.array)
    }

    public function popAll():Cards {
        return new Cards(_Array.popAll(this.array))
    }

    public function push(_cards:*):void {
        var cards:Cards = Cards.cast(_cards)
        for each (var card:Card in cards.array) {
            this.array.push(card)
        }
    }

    public function pop():Card {
        return this.array.pop()
    }

    public function count():int {
        return this.array.length
    }

    public function sort():void {
        var array:Array = this.array.slice()
        this.array.sort(function(a:Card, b:Card):int {
            return a.rank - b.rank || array.indexOf(a) - array.indexOf(b)
        })
    }

    static public function cast(cards:*):Cards {
        if (cards is Cards) {
            return Cards(cards)
        } else if (cards is Card) {
            return new Cards([cards])
        }
        throw Error('invalid cards=' + cards)
    }

    public function selectees():Cards {
        var cards:Cards = new Cards
        for each (var card:Card in this.array) {
            if (card.selected) {
                cards.push(card)
            }
        }
        return cards
    }

    public function popSelectees():Cards {
        return new Cards(_Array.popValues(this.array, this.selectees().array))
    }

    public function get rank():Number {
        var _ranks:Array = _Array.unique(this.ranks)
        var rank:Number = _ranks.length == 1 ? _ranks[0] : NaN
        return rank
    }

    public function get ranks():Array {
        return this.array.map(function(card:Card, i:int, array:Array):Number {
            return card.rank
        })
    }
}

class Hand {
    public static const COUNT:int = g.testHandCount || 13
    public static var Y:int
    private static const SELECT_Y:int = 10

    private var cards:Cards
    private var player:Player
    private var group:MyGroup
    private var _opened:Boolean

    function Hand(player:Player) {
        Hand.Y = g.stage.stageHeight - Card.HEIGHT - Card.BORDER_WIDTH
        this.cards = new Cards
        this.player = player
        this.group = new MyGroup({parent: this.player.stage, direction: 'horizontal', gap: -Card.BORDER_WIDTH})
    }

    private function push(card:Card):void {
        card.selected = false
        card.opened = this._opened || this.player.human || g.opened
        card.x = 0
        card.y = 0

        if (this.player.human) {
            this.bind(card)
        }

        this.cards.push(card)
        card.draw()
    }

    public function pushToDeal(cards:Cards):void {
        for each (var card:Card in cards.array) {
            this.push(card)
        }
        this.arrange()
    }

    public function pushToDraw(card:Card):void {
        this.push(card)
        this.group.addChild(new Spacer(10))
        this.group.addChild(card)
        _DisplayObject.align(this.group, ['center'], g.stage)
    }

    private function bind(card:Card):void {
        card.buttonMode = true
        card.select = function():void {
            card.y += SELECT_Y * (card.selected ? 1 : -1)
            card.selected = !card.selected
        }
        card.addEventListener(MouseEvent.CLICK, card.select)
    }

    private function unbind(card:Card):void {
        card.buttonMode = false
        card.removeEventListener(MouseEvent.CLICK, card.select)
    }

    public function set opened(b:Boolean):void {
        this._opened = b
        if (this.cards.count()) {
            for each (var card:Card in this.cards.array) {
                card.opened = b
                card.draw()
            }
            this.arrange()
        }
    }

    private function arrange():void {
        this.cards.sort()
        _DisplayObjectContainer.removeAllChildren(this.group)
        for each (var card:Card in this.cards.array) {
            this.group.addChild(card)
        }

        _DisplayObject.align(this.group, ['center'], g.stage)
        this.group.y = Y
    }

    public function count():int {
        return this.cards.count()
    }

    public function get ranks():Array {
        return this.cards.ranks
    }

    public function selectees():Cards {
        return this.cards.selectees()
    }

    public function popSelectees():Cards {
        var cards:Cards = this.cards.popSelectees()
        this.remove(cards)
        this.arrange()
        return cards
    }

    private function remove(cards:Cards):void {
        for each (var card:Card in cards.array) {
            if (this.player.human) {
                this.unbind(card)
            }
            card.selected = false
            card.parent.removeChild(card)
        }
    }

    public function select(rank:Number, count:int):void {
        var _count:int = 0
        for (var i:int = this.count() - 1; i >= 0; i--) {
            var card:Card = this.cards.array[i]

            card.selected = false
            if (_count == count) {
                break
            }
            if (card.rank == rank) {
                card.selected = true
                _count++
            }
        }
        if (_count != count) throw Error('wrong count')
        if (_count != this.selectees().count()) throw Error('failed to select')
    }

    public function clear():void {
        var cards:Cards = this.cards.popAll()
        this.remove(cards)
        g.stock.push(cards)
    }
}

class Stock {
    private static const DECK_COUNT:int = 3

    private var frontCards:Cards
    private var backCards:Cards
    private var createdCardCount:int

    function Stock() {
        this.frontCards = new Cards
        this.backCards = this.createCards()
    }

    private function createCards():Cards {
        var cards:Cards = new Cards
        for (var deckId:int = 0; deckId < DECK_COUNT; deckId++) {
            for each (var rank:Number in Rank.ALL) {
                for each (var suit:String in Suit.ALL) {
                    if (rank == Rank.JOKER && !_Array.includes(['heart', 'spade'], suit)) {
                        continue
                    }
                    cards.push(new Card({rank: rank, suit: suit, deckId: deckId, draw: false}))
                }
            }
        }

        this.createdCardCount = cards.count()
        if (this.createdCardCount != 162) throw Error('wrong created card count')

        return cards
    }

    public function pop():Card {
        if (!this.frontCards.count()) {
            this.frontCards.push(this.backCards.popAll())
            this.frontCards.shuffle()
        }
        var card:Card = this.frontCards.pop()
        card.x = 0
        card.y = 0
        card.rotation = 0
        card.opened = false
        return card
    }

    public function popSome(count:int):Cards {
        var cards:Cards = new Cards
        for (var i:int = 0; i < count; i++) {
            cards.push(this.pop())
        }
        return cards
    }

    public function push(_cards:*):void {
        var cards:Cards = Cards.cast(_cards)
        for each (var card:Card in cards.array) {
            if (card.parent) {
                card.parent.removeChild(card)
            }
            card.undraw()
        }
        this.backCards.push(cards)
    }

    public function deal():void {
        for each (var player:Player in g.players.array) {
            if (!player.playing) {
                continue
            }
            player.hand.pushToDeal(g.stock.popSome(Hand.COUNT))
        }
        g.drawPile.push(g.stock.pop())
    }

    public function collect():void {
        g.playPile.clear()
        g.drawPile.clear()
        g.discardPile.clear()
        for each (var player:Player in g.players.array) {
            player.hand.clear()
        }

        this.backCards.push(this.frontCards.popAll())
        if (this.backCards.count() != this.createdCardCount) throw Error('some cards lost=' + (this.backCards.count() - this.createdCardCount))
        if (_Array.unique(this.backCards.array).length != this.createdCardCount) throw Error('some cards duplicated=' + (_Array.unique(this.backCards.array).length - this.createdCardCount))
    }
}

class PlayPile {
    public var player:Player
    private var cards:Cards = new Cards
    private var group:MyGroup

    public function clear():void {
        this.player = null

        if (this.group) {
            g.stage.removeChild(this.group)
            this.group = null
            g.stock.push(this.cards.popAll())
        }
    }

    public function count():int {
        return this.cards.count()
    }
    
    public function get rank():Number {
        return this.cards.rank
    }

    public function push(cards:Cards, player:Player):void {
        this.clear()
        this.player = player
        this.group = new MyGroup({parent: g.stage, direction: 'horizontal', gap: -Card.BORDER_WIDTH})
        this.cards = cards

        for each (var card:Card in this.cards.array) {
            card.opened = true
            card.x = 0
            card.y = 0
            card.draw()
            this.group.addChild(card)
        }
        _DisplayObject.transform(this.group, player.stage.rotation, g.stage.stageWidth / 2, g.stage.stageHeight / 2)
    }

    public function playerHaveHand():Boolean {
        return this.player && this.player.hand.count()
    }
}

class DrawPile {
    private var card:Card
    public var drawn:Boolean = false
    private var _opened:Boolean

    public function push(card:Card):void {
        this.card = card
        this.card.opened = this._opened || g.opened
        this.draw()
    }

    private function draw():void {
        this.card.draw()
        _DisplayObject.transform(this.card, 0, g.stage.stageWidth / 2 - 110, g.stage.stageHeight / 2 + Card.HEIGHT + 10)
        g.stage.addChild(this.card)
    }

    public function pop():Card {
        var _card:Card = this.card
        this.push(g.stock.pop())
        g.stage.removeChild(_card)
        return _card
    }

    public function clear():void {
        if (this.card) {
            g.stock.push(this.card)
            this.card = null
        }
    }

    public function set opened(b:Boolean):void {
        this._opened = b
        if (this.card) {
            this.card.opened = b
            this.draw()
        }
    }
}

class DiscardPile {
    private var card:Card

    public function push(cards:Cards, player:Player):void {
        if (cards.count() != 1) throw Error('invalid count=' + cards.count())

        this.clear()
        this.card = cards.array[0]
        this.card.opened = true
        this.card.draw()
        this.card.x = 0
        this.card.y = 0
        g.stage.addChild(this.card)
        _DisplayObject.transform(this.card, player.stage.rotation, g.stage.stageWidth / 2 + 110, g.stage.stageHeight / 2 + Card.HEIGHT + 10)
    }

    public function clear():void {
        if (this.card) {
            g.stock.push(this.card)
            this.card = null
        }
    }
}

class Suit {
    public static const ALL:Array = ['heart', 'diamond', 'club', 'spade']
}

class Rank {
    public static const COUNTERREVOLUTION:int = 3
    public static const CENTER:int = 7
    public static const REVOLUTION:int = 11
    public static const JOKER:int = 14

    public static const ALL:Array = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14]

    private static function filter(rank:Number):int {
        if (!_Array.includes(Rank.ALL, rank)) throw Error('invalid rank')
        return rank
    }

    public static function abs(rank:Number):int {
        Rank.filter(rank)
        var _rank:Number = Rank.CENTER + Math.abs(rank - Rank.CENTER)
        return Rank.filter(_rank)
    }

    public static function reverse(rank:Number):int {
        Rank.filter(rank)
        var _rank:Number
        if (rank == Rank.JOKER) {
            _rank = rank
        } else {
            _rank = Rank.JOKER - rank
        }
        return Rank.filter(_rank)
    }

    public static function current(rank:Number):int {
        Rank.filter(rank)
        if (g.revolution.revolutionized) {
            return reverse(rank)
        } else {
            return rank
        }
    }
}

class Revolution {
    public var revolutionized:Boolean
    private var indicator:MyLabel
    private static var INDICATOR_CONFS:Array

    function Revolution() {
        INDICATOR_CONFS = [
            {text: g.lang.counterrevolution, backgroundColor: Card.BACKGROUND_COLORS[3]},
            {text: g.lang.revolution, backgroundColor: Card.BACKGROUND_COLORS[11]}
        ]
    }

    public function revolutionize():void {
        this.revolutionized = !this.revolutionized
        this.draw()
    }

    private function draw():void {
        this.undraw()
        this.indicator = this.newIndicator()
        g.stage.addChild(this.indicator)
        _DisplayObject.setCenterX(this.indicator, 250)
        this.indicator.y = 350
    }

    public function undraw():void {
        if (this.indicator) {
            g.stage.removeChild(this.indicator)
            this.indicator = null
        }
    }

    private function newIndicator():MyLabel {
        var conf:Object = INDICATOR_CONFS[int(this.revolutionized)]
        return new MyLabel(conf.text, {color: Card.BLACK_SUIT_COLOR, bold: true, size: 16, backgroundColor: conf.backgroundColor, letterSpacing: 2, horizontalPadding: 4, verticalPadding: 4})
    }
}

class Message {
    private var label:MyLabel

    public function draw(text:String, conf:Object=null):void {
        conf = conf || {}
        text = g.lang[text] ? g.lang[text] : text

        this.undraw()
        this.label = new MyLabel(text, {size: conf.size || 14, color: 0x777777, backgroundColor: 0xffffff, letterSpacing: 0, horizontalPadding: 2})
        this.label.y = 390
        g.stage.addChild(this.label)
        _DisplayObject.align(this.label, ['center'])
    }

    public function undraw():void {
        if (this.label) {
            g.stage.removeChild(this.label)
            this.label = null
        }
    }
}

class CommandButtons {
    private var group:MyGroup

    function CommandButtons() {
        this.group = new MyGroup({parent: g.stage, direction: 'horizontal', gap: 10})
    }

    private function drawButtons(buttons:Array):void {
        _DisplayObjectContainer.removeAllChildren(this.group)
        for each (var button:MyButton in buttons) {
            this.group.addChild(button)
        }
        _DisplayObject.align(this.group, ['center'])
        this.group.y = Hand.Y - this.group.height - 20
    }

    public function drawMoveButtons():void {
        this.drawButtons([this.newDrawButton(), this.newPlayButton(), this.newDiscardButton()])
    }

    private function newDrawButton():MyButton {
        var button:MyButton = new MyButton(g.lang.Command_draw)
        button.addEventListener(MouseEvent.CLICK, function():void {
            g.players.human.inputter.accept(new Move({type: 'draw'}))
        })
        return button
    }

    private function newPlayButton():MyButton {
        var button:MyButton = new MyButton(g.lang.Command_play)
        button.addEventListener(MouseEvent.CLICK, function():void {
            accept('play')
        })
        return button
    }

    private function newDiscardButton():MyButton {
        var button:MyButton = new MyButton(g.lang.Command_discard)
        button.addEventListener(MouseEvent.CLICK, function():void {
            accept('discard')
        })
        return button
    }

    private function accept(type:String):void {
        var cards:Cards = g.players.human.hand.selectees()

        var move:Move = new Move
        move.count = cards.count()
        move.rank = cards.rank
        move.type = type

        g.players.human.inputter.accept(move)
    }

    public function drawRetryButton():void {
        var f:Function = function():void {
            g.game.terminateGame()
        }
        if (g.skipConfirm) {
            f()
        } else {
            var button:MyButton = new MyButton(g.lang.Command_retry, {width: 0, horizontalPadding: 3})
            button.addEventListener(MouseEvent.CLICK, f)
            this.drawButtons([button])
        }
    }

    public function drawNextRoundButton():void {
        var f:Function = function():void {
            g.game.terminateRound()
        }
        if (g.skipConfirm) {
            f()
        } else {
            var button:MyButton = new MyButton(g.lang.Command_nextRound, {width: 0, horizontalPadding: 3})
            button.addEventListener(MouseEvent.CLICK, f)
            this.drawButtons([button])
        }
    }
}

class Move {
    public var type:String
    public var rank:Number
    public var count:int
    public var priorities:Array

    public function Move(conf:Object=null) {
        conf = conf || {}
        this.type = conf.type || ''
        this.rank = conf.rank || NaN
        this.count = conf.count || 0
        this.priorities = conf.priorities || []
    }

    public function validate():String {
        if (!(_Array.includes(Rank.ALL, this.rank) || isNaN(this.rank))) throw Error('invalid rank=' + this.rank)
        if (!(this.count >= 0)) throw Error('invalid count=' + this.count)

        switch (this.type) {
            case 'play':
                if (this.count <= 0) {
                    return 'Error_playingNothing'
                }

                if (isNaN(this.rank)) {
                    return 'Error_playingRanks'
                }

                if (this.rank == Rank.JOKER) {
                    if (this.count != 1) {
                        return 'Error_playingJorkers'

                    } else if (g.player.hand.count() == 1) {
                        return 'Error_playingJokerAtLast'
                    }

                    return ''
                }

                if (g.playPile.count()) {
                    if (this.count != g.playPile.count()) {
                        return 'Error_playingDifferentCountOfCards'

                    } else if (Rank.current(this.rank) <= Rank.current(g.playPile.rank)) {
                        if (g.revolution.revolutionized) {
                            return 'Error_playingWeakerInRevolution'
                        } else {
                            return 'Error_playingWeakerNotInRevolution'
                        }
                    }

                    return ''
                }

                return ''

            case 'draw':
                if (!Move.validType(this.type)) {
                    return 'Error_drawingTwice'
                }

                return ''

            case 'discard':
                if (!Move.validType(this.type)) {
                    return 'Error_discardingBeforeDrawing'
                }

                if (this.count <= 0) {
                    return 'Error_discardingNothing'
                }

                if (this.count != 1) {
                    return 'Error_discardingMultiple'
                }

                return ''
        }

        return 'Error_invalidMoveType'
    }

    public function execute():void {
        if (this.validate()) throw Error('move validation failed')
        trace(
            '#player=' + g.player.id + 
            ' playPile=[' + (g.playPile.rank || g.playPile.count() ? g.playPile.rank + ' * ' + g.playPile.count() + ' player=' + g.playPile.player.id : '') + ']' +
            ' revolutionized=' + int(g.revolution.revolutionized) +
            ' drawn=' + int(g.drawPile.drawn) +
            ' hand=' + '[' + g.player.hand.ranks.join(' ') + ']' +
            ' move=[' + this.type + (this.rank || this.count ? ' ' + this.rank + ' * ' + this.count : '') + ']' +
            ' remain=' + (g.player.hand.count() - this.count + (this.type == 'draw'))
        )

        g.drawPile.drawn = false
        switch (this.type) {
            case 'play':
                g.playPile.push(g.player.hand.popSelectees(), g.player)
                if (Rank.current(g.playPile.rank) == Rank.REVOLUTION) {
                    g.revolution.revolutionize()
                }
                break
            case 'draw':
                var card:Card = g.drawPile.pop()
                g.player.hand.pushToDraw(card)
                g.drawPile.drawn = true
                break
            case 'discard':
                g.discardPile.push(g.player.hand.popSelectees(), g.player)
                break
            default:
                throw Error('invalid type=' + this.type)
        }

        g.game.terminateTurn()
    }

    public function onlyJokersWillRemain():Boolean {
        return (
            this.rank != Rank.JOKER &&
            _Array.countValues(g.player.hand.ranks, Rank.JOKER) &&
            (g.player.hand.count() - this.count) == _Array.countValues(g.player.hand.ranks, Rank.JOKER)
        )
    }

    public static function validType(type:String):Boolean {
        return {
            draw: !g.drawPile.drawn,
            discard: g.drawPile.drawn,
            play: true
        }[type]
    }

    public static function sortMovesByPriorities(moves:Array):void {
        moves.sort(function(a:Move, b:Move):int {
            for (var i:int = 0; i < Math.min(a.priorities.length, b.priorities.length); i++) {
                var compare:Number = Number(b.priorities[i]) - Number(a.priorities[i])
                if (compare) {
                    return compare < 0 ? -1 : 1
                }
            }
            return b.priorities.length - a.priorities.length
        })
    }

    public static function validMoves(type:String):Array {
        var moves:Array = []
        if (type == 'draw') {
            moves.push(new Move({type: type}))
        } else {
            for each (var rank:Number in Rank.ALL) {
                for (var count:int = 1; count <= _Array.countValues(g.player.hand.ranks, rank); count++) {
                    var move:Move = new Move({type: type, rank: rank, count: count})
                    if (!move.validate() && !move.onlyJokersWillRemain()) {
                        moves.push(move)
                    }
                }
            }
        }    
        return moves
    }
}

class HumanInputter {
    private var accepting:Boolean

    public function input():void {
        this.accepting = true
    }

    public function accept(move:Move):void {
        if (!this.accepting) {
            return
        }

        var error:String = move.validate()

        if (error) {
            g.message.draw(error)
            return
        }

        this.accepting = false
        move.execute()
    }
}

class MachineInputter {
    private var player:Player
    private var machine:Machine

    function MachineInputter(player:Player) {
        this.player = player
        this.machine = new Machine
    }

    public function input():void {
        var move:Move = this.get()
        if (_Array.includes(['play', 'discard'], move.type)) {
            this.player.hand.select(move.rank, move.count)
        }
        move.execute()
    }

    private function get():Move {
        var move:Move
        if (Move.validType('draw')) {
            move = this.getByType('draw')
            if (move.priorities.length) {
                return move
            }
        }

        move = this.getByType('play')
        if (move.priorities.length) {
            return move
        }

        if (Move.validType('draw')) {
            return new Move({type: 'draw'})
        }

        if (Move.validType('discard')) {
            return this.getByType('discard')
        }

        throw Error('wrong flow')
    }

    private function getByType(type:String):Move {
        var moves:Array = []
        for each (var move:Move in Move.validMoves(type)) {
            move.priorities = this.machine[type](move, g.player.hand)
            if (!(move.priorities is Array)) throw Error('priorities is not array')
            for each (var priority:* in move.priorities) {
                if (!((priority is Number && !isNaN(priority))|| priority is int || priority is Boolean)) throw Error('invalid priority')
            }

            moves.push(move)
        }
        if (type == 'play' && !moves.length) {
            moves.push(new Move({type: type}))
        }
        if (!moves.length) throw Error('no moves')

        Move.sortMovesByPriorities(moves)
        return moves[0]
    }
}

class Machine {
    public function draw(move:Move, hand:Hand):Array {
        return []
    }

    public function play(move:Move, hand:Hand):Array {
        if (move.count == hand.count()) {
            return [4]
        }
        if (move.rank == Rank.JOKER) {
            if (
                (g.players.countWhoHaveHand() == 2) &&
                g.playPile.playerHaveHand() && (
                    g.playPile.player.hand.count() == 1 ||
                    (g.playPile.player.hand.count() <= 5 && Math.random() < 0.5)
                )
            ) {
                return [3]
            } else if (_Array.unique(hand.ranks).length <= 2) {
                return [1]
            } else if (_Array.unique(hand.ranks).length <= 3 && Math.random() < 0.2) {
                return [1]
            } else if (g.playPile.playerHaveHand() && g.playPile.player.hand.count() <= 3 && _Array.countValues(hand.ranks, Rank.JOKER) >= 2 && Math.random() < 0.5) {
                return [1]
            }
            return []
        }

        var priorities:Array = [2]
        if (g.players.minOtherHandCount() <= 7) {
            priorities.push(Rank.current(move.rank))
            priorities.push(move.count != g.players.minOtherHandCount())
            priorities.push(move.count == _Array.countValues(hand.ranks, move.rank))
            priorities.push(_Array.countValues(hand.ranks, move.rank))
        } else {
            priorities.push(Rank.current(move.rank) < 11)
            priorities.push(move.count == _Array.countValues(hand.ranks, move.rank))
            priorities.push(-_Array.countValues(hand.ranks, move.rank))
            priorities.push(-Rank.abs(move.rank))
        }
        return priorities
    }
    
    public function discard(move:Move, hand:Hand):Array {
        var priorities:Array = []
        if (g.players.minOtherHandCount() <= 2) {
            priorities.push(-Rank.current(move.rank))
        } else {
            priorities.push(Rank.current(move.rank) < 12)
            priorities.push(Rank.abs(move.rank) < 12)
            priorities.push(move.rank != Rank.JOKER)
            priorities.push(-_Array.countValues(hand.ranks, move.rank))
        }
        return priorities
    }
}

class _DisplayObject {
    static public function align(obj:DisplayObject, types:Array, parent:*=null):void {
        for each (var type:String in types) {
            _DisplayObject.alignOne(obj, type, parent)
        }
    }

    static private function alignOne(obj:DisplayObject, type:String, parent:*=null):void {
        parent = parent || obj.parent
        if (type == 'center') {
            obj.x = ((parent is Stage ? parent.stageWidth : parent.width) - obj.width) / 2
        } else if (type == 'middle') {
            obj.y = ((parent is Stage ? parent.stageHeight : parent.height) - obj.height) / 2
        } else {
            throw Error('invalid type=' + type)
        }
    }

    public static function setCenterX(obj:DisplayObject, x:Number):void {
        obj.x = x - obj.width / 2
    }

    public static function transform(obj:DisplayObject, rotation:Number, centerX:Number, centerY:Number):void {
        obj.x = 0
        obj.y = 0
        var matrix:Matrix = new Matrix
        var centerX0:Number = obj.width / 2
        var centerY0:Number = obj.height / 2
        matrix.translate(-centerX0, -centerY0)
        matrix.rotate(rotation / 180 * Math.PI)
        matrix.translate(centerX, centerY)
        obj.transform.matrix = matrix
    }
}

class _DisplayObjectContainer {
    static public function removeAllChildren(obj:DisplayObjectContainer):void {
        while (obj.numChildren) {
            obj.removeChildAt(0)
        }
    }
    
    static public function arrangeChildren(obj:DisplayObjectContainer, direction:String, gap:int):void {
        var confs:Object = {
            horizontal: {axis: 'x', length: 'width'},
            vertical: {axis: 'y', length: 'height'}
        }
        var conf:Object = confs[direction]
        if (!conf) throw Error('invalid direction=' + direction)

        for (var i:int = 0; i < obj.numChildren; i++) {
            var curr:DisplayObject = obj.getChildAt(i)
            curr[conf.axis] = i == 0 ? 0 : prev[conf.axis] + prev[conf.length] + gap
            var prev:DisplayObject = curr
        }
    }
}

class MyGroup extends Sprite {
    private var gap:int
    private var direction:String

    function MyGroup(conf:Object) {
        this.direction = conf.direction
        if (conf.parent) {
            conf.parent.addChild(this)
        }
        this.gap = conf.gap
    }

    override public function addChild(obj:DisplayObject):DisplayObject {
        super.addChild(obj)
        _DisplayObjectContainer.arrangeChildren(this, this.direction, this.gap)
        return obj
    }
}

class Spacer extends Sprite {
    function Spacer(size:int) {
        this.graphics.drawRect(0, 0, size, size)
    }
}

class MyLabel extends Sprite {
    function MyLabel(_text:String, conf:Object) {
        var format:TextFormat = new TextFormat
        format.font = g.font
        format.color = g.defaultable(conf.color, 0xffffff)
        format.size = g.defaultable(conf.size, 11)
        format.letterSpacing = conf.letterSpacing
        format.bold = conf.bold

        var text:TextField = new TextField
        text.defaultTextFormat = format
        text.autoSize = TextFieldAutoSize.LEFT
        text.text = _text
        text.mouseEnabled = false

        this.graphics.beginFill(conf.backgroundColor)
        var width:int = (conf.width || text.width) + (conf.horizontalPadding || 0) * 2
        var height:int = (conf.height || text.height) + (conf.verticalPadding || 0) * 2
        this.graphics.drawRect(0, 0, width, height)
        this.graphics.endFill()

        this.addChild(text)
        _DisplayObject.align(text, ['center', 'middle'])
        text.x += conf.letterSpacing / 2
    }
}

class MyButton extends MyLabel {
    function MyButton(text:String, conf:Object=null) {
        conf = conf || {}
        var conf:Object = {horizontalPadding: conf.horizontalPadding, width: g.defaultable(conf.width, 100), backgroundColor: 0x888888, letterSpacing: 5}
        super(text, conf)
        this.buttonMode = true
    }
}

class _TextField {
    public static function newText(_text:String, conf:Object):TextField {
        var format:TextFormat = new TextFormat
        format.font = g.font
        format.color = g.defaultable(conf.color, 0xaaaaaa)
        format.size = conf.size
        format.letterSpacing = conf.letterSpacing
        format.bold = conf.bold

        var text:TextField = new TextField
        text.autoSize = TextFieldAutoSize.LEFT
        text.defaultTextFormat = format
        text.text = _text
        return text
    }
}

class _Array {
    public static function shuffle(array:Array):void {
        // Knuth-Fisher-Yates shuffle
        var length:int = array.length
        for (var i:int = length - 1; i > 0; i--) {
            var j:int = Math.floor(Math.random() * (i + 1))
            var temp:* = array[i]
            array[i] = array[j]
            array[j] = temp

            if (!(0 <= i && i < length)) throw Error('i is out of range. shuffle failed.')
            if (!(0 <= j && j < length)) throw Error('j is out of range. shuffle failed.')
        }
        if (!(array.length == length)) throw Error('array length changed. shuffle failed.')
    }

    public static function popAll(array:Array):Array {
        var _array:Array = []
        while (array.length) {
            _array.push(array.pop())
        }
        return _array
    }

    public static function popValues(heystack:Array, needles:Array):Array {
        for each (var needle:* in needles) {
            var i:int = heystack.indexOf(needle)
            if (!(i >= 0)) throw Error('invalid argument')
            heystack.splice(i, 1)
        }
        return needles
    }

    public static function circularAt(array:Array, i:int):* {
        return array[i % array.length]
    }

    public static function unique(array:Array):Array {
        var _array:Array = []
        for each (var v:Object in array) {
            if (!_Array.includes(_array, v)) {
                _array.push(v)
            }
        }
        return _array
    }

    public static function includes(heystack:Array, needle:*):Boolean {
        return heystack.indexOf(needle) >= 0
    }

    public static function countValues(heystack:Array, needles:*):int {
        needles = needles is Array ? needles : [needles]
        var count:int = 0
        for each (var hay:* in heystack) {
            count += _Array.includes(needles, hay)
        }
        return count
    }
}

class Version {
    function Version() {
        var text:TextField = _TextField.newText('ONO ' + Ono.version + ' ', {size: 10, letterSpacing: 3})
        text.x = Card.HEIGHT + 10
        text.y = Card.HEIGHT + 10
        g.stage.addChild(text)
    }
}

class Lang {
    public static const lang:Object = {
        revolution: 'REVOLUTION',
        counterrevolution: 'COUNTERREVOLUTION',
    
        lose: 'YOU LOSE...',
        win: 'YOU WIN!!!',

        Command_play: 'PLAY',
        Command_draw: 'DRAW',
        Command_discard: 'DISCARD',
        Command_retry: 'RETRY',
        Command_nextRound: 'NEXT ROUND',

        Error_playingNothing: 'Select card.',
        Error_playingWeakerNotInRevolution: 'Play bigger rank or a joker.',
        Error_playingWeakerInRevolution: 'In the revolution, play smaller rank or a joker.',
        Error_playingDifferentCountOfCards: 'Play the same count of cards.',
        Error_playingRanks: 'Play cards of a single rank.',
        Error_playingJorkers: 'Play jokers one by one.',
        Error_playingJokerAtLast: 'You can not play a joker at last.',

        Error_drawingTwice: 'You can not draw twice.',
        
        Error_discardingNothing: 'Select a card.',
        Error_discardingMultiple: 'Discard only one card.',
        Error_discardingBeforeDrawing: 'Draw a card before discarding.'
    }
}

