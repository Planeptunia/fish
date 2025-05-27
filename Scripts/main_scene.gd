extends Node2D
var money = 0

var buildingButton = preload("res://Scenes/building_button.tscn")

var buildings
var buildingsList = {}

var upgrades
var upgradesList = {}
var upgradeButton = preload("res://Scenes/upgrade_button.tscn")

var options
var savedata

func _init():
	pass

# Called when the node enters the scene tree for the first time.
func _ready():
	load_buildings()
	load_upgrades()
	savedata = load_data()
	options = load_settings(savedata['settings'])
	load_save(savedata['savedata'])
	get_tree().set_auto_accept_quit(false)


func on_pressed(buildingId):
	var building_price = buildingsList[buildingId].get_info().y
	if money >= building_price:
		buildingsList[buildingId].change_amount(buildingsList[buildingId].get_info().x + 1)
		money -= building_price
		update_money()
		$sfx_player.stream = load("res://Sounds/positive.wav")
		$sfx_player.play()
	else:
		$sfx_player.stream = load("res://Sounds/negative.wav")
		$sfx_player.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	process_stats()
	
func _physics_process(delta):
	var mps = 0
	for building in buildingsList:
		var building_amount = buildingsList[building].get_info().x
		mps += building_amount * (buildings['buildings'][building]['mps'] * buildingsList[building].properties['mps_multiplier'])
	$Control/Control2/mps.text = "SPS: {mps}".format({'mps': mps})
	money += mps / 60
	update_money()

func _on_fish_click_pressed():
	var click_increase = 0
	for building in buildingsList:
		click_increase += buildingsList[building].properties['click_increase']
	money += 1 + click_increase
	var random_rotation = randf_range(-.2, .2)
	$Control/fish_click.rotation = 0
	$Control/fish_click.rotation = random_rotation
	$sfx_player.stream = load("res://Sounds/click.wav")
	$sfx_player.play()
	update_money()
	
func update_money():
	var sign
	if options["short_numbers"]:
		var shown_money = money
		if (money / 1000) < 1000 and (money / 1000) >= 1:
			sign = "k"
			shown_money = money / 1000
			$Control/Control2/money.text = str(snappedf(shown_money, 0.01)) + " " + sign
		elif (money / 1000000) < 1000 and (money / 1000000) >= 1:
			sign = "m"
			shown_money = money / 1000000
			$Control/Control2/money.text = str(snappedf(shown_money, 0.01)) + " " + sign
		$Control/Control2/money.text = str(snappedf(money, 1))
	else: $Control/Control2/money.text = str(snappedf(money, 1))

func _on_options_b_pressed():
	$Control/tabs_for_option_stats_info.set_current_tab(1)

func _on_info_b_pressed():
	$Control/tabs_for_option_stats_info.set_current_tab(0)
	
func _on_stats_b_pressed():
	$Control/tabs_for_option_stats_info.set_current_tab(2)


func _on_music_volume_value_changed(value):
	value = snappedf(value, 0.01) * 100
	$Control/tabs_for_option_stats_info/Settings/music_percent.text = str(value) + "%"

func _on_sfx_volume_value_changed(value):
	value = snappedf(value, 0.01) * 100
	$Control/tabs_for_option_stats_info/Settings/sfx_percent.text = str(value) + "%"

func load_buildings():
	var json = JSON.new()

	buildings = FileAccess.open("res://saves/buildings.json", FileAccess.READ)
	buildings = buildings.get_as_text()
	buildings = json.parse_string(buildings)
	for building in buildings['buildings'].keys():
		var newbuilding = buildingButton.instantiate()
		buildingsList[building] = newbuilding
		buildingsList[building].id = building
		if 'price_multiplier' in buildings['buildings'][building].keys():
			buildingsList[building].properties['price_multiplier'] = buildings['buildings'][building]['price_multiplier']
		if 'mps_multiplier' in buildings['buildings'][building].keys():
			buildingsList[building].properties['mps_multiplier'] = buildings['buildings'][building]['mps_multiplier']
		if 'click_increase' in buildings['buildings'][building].keys():
			buildingsList[building].properties['click_increase'] = buildings['buildings'][building]['click_increase']
		buildingsList[building].properties['baseCost'] = buildings['buildings'][building]['price']
		buildingsList[building].change_icon(buildings['buildings'][building]['icon'])
		buildingsList[building].change_price(buildings['buildings'][building]['price'])
		buildingsList[building].change_name(buildings['buildings'][building]['name'])
		buildingsList[building].clicked.connect(on_pressed)
		$Control/tabs_for_buildings_upgrades/Buildings/Control.add_child(newbuilding)
	$Control/tabs_for_buildings_upgrades/Buildings/Control.custom_minimum_size = Vector2(635, (buildingsList.size() * 110) + 110)

func load_upgrades():
	var json = JSON.new()

	upgrades = FileAccess.open("res://saves/upgrades.json", FileAccess.READ)
	upgrades = upgrades.get_as_text()
	upgrades = json.parse_string(upgrades)
	for upgrade in upgrades['upgrades'].keys():
		var newupgrade = upgradeButton.instantiate()
		upgradesList[upgrade] = newupgrade
		upgradesList[upgrade].id = upgrade
		upgradesList[upgrade].price = upgrades['upgrades'][upgrade]['price']
		for effect in upgrades['upgrades'][upgrade]['effects'].keys():
			upgradesList[upgrade]['effects'][effect] = upgrades['upgrades'][upgrade]['effects'][effect]
		upgradesList[upgrade].change_name(upgrades['upgrades'][upgrade]['name'])

		upgradesList[upgrade].clicked.connect(on_upgrade_pressed)
		$Control/tabs_for_buildings_upgrades/Upgrades.add_child(newupgrade)

func on_upgrade_pressed(upgradeId):
	if money >= upgradesList[upgradeId].price:
		money -= upgradesList[upgradeId].price
		upgradesList[upgradeId].applied = true
		match upgradesList[upgradeId]['effects']['action']:
			"add":
				buildingsList[upgradesList[upgradeId]['effects']['building']]['properties'][upgradesList[upgradeId]['effects']['effect']] += upgradesList[upgradeId]['effects']['value']
			"remove":
				buildingsList[upgradesList[upgradeId]['effects']['building']]['properties'][upgradesList[upgradeId]['effects']['effect']] -= upgradesList[upgradeId]['effects']['value']
			"multiply":
				buildingsList[upgradesList[upgradeId]['effects']['building']]['properties'][upgradesList[upgradeId]['effects']['effect']] *= upgradesList[upgradeId]['effects']['value']
			"set":
				buildingsList[upgradesList[upgradeId]['effects']['building']]['properties'][upgradesList[upgradeId]['effects']['effect']] = upgradesList[upgradeId]['effects']['value']
			"thousand_wires":
				var amount_b = 0
				for building in buildingsList:
					amount_b += buildingsList[building].get_info().x
				buildingsList[upgradesList[upgradeId]['effects']['building']]['properties'][upgradesList[upgradeId]['effects']['effect']] += (upgradesList[upgradeId]['effects']['value'] * amount_b)
				
		upgradesList[upgradeId].disabled = true
		$sfx_player.stream = load("res://Sounds/positive.wav")
		$sfx_player.play()
	else: 
		$sfx_player.stream = load("res://Sounds/negative.wav")
		$sfx_player.play()

func load_data():
	var json = JSON.new()
	
	var data = FileAccess.open("res://saves/save.json", FileAccess.READ)
	data = data.get_as_text()
	data = json.parse_string(data)
	return data

func load_save(save):
	money = save['money']
	for building in save['buildings'].keys():
		buildingsList[building].change_amount(save['buildings'][building])
	for upgrade in save['upgrades'].keys():
		upgradesList[upgrade].applied = save['upgrades'][upgrade]

func load_settings(settings):
	$Control/tabs_for_option_stats_info/Settings/mus_volume.value = settings['music_volume']
	if	$Control/tabs_for_option_stats_info/Settings/mus_volume.value == 0:
		$music_player.volume_db = -80
	else:
		$music_player.volume_db = linear_to_db(settings['music_volume'])
	$Control/tabs_for_option_stats_info/Settings/sfx_volume.value = settings['sfx_volume']
	if	$Control/tabs_for_option_stats_info/Settings/sfx_volume.value == 0:
		$sfx_player.volume_db = -80
	else:
		$sfx_player.volume_db = linear_to_db(settings['music_volume'])
	$Control/tabs_for_option_stats_info/Settings/short_num_toggle.button_pressed = settings['short_numbers']
	$Control/tabs_for_option_stats_info/Settings/auto_save_toggle.button_pressed = settings['save_on_exit']
	return settings

func save_data():
	savedata['savedata']['money'] = money
	for building in buildingsList.keys():
		savedata['savedata']['buildings'][building] = buildingsList[building].amount
	for upgrade in upgradesList.keys():
		savedata['savedata']['upgrades'][upgrade] = upgradesList[upgrade].applied

func save_settings():
	options['music_volume'] = $Control/tabs_for_option_stats_info/Settings/mus_volume.value
	$music_player.volume_db = linear_to_db($Control/tabs_for_option_stats_info/Settings/mus_volume.value)
	options['sfx_volume'] = $Control/tabs_for_option_stats_info/Settings/sfx_volume.value
	$sfx_player.volume_db = linear_to_db($Control/tabs_for_option_stats_info/Settings/sfx_volume.value)
	options['short_numbers'] = $Control/tabs_for_option_stats_info/Settings/short_num_toggle.button_pressed
	options['save_on_exit'] = $Control/tabs_for_option_stats_info/Settings/auto_save_toggle.button_pressed

func write_to_save():
	save_data()
	save_settings()
	savedata['settings'] = options
	var json = JSON.new()
	var data = json.stringify(savedata, "\t")
	var file = FileAccess.open("res://saves/save.json", FileAccess.WRITE)
	file.store_line(data)
	file.close()
	$Control/save_icon.position = get_viewport().get_mouse_position()
	$Control/save_icon.visible = true
	$Control/save_icon/save_icon_timer.start()

func wipe_save():
	money = 0
	for building in buildingsList.keys():
		buildingsList[building].change_amount(0)
		buildingsList[building].change_price(buildingsList[building].properties['baseCost'])
		if 'price_multiplier' in buildings['buildings'][building].keys():
			buildingsList[building].properties['price_multiplier'] = buildings['buildings'][building]['price_multiplier']
		else: buildingsList[building].properties['price_multiplier'] = 1.13
		if 'mps_multiplier' in buildings['buildings'][building].keys():
			buildingsList[building].properties['mps_multiplier'] = buildings['buildings'][building]['mps_multiplier']
		else: buildingsList[building].properties['mps_multiplier'] = 1
		if 'click_increase' in buildings['buildings'][building].keys():
			buildingsList[building].properties['click_increase'] = buildings['buildings'][building]['click_increase']
		else: buildingsList[building].properties['click_increase'] = 0
	for upgrade in upgradesList.keys():
		upgradesList[upgrade].applied = false
		upgradesList[upgrade].disabled = false
	$Control/save_icon.play('discett_wipe_animation')
	write_to_save()
	await $Control/save_icon/save_icon_timer.timeout
	$Control/save_icon.play('discett_save_png')

func disable_save_icon():
	$Control/save_icon.visible = false

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		if options['save_on_exit']:
			write_to_save()
			await $Control/save_icon/save_icon_timer.timeout
		get_tree().quit()

func process_stats():
	$Control/tabs_for_option_stats_info/statistics/Control/stats/fish_scales.text = "Current amount of Scales: [b]{money}[/b]".format({'money': snappedf(money, 1)})

func _on_buildings_choice_pressed():
	$Control/tabs_for_buildings_upgrades.set_current_tab(0)


func _on_upgrades_choice_pressed():
	$Control/tabs_for_buildings_upgrades.set_current_tab(1)
