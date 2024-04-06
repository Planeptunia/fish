extends Button
signal clicked(id)

var id

var itemIcon = preload("res://Sprites/Sprite-0001.png")

var properties = {'baseCost': 1, 'price_multiplier': 1.13, 'mps_multiplier': 1, 'click_increase': 0}
var price = 0
var amount = 0

func _ready():
	change_amount(self.amount)

func change_icon(newIcon: String):
	var iconRes = load(newIcon)
	$itemIcon.texture = iconRes
	itemIcon = iconRes

func change_price(price: float):
	self.price = price
	$price.text = str(price)

func change_amount(amount: int):
	$amount.text = str(amount)
	self.amount = amount
	self.price = properties['baseCost'] * (properties['price_multiplier'] ** (self.amount))
	self.price = snappedf(self.price, 1)
	$price.text = str(self.price)

func change_name(name: String):
	$name.text = name

func get_info():
	return Vector2(self.amount, self.price)

func _on_pressed():
	clicked.emit(id)
