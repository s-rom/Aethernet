extends PanelContainer
class_name StationTable

var _linked_station: Station = null


func link_station(station: Station):
	_linked_station = station
	_linked_station.tableUpdated.connect(update_data)
	_linked_station.tree_exited.connect(remove_table)
	$MarginContainer/VBoxContainer/MetaHeader/StationName.text = _linked_station.name
	update_data()


func remove_table():
	self.queue_free()


func _get_shorted_string(value: String) -> String:
	if value.length() < 2:
		return value
	return value[0] + "" + value[-1]

func update_data():
	var table = _linked_station.get_port_table_gui() as Dictionary

	var coordLabels = [
		$MarginContainer/VBoxContainer/Row1/V,
		$MarginContainer/VBoxContainer/Row2/V,
		$MarginContainer/VBoxContainer/Row3/V,
		$MarginContainer/VBoxContainer/Row4/V
	]
	
	var portLabels = [
		$MarginContainer/VBoxContainer/Row1/P,
		$MarginContainer/VBoxContainer/Row2/P,
		$MarginContainer/VBoxContainer/Row3/P,
		$MarginContainer/VBoxContainer/Row4/P
	]
	
	var index = 0
	for portName in table.keys():
		var coord = table[portName]
		
		(portLabels[index] as Label).text = _get_shorted_string(portName)
		(coordLabels[index] as Label).text = coord
		
		index += 1
