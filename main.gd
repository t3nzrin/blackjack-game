extends Node2D

# The deck data
const SUITS = ["♠", "♥", "♦", "♣"]
const VAlUES = ["A","2","3","4","5","6","7","8","9","10","J","Q","K"]
const NUMERIC = [11, 2, 3, 4, 5, 6, 7, 8, 9, 10, 10, 10, 10]
# ACE = 11 , number cards = face values, J/Q/K = 10
var deck = []  #the full shuffled deck (list of cards)
var player_hand = []   # cards the player is holding
var dealer_hand = []   #cards the dealer is holding 
var game_over = false  #is the game finished

#this loads the cards scene so we can create cards dynamically
var CardScene = preload("res://card.tscn")

func _ready() -> void:
	#_ready() runs automatically when the game starts
	#"Connect" each buttons to a function that runs when clicked
	$MarginContainer/VBoxContainer/HitButton.pressed.connect(_on_hit)
	$MarginContainer/VBoxContainer/StandButton.pressed.connect(_on_stand)
	$MarginContainer/VBoxContainer/NewGameButton.pressed.connect(start_game)
	
	start_game() #kick off the first game immediately
func build_deck():
	deck.clear() #empty any old deck first
	#loop through every suit and every value
	for suit in SUITS:
		for i in range(VAlUES.size()):
			#Add a card as a "dictionary" (a mini data bundle)
			deck.append({
				"suit": suit,
				"value": VAlUES[i],
				"numeric": NUMERIC[i]
			})
		#now deck has 52 cards 
func shuffle_deck():
	deck.shuffle() #Godot built in shuffle - randomizes the array
func draw_card():
	return deck.pop_back() #removes and return the last card
func hand_value(hand: Array) -> int:
	var total = 0
	var aces = 0
	for card in hand:
		total += card["numeric"]
		if card ["value"] == "A":
			aces += 1
	#if we're over 21 and have an ace counted as 11,
	#downgrade it to 1 (subtract 10) to avoid busting
	while total > 21 and aces > 0:
		total -= 10
		aces -= 1
	return total
func start_game():
	player_hand.clear()
	dealer_hand.clear()
	game_over =  false
	
	build_deck()
	shuffle_deck()
	
	#deal 2 cards to each person(alternating like real blackjack)
	player_hand.append(draw_card())
	dealer_hand.append(draw_card())
	player_hand.append(draw_card())
	dealer_hand.append(draw_card())
	 
	$MarginContainer/VBoxContainer/HitButton.disabled = false
	$MarginContainer/VBoxContainer/StandButton.disabled = false
	
	update_ui(true) #true = hide dealer's first card
	check_blackjack()
func check_blackjack():
	if hand_value(player_hand) == 21:
		end_game("Blackjack! YOU WIN")
func _on_hit():
	player_hand.append(draw_card()) #give player one more card
	update_ui(true)
	if hand_value(player_hand) > 21:
		end_game("Bust! YOU LOSE.")
func _on_stand():
	#Dealer must keep drawing util they reach 17 or more 
	while hand_value(dealer_hand) < 17:
		dealer_hand.append(draw_card())
	update_ui(false) #false = now reveal dealer's card
	resolve_game()
func resolve_game():
	var p = hand_value(player_hand)
	var d = hand_value(dealer_hand)
	
	if d > 21:
		end_game("Dealer busts! YOU WIN")
	elif p > d:
		end_game("YOU WIN")
	elif p < d:
		end_game("Dealer wins")
	else:
		end_game("It's a draw")
func end_game(message: String):
	game_over = true
	$MarginContainer/VBoxContainer/HitButton.disabled = true
	$MarginContainer/VBoxContainer/StandButton.disabled = true
	$MarginContainer/VBoxContainer/NewGameButton.text = message
	update_ui(false)
func update_ui(hide_dealer: bool):
	#remove all old card visuals
	for child in $MarginContainer/VBoxContainer/PlayerHand.get_children():
		child.queue_free()
	for child in $MarginContainer/VBoxContainer/DealerHand.get_children():
		child.queue_free()
		
	#Show player's cards
	for card in player_hand:
		var c = CardScene.instantiate() # create a new card scene
		$MarginContainer/VBoxContainer/PlayerHand.add_child(c) #add it to the player's hand area
		c.setup(card["suit"], card["value"], card["numeric"])
		
	#show dealer's cards
	for i in range(dealer_hand.size()):
		var c = CardScene.instantiate()
		$MarginContainer/VBoxContainer/DealerHand.add_child(c)
		if i == 0 and hide_dealer:
			c.setup("?", "?", 0) #face-down card
		else:
			c.setup(dealer_hand[i]["suit"], dealer_hand[i]["value"], dealer_hand[i]["numeric"])
			
			#update score text
	$MarginContainer/VBoxContainer/Playerlabel.text = "Player: %d " % hand_value(player_hand)
	$MarginContainer/VBoxContainer/Dealerlabel.text = "Dealer: ?" if hide_dealer else "Dealer: %d" %hand_value(dealer_hand)
	if not game_over:
		$MarginContainer/VBoxContainer/ScoreLabel.text = ""
