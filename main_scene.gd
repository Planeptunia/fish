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
	var multiplier = 1.10
	var n = 1
	var money_per_second
	func _init_(price, mnp):
		self.price = price
		self.mnp = mnp
	func when_pressed():
		self.price = self.price * multiplier ** (n + 1)
		money_per_second += self.mnp 
		self.mnp = self.mnp * multiplier ** (n + 1)

var ls = [0, 1, 44, 5, 6]
var prices = [100, 200, 300, 400, 500]
var mps = [1, 2, 3, 4, 5]
var monps = 0
func _when_pressed(upgrade):
	for i in ls:
		if money < prices[i]:
			pass
		n = ls[i]
		prices[i] = prices[i] * multiplier ** (n + 1)
		monps += mps[i] * n


func _on_fish_click_pressed():
	money += click * multiplier
	get_node("Control/Control2/money").text = str(money)

