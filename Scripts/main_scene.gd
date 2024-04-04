extends Node2D
var money = 0

var upgradeButton = preload("res://Scenes/upgrade_button.tscn")

var upgrades
var upgradesList = {}

var options
var savedata

func _init():
	pass

# Called when the node enters the scene tree for the first time.
func _ready():
	load_upgrades()
	savedata = load_data()
	options = load_settings(savedata['settings'])
	load_save(savedata['savedata'])
	get_tree().set_auto_accept_quit(false)


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
	var click_increase = 0
	for upgrade in upgradesList:
		click_increase += upgradesList[upgrade].click_increase
	money += 1 + click_increase
	var random_rotation = randi_range(-15, 15)
	$Control/fish_click.rotation = 0
	$Control/fish_click.rotation = random_rotation
	update_money()
	
func update_money():
	var sign
	if options["short_numbers"]:
		var shown_money
		if (money / 1000) < 1000 and (money / 1000) > 0:
			sign = "k"
			shown_money = money / 1000
		elif (money / 1000000) < 1000 and (money / 1000) > 0:
			sign = "m"
			shown_money = money / 1000000
		$Control/Control2/money.text = str(snappedf(shown_money, 0.01)) + " " + sign
	else: $Control/Control2/money.text = str(snappedf(money, 1))

func _on_options_b_pressed():
	$Control/TabContainer.set_current_tab(1)

func _on_info_b_pressed():
	$Control/TabContainer.set_current_tab(0)
	
func _on_stats_b_pressed():
	$Control/TabContainer.set_current_tab(2)


func _on_music_volume_value_changed(value):
	$Control/TabContainer/Settings/music_percent.text = str(value) + "%"

func _on_sfx_volume_value_changed(value):
	$Control/TabContainer/Settings/sfx_percent.text = str(value) + "%"

func load_upgrades():
	var json = JSON.new()

	upgrades = FileAccess.open("res://upgrades.json", FileAccess.READ)
	upgrades = upgrades.get_as_text()
	upgrades = json.parse_string(upgrades)
	for upgrade in upgrades['upgrades'].keys():
		var newUpgrade = upgradeButton.instantiate()
		upgradesList[upgrade] = newUpgrade
		upgradesList[upgrade].id = upgrade
		if 'price_multiplier' in upgrades['upgrades'][upgrade].keys():
			upgradesList[upgrade].price_multiplier = upgrades['upgrades'][upgrade]['price_multiplier']
		if 'mps_multiplier' in upgrades['upgrades'][upgrade].keys():
			upgradesList[upgrade].mps_multiplier = upgrades['upgrades'][upgrade]['mps_multiplier']
		if 'click_increase' in upgrades['upgrades'][upgrade].keys():
			upgradesList[upgrade].click_increase = upgrades['upgrades'][upgrade]['click_increase']
		upgradesList[upgrade].baseCost = upgrades['upgrades'][upgrade]['price']
		upgradesList[upgrade].change_icon(upgrades['upgrades'][upgrade]['icon'])
		upgradesList[upgrade].change_price(upgrades['upgrades'][upgrade]['price'])
		upgradesList[upgrade].change_name(upgrades['upgrades'][upgrade]['name'])
		upgradesList[upgrade].clicked.connect(on_pressed)
		$Control/scroll_container/Control.add_child(newUpgrade)
	$Control/scroll_container/Control.custom_minimum_size = Vector2(635, (upgradesList.size() * 110) + 110)

func load_data():
	var json = JSON.new()
	
	var data = FileAccess.open("res://save.json", FileAccess.READ)
	data = data.get_as_text()
	data = json.parse_string(data)
	return data

func load_save(save):
	money = save['money']
	for upgrade in save['upgrades'].keys():
		upgradesList[upgrade].change_amount(save['upgrades'][upgrade])

func load_settings(settings):
	$Control/TabContainer/Settings/mus_volume.value = settings['music_volume']
	$Control/TabContainer/Settings/sfx_volume.value = settings['sfx_volume']
	$Control/TabContainer/Settings/short_num_toggle.button_pressed = settings['short_numbers']
	return settings

func save_data():
	savedata['savedata']['money'] = money
	for upgrade in upgradesList.keys():
		savedata['savedata']['upgrades'][upgrade] = upgradesList[upgrade].amount

func save_settings():
	options['music_volume'] = $Control/TabContainer/Settings/mus_volume.value
	options['sfx_volume'] = $Control/TabContainer/Settings/sfx_volume.value
	options['short_numbers'] = $Control/TabContainer/Settings/short_num_toggle.button_pressed

func write_to_save():
	save_data()
	save_settings()
	savedata['settings'] = options
	var json = JSON.new()
	var data = json.stringify(savedata, "\t")
	var file = FileAccess.open("res://save.json", FileAccess.WRITE)
	file.store_line(data)
	file.close()
	$Control/save_icon.visible = true
	$Control/save_icon/save_icon_timer.start()

func wipe_save():
	money = 0
	for upgrade in upgradesList.keys():
		upgradesList[upgrade].change_amount(0)
	write_to_save()

func disable_save_icon():
	$Control/save_icon.visible = false

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		write_to_save()
		await $Control/save_icon/save_icon_timer.timeout
		get_tree().quit()
