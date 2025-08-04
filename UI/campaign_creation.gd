extends Panel

var campaign_price = 500

# Contains logic for influence alteration requests to server

func _on_option_button_item_selected(index):
	if index == 0:
		campaign_price = 500
	if index == 1:
		campaign_price = 1500
	if index == 2:
		campaign_price = 5000
	
	
	update_campaign_price()


func update_campaign_price():
	$CampaignButton.text = "Create " + str(campaign_price) + "🪙"

func create_campaign():
	pass

func _on_campaign_button_pressed():
	create_campaign()
	self.hide()
