extends Control

var ruleControl = preload("res://GUI/PortalTable/PortalRule.tscn")
@export var rulesContainer: Control

@export var targetNetworkLineEdit: LineEdit
@export var nextHopLineEdit: LineEdit
@export var nameLabel: Label

var _linkedPortal: Portal = null

func _ready():
	pass
	
func _process(delta):
	pass

func linkPortal(portal: Portal):
	nameLabel.text = portal.name
	_linkedPortal = portal
	updateRulesDisplay()

func updateRulesDisplay():
	for ruleItem in rulesContainer.get_children():
		ruleItem.queue_free()
	
	var newRules = _linkedPortal.get_rules_string()
	for rule in newRules:
		var ruleScn = ruleControl.instantiate() as PortalRule
		ruleScn.set_values(rule)
		ruleScn.connect("delete_rule", _on_delete_rule)
		rulesContainer.add_child(ruleScn)
		

func unlink():
	_linkedPortal = null

func _on_button_pressed():
	print("Add rule button pressed")
	
	if not _linkedPortal:
		print("[ERROR] Tried to add a rule but no Portal is selected") 
		return
	
	print("Adding rule: " + targetNetworkLineEdit.text + " via " + nextHopLineEdit.text)
	_linkedPortal.add_rule(targetNetworkLineEdit.text, nextHopLineEdit.text)
	updateRulesDisplay()

func _on_delete_rule(ruleString: String):
	print("Deleting rule that targets network " + ruleString)
	_linkedPortal.delete_rule_from_string(ruleString)
	updateRulesDisplay()
