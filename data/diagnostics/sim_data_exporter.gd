class_name SimDataExporter
extends RefCounted

var _buffer: Array[Array] = []
var _buffer_limit := 10000

var file_path_binary := "user://simulation_raw_data.dat"

func clear_previous_data() -> void:
	# Wipe old logs before starting a fresh generation loop
	var _file = FileAccess.open(file_path_binary, FileAccess.WRITE)
	_buffer.clear()


## Buffers individual match details as compact primitive arrays containing faction identifiers
func log_match(match_index: int, stage: int, attacker_id: int, defender_id: int, attacker_won: bool, atk_hand: Array, def_hand: Array) -> void:
	var match_record = [
		match_index,               # Index 0
		stage,                     # Index 1
		attacker_id,               # Index 2
		defender_id,               # Index 3
		1 if attacker_won else 0,  # Index 4
		atk_hand,                  # Index 5
		def_hand                   # Index 6
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
		push_error("Export Failed: No source raw simulation data file found.")
		return
		
	var read_file = FileAccess.open(file_path_binary, FileAccess.READ)
	var write_file = FileAccess.open(csv_destination_path, FileAccess.WRITE)
	
	if not read_file or not write_file:
		return
		
	# Write updated CSV Header line with new identity columns
	write_file.store_line("MatchIndex,Stage,AttackerID,DefenderID,AttackerWon,AttackerHand,DefenderHand")
	
	while read_file.get_position() < read_file.get_length():
		var data = read_file.get_var()
		if data is Array:
			# Shift index mapping over to align with updated record architecture
			var atk_hand_str = ";".join(data[5]) # Semi-colons keep arrays safe inside individual cells
			var def_hand_str = ";".join(data[6])
			
			var line := "%d,%d,%d,%d,%d,%s,%s" % [
				data[0], # MatchIndex
				data[1], # Stage
				data[2], # AttackerID
				data[3], # DefenderID
				data[4], # AttackerWon
				atk_hand_str, 
				def_hand_str
			]
			write_file.store_line(line)
			
	print("CSV Export Successful: Target matrix file saved to -> " + csv_destination_path)
