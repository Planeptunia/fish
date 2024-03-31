extends Node2D
var money = 0
var multiplier = 1
var click = 1
var price1 = 15
var price2 = 100
var price3 = 500
var price4 = 3000
var price5 = 10000
var price6 = 40000
var price7 = 200000
var price8 = 1666666
var price9 = 123456789
var price10 = 75000000000
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_fish_click_pressed():
	money += click * multiplier
	get_node("Control/Control2/money").text = str(money)
