extends Panel
#these variable stores the card's infromation

var suit: String #card's color
var value: String #A,2,3......K
var numeric_value:int #the actual number used in scoring

#this function sets up the card with real data
func setup(s: String, v: String, n: int):
	suit = s
	value = v
	numeric_value = n
	$Label.text = value + "\n" + suit

	# White card background with rounded corners
	var style = StyleBoxFlat.new()
	style.bg_color = Color.WHITE
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6
	add_theme_stylebox_override("panel", style)

	# Red for hearts/diamonds, dark for spades/clubs
	if suit == "♥" or suit == "♦":
		$Label.add_theme_color_override("font_color", Color.RED)
	else:
		$Label.add_theme_color_override("font_color", Color(0.1, 0.1, 0.1))
	
		
	
	
