extends Node2D
var money = 0
var timer
# Множитель увелечения цен строений и заробатка в секунду за одну покупку
# new_price = last_price * multiplier^n+1 | n = 1
var multiplier = 1.10
var click = 1
var n = 1
var money_per_second = 0
var mnp = 0
# Цены строений
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
var price = 0
func init():
	timer = Timer.new()
	add_child(timer)
	timer.autostart = true
	timer.wait_time = 1
	timer.connect("timeout", self, "_timeout")

func _timeout():
	money += money_per_second

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

class towers:
	func _init_(price, mnp):
		self.price = price
		self.mnp = mnp
	func when_pressed():
		self.price = self.price * multiplier ** (n + 1)
		money_per_second += self.mnp 
		self.mnp = self.mnp * multiplier ** (n + 1)
func _on_fish_click_pressed():
	money += click * multiplier
	get_node("Control/Control2/money").text = str(money)


func _on_mech_arm_pressed():
	price1 = price1 * multiplier ** (n + 1)
	money_per_second += mnp 

func _on_fisherman_pressed():
	price2 = price2 * multiplier ** (n + 1)


func _on_lakes_pressed():
	price3 = price3 * multiplier ** (n + 1)


func _on_fish_sellers_pressed():
	price4 = price4 * multiplier ** (n + 1)


func _on_bank_pressed():
	price5 = price5 * multiplier ** (n + 1)


func _on_a_small_part_of_the_sea_pressed():
	price6 = price6 * multiplier ** (n + 1)


func _on_temple_pressed():
	price7 = price7 * multiplier ** (n + 1)


func _on_laboratory_pressed():
	price8 = price8 * multiplier ** (n + 1)


func _on_spaceship_pressed():
	price9 = price9 * multiplier ** (n + 1)


func _on_mage_towers_pressed():
	price10 = price10 * multiplier ** (n + 1)
