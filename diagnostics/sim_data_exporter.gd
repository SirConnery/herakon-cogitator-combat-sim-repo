class_name SimDataExporter
extends RefCounted

var _buffer: Array[Array] = []
var _buffer_limit := 10000

# Default fallback path, dynamically overwritten by the simulation controller
var file_path_binary := "user://simulation_raw_data.dat"

func clear_previous_data() -> void:
	# Wipe old logs before starting a fresh generation loop
	var _file = FileAccess.open(file_path_binary, FileAccess.WRITE)
	_buffer.clear()


## Buffers individual match details as compact primitive arrays containing faction identifiers
func log_match(match_index: int, stage: int, attacker_id: int, defender_id: int, attacker_won: bool, atk_deck: Array, def_deck: Array) -> void:
	var match_record = [
		match_index,               # Index 0
		stage,                     # Index 1
		attacker_id,               # Index 2
		defender_id,               # Index 3
		1 if attacker_won else 0,  # Index 4
		atk_deck,                  # Index 5
		def_deck                   # Index 6
	]
	_buffer.append(match_record)
	
	if _buffer.size() >= _buffer_limit:
		flush_to_disk()


## Flushes memory cache into a binary format file stream
func flush_to_disk() -> void:
	if _buffer.is_empty(): 
		return
		
	var file: FileAccess
	if FileAccess.file_exists(file_path_binary):
		file = FileAccess.open(file_path_binary, FileAccess.READ_WRITE)
		file.seek_end()
	else:
		file = FileAccess.open(file_path_binary, FileAccess.WRITE)
		
	if file:
		for record in _buffer:
			file.store_var(record)
		_buffer.clear()


## Translates the multi-faction binary log cleanly into a massive tabular CSV spreadsheet
func export_current_to_csv(csv_destination_path: String) -> void:
	flush_to_disk() # Pull down outstanding cache blocks first
	
	if not FileAccess.file_exists(file_path_binary):
		push_error("Export Failed: No source raw simulation data file found at: " + file_path_binary)
		return
		
	var read_file = FileAccess.open(file_path_binary, FileAccess.READ)
	var write_file = FileAccess.open(csv_destination_path, FileAccess.WRITE)
	
	if not read_file or not write_file:
		return
		
	write_file.store_line("MatchIndex,Stage,AttackerID,DefenderID,AttackerWon,AttackerDeck,DefenderDeck")
	
	print("Converting binary data stream [%s] to CSV..." % file_path_binary.get_file())
	
	while read_file.get_position() < read_file.get_length():
		var data = read_file.get_var()
		if data is Array and data.size() >= 7:
			
			var atk_string_array: PackedStringArray = []
			for card_id in data[5]:
				atk_string_array.append(str(card_id))
				
			var def_string_array: PackedStringArray = []
			for card_id in data[6]:
				def_string_array.append(str(card_id))
			
			# 🎯 UPDATED: Variables renamed to track complete arrays safely inside table cells
			var atk_deck_str = ";".join(atk_string_array) 
			var def_deck_str = ";".join(def_string_array)
			
			var line := "%d,%d,%d,%d,%d,%s,%s" % [
				data[0], # MatchIndex
				data[1], # Stage
				data[2], # AttackerID
				data[3], # DefenderID
				data[4], # AttackerWon
				atk_deck_str, 
				def_deck_str
			]
			write_file.store_line(line)
			
	print("CSV Export Successful: Target matrix file saved to -> " + csv_destination_path)
