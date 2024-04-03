extends Node2D
var money = 0

var upgradeButton = preload("res://upgrade_button.tscn")

var upgrades
var upgradesList = {}

func _init():
	pass

# Called when the node enters the scene tree for the first time.
func _ready():
	
	update_money()
	
	upgrades = FileAccess.open("res://upgrades.json", FileAccess.READ)
	upgrades = upgrades.get_as_text()
	var json = JSON.new()
	upgrades = json.parse_string(upgrades)
	for upgrade in upgrades['upgrades'].keys():
		var newUpgrade = upgradeButton.instantiate()
		upgradesList[upgrade] = newUpgrade
		upgradesList[upgrade].id = upgrade
		if 'price_multiplier' in upgrades['upgrades'][upgrade].keys():
			print(upgrades['upgrades'][upgrade].keys())
			upgradesList[upgrade].price_multiplier = upgrades['upgrades'][upgrade]['price_multiplier']
		if 'mps_multiplier' in upgrades['upgrades'][upgrade].keys():
			print(upgrades['upgrades'][upgrade].keys())
			upgradesList[upgrade].mps_multiplier = upgrades['upgrades'][upgrade]['mps_multiplier']
		upgradesList[upgrade].baseCost = upgrades['upgrades'][upgrade]['price']
		upgradesList[upgrade].change_icon(upgrades['upgrades'][upgrade]['icon'])
		upgradesList[upgrade].change_price(upgrades['upgrades'][upgrade]['price'])
		upgradesList[upgrade].change_name(upgrades['upgrades'][upgrade]['name'])
		upgradesList[upgrade].clicked.connect(on_pressed)
		$Control/scroll_container/Control.add_child(newUpgrade)
	$Control/scroll_container/Control.custom_minimum_size = Vector2(635, (upgradesList.size() * 110) + 110)

func on_pressed(upgradeId):
	var upgrade_price = upgradesList[upgradeId].get_info().y
	if money >= upgrade_price:
		upgradesList[upgradeId].change_amount(upgradesList[upgradeId].get_info().x + 1)
		money -= upgrade_price
		update_money()
	else: print("no money")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _physics_process(delta):
	var mps = 0
	for upgrade in upgradesList:
		var upgrade_amount = upgradesList[upgrade].get_info().x
		mps += (upgrade_amount * upgrades['upgrades'][upgrade]['mps']) * upgradesList[upgrade].mps_multiplier
	money += mps / 60
	update_money()

func _on_fish_click_pressed():
	money += 1
	update_money()
	
func update_money():
	$Control/Control2/money.text = str(snappedf(money, 1))
