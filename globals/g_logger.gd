extends Node

const ARROWS_COUNTERCLOCKWISE = preload("uid://865pnryo3ujp")
const AXE = preload("uid://cjqm3odnptdox")
const BOOM = preload("uid://bb86pf3ujv2ll")
const BRAIN = preload("uid://cib2wu76oigcs")
const CARD_INDEX = preload("uid://cgj0u2io8yxbh")
const CHECKERED_FLAG = preload("uid://cgqk18tlfu8ki")
const CROSSED_SWORDS = preload("uid://bdhga5ctungo4")
const CRYSTAL_BALL = preload("uid://i1kke1ijr24r")
const DISCARD_HARVEST = preload("uid://cdc5bhhw22cmp")
const FALLBACK_CONDITION = preload("uid://olgrn53fh3uc")
const FAST_FORWARD = preload("uid://dyk4ksxen13eo")
const FLOWER_PLAYING_CARDS = preload("uid://fsarkovhf8ll")
const GAME_DICE = preload("uid://b51b7ogv3v08x")
const GLOBAL_EFFECT = preload("uid://b4o6suck4tg0e")
const GUARD = preload("uid://c7y0855sdtlee")
const INNER_ABILITY = preload("uid://cu8d75tcp48y6")
const LARGE_BLUE_SQUARE = preload("uid://c3mh1p2tbkpbn")
const LARGE_RED_SQUARE = preload("uid://cqy2rgwfkk0k0")
const MEDAL = preload("uid://cq63x40y4n0ki")
const RALLY = preload("uid://io1te3a6p5pw")
const SAVED_FROM_DESTRUCTION = preload("uid://gnlrlamg1kuo")
const SCAN = preload("uid://cqcwgny2oqivw")
const SHIELD = preload("uid://bnr4nvio4fy5f")
const SKULL = preload("uid://bbthodxg0r8d2")
const TOKEN = preload("uid://cruigmoxlb8r0")
const WARNING = preload("uid://eoi5qeurd3od")
const WAVING_WHITE_FLAG = preload("uid://cdxydf02sdra5")
const X = preload("uid://b8f60ffd8wqla")
const ZAP = preload("uid://desyroq2a3rp4")

# 🎰 INLINE BBCODE TEXTURE PATH STRINGS (Sized to match console lines)
@onready var IMG_AXE: String = "[img=18]" + AXE.get_path() + "[/img]"
@onready var IMG_BLUE_SQUARE: String = "[img=18]" + LARGE_BLUE_SQUARE.get_path() + "[/img]"
@onready var IMG_BOOM: String = "[img=18]" + BOOM.get_path() + "[/img]"
@onready var IMG_BRAIN: String = "[img=18]" + BRAIN.get_path() + "[/img]"
@onready var IMG_CARDS_PLAYED: String = "[img=18]" + FLOWER_PLAYING_CARDS.get_path() + "[/img]"
@onready var IMG_CRYSTAL_BALL: String = "[img=18]" + CRYSTAL_BALL.get_path() + "[/img]"
@onready var IMG_DICE: String = "[img=18]" + GAME_DICE.get_path() + "[/img]"
@onready var IMG_DISCARD: String = "[img=18]" + CARD_INDEX.get_path() + "[/img]"
@onready var IMG_DISCARD_HARVEST: String = "[img=18]" + DISCARD_HARVEST.get_path() + "[/img]"
@onready var IMG_FALLBACK_CONDITION: String = "[img=18]" + FALLBACK_CONDITION.get_path() + "[/img]"
@onready var IMG_FAST_FORWARD: String = "[img=18]" + FAST_FORWARD.get_path() + "[/img]"
@onready var IMG_FLAG: String = "[img=18]" + CHECKERED_FLAG.get_path() + "[/img]"
@onready var IMG_GLOBAL_EFFECT: String = "[img=18]" + GLOBAL_EFFECT.get_path() + "[/img]"
@onready var IMG_GUARD: String = "[img=18]" + GUARD.get_path() + "[/img]"
@onready var IMG_INNER_ABILITY: String = "[img=18]" + INNER_ABILITY.get_path() + "[/img]"
@onready var IMG_MEDAL: String = "[img=18]" + MEDAL.get_path() + "[/img]"
@onready var IMG_RALLY: String = "[img=18]" + RALLY.get_path() + "[/img]"
@onready var IMG_RED_SQUARE: String = "[img=18]" + LARGE_RED_SQUARE.get_path() + "[/img]"
@onready var IMG_REROLL: String = "[img=18]" + ARROWS_COUNTERCLOCKWISE.get_path() + "[/img]"
@onready var IMG_ROUTED: String = "[img=18]" + WAVING_WHITE_FLAG.get_path() + "[/img]"
@onready var IMG_SAVED_FROM_DESTRUCTION: String = "[img=18]" + SAVED_FROM_DESTRUCTION.get_path() + "[/img]"
@onready var IMG_SCAN: String = "[img=18]" + SCAN.get_path() + "[/img]"
@onready var IMG_SHIELD: String = "[img=18]" + SHIELD.get_path() + "[/img]"
@onready var IMG_SKULL: String = "[img=18]" + SKULL.get_path() + "[/img]"
@onready var IMG_SWORD: String = "[img=18]" + CROSSED_SWORDS.get_path() + "[/img]"
@onready var IMG_TOKEN: String = "[img=18]" + TOKEN.get_path() + "[/img]"
@onready var IMG_WARNING: String = "[img=18]" + WARNING.get_path() + "[/img]"
@onready var IMG_X: String = "[img=18]" + X.get_path() + "[/img]"
@onready var IMG_ZAP: String = "[img=18]" + ZAP.get_path() + "[/img]"

# This dict is only for the generic "ability_triggered" log
@onready var ICON_MAP: Dictionary = {
	"axe_icon": IMG_AXE,
	"blue_square_icon": IMG_BLUE_SQUARE,
	"boom_icon": IMG_BOOM,
	"brain_icon": IMG_BRAIN,
	"cards_played_icon": IMG_CARDS_PLAYED,
	"crystal_ball_icon": IMG_CRYSTAL_BALL,
	"dice_icon": IMG_DICE,
	"discard_harvest_icon": IMG_DISCARD_HARVEST,
	"discard_icon": IMG_DISCARD,
	"fallback_condition_icon": IMG_FALLBACK_CONDITION,
	"fast_forward_icon": IMG_FAST_FORWARD,
	"flag_icon": IMG_FLAG,
	"global_effect_icon": IMG_GLOBAL_EFFECT,
	"guard_icon": IMG_GUARD,
	"inner_ability_icon": IMG_INNER_ABILITY,
	"medal_icon": IMG_MEDAL,
	"rally_icon": IMG_RALLY,
	"red_square_icon": IMG_RED_SQUARE,
	"reroll_icon": IMG_REROLL,
	"routed_icon": IMG_ROUTED,
	"saved_from_destruction_icon": IMG_SAVED_FROM_DESTRUCTION,
	"scan_icon": IMG_SCAN,
	"shield_icon": IMG_SHIELD,
	"skull_icon": IMG_SKULL,
	"sword_icon": IMG_SWORD,
	"token_icon": IMG_TOKEN,
	"warning_icon": IMG_WARNING,
	"x_icon": IMG_X,
	"zap_icon": IMG_ZAP
}

var active_round_panels: Array[CombatRoundPanel] = []
var active_round_index: int = 0
var context: Dictionary = {}

# --- PERFORMANCE CACHE STORAGE ---
var cached_atk_name: String = ""
var cached_def_name: String = ""

#region Session Lifecycle

func clear_session() -> void:
	active_round_panels.clear()
	active_round_index = 0
	context.clear()
	cached_atk_name = ""
	cached_def_name = ""


func initialize_battle_logger(initialization_context: Dictionary) -> void:
	active_round_index = 0
	context = initialization_context
	
	# --- OPTIMIZATION: CACHE NAMES ONCE ON STARTUP ---
	cached_atk_name = "Attacker"
	cached_def_name = "Defender"
	
	var raw_factions = FactionRegistry.get_database()
	
	var atk_id = context.get("attacker_faction_id")
	if atk_id != null:
		var atk_profile = raw_factions.get(atk_id)
		if atk_profile:
			cached_atk_name = atk_profile.get("name", "Attacker")
			
	var def_id = context.get("defender_faction_id")
	if def_id != null:
		var def_profile = raw_factions.get(def_id)
		if def_profile:
			cached_def_name = def_profile.get("name", "Defender")


func finalize_battle_logger(attacker_won: bool) -> void:
	print("\n[SANDBOX FINISHED] Combat evaluation engine sequence complete. Winner evaluated: %s"
		% ("ATTACKER" if attacker_won else "DEFENDER"))

#endregion


#region Helpers

func _get_panel() -> CombatRoundPanel:
	if active_round_index < active_round_panels.size():
		return active_round_panels[active_round_index]
	return null


func _role_color(role: String) -> String:
	return "🟥" if role == "Attacker" else "🟦"

func _role_image(role: String) -> String:
	return IMG_RED_SQUARE if role == "Attacker" else IMG_BLUE_SQUARE

#endregion


#region Engine Callback

func engine_callback(event_type: String, data: Array) -> void:
	if event_type == "round_start":
		active_round_index = data[0]

	var current_panel := _get_panel()

	match event_type:

		# =========================================================
		# COMBAT START
		# =========================================================
		"combat_start":
			print("\n==================  STARTED COMBAT ==================")
			var atk_side: Dictionary = data[0]
			var def_side: Dictionary = data[1]
			
			var atk_name: String = atk_side.get("name", "Unknown Faction")
			var def_name: String = def_side.get("name", "Unknown Faction")
			
			for panel in active_round_panels:
				if panel != null:
					panel.set_faction_titles(atk_name, def_name)
					panel.update_unit_displays(true, "Deploying...", "")
					panel.update_unit_displays(false, "Deploying...", "")

		
		# =========================================================
		# UNITS
		# =========================================================
		"unit_status_logged":
			print("💂   Units unrouted and routed -> %s: %s | %s" % [data[0], data[1], data[2]])
			
			if current_panel != null:
				var is_attacker: bool = (data[0] == cached_atk_name)
				var phase_context: String = data[3] if data.size() > 3 else "all"
				
				current_panel.update_unit_displays(is_attacker, data[1], data[2], phase_context)
		
		
		"unit_morale_status_logged":
			var role_label: String = data[0]
			var morale_val: int = data[1]
			var phase_context: String = data[2]
			
			print("🧠     %s Unit 🎖️ %d (%s)" % [role_label, morale_val, phase_context])
			
			if current_panel != null:
				current_panel.set_unit_morale(role_label, morale_val, phase_context)
		# =========================================================
		# DICE
		# =========================================================
		"roll_dice_phase":
			print("\n=== PHASE 1: ROLL DICE PHASE ===")
			
		
		"dice_pool_status_logged":
			print("🎲 %s dice updated (%s) -> %d ⚔️ | %d 🛡️ | %d 🎖️" % [data[0], data[4], data[1], data[2], data[3]])
			
			if current_panel:
				var is_attacker: bool = (data[0] == "Attacker")
				var phase_context: String = data[4]
				current_panel.update_dice_displays(is_attacker, data[1], data[2], data[3], phase_context)
		
		"assess_dmg_step_dice_amounts":
			print("🎲 Modified assessment pools -> %s: %d ⚔️ | %d 🛡️ | %d 🎖️" % [data[0], data[1], data[2], data[3]])
			
			if current_panel:
				var is_attacker: bool = (data[0] == "Attacker")
				current_panel.update_dice_displays(is_attacker, data[1], data[2], data[3], "damage_step")
		
		"bonus_dice_rolled":
			print("🎲 -> %s dice results: +%d ⚔️ | +%d 🛡️ | +%d 🎖️" % [data[0], data[1], data[2], data[3]])
			
			if current_panel:
				var msg := "%s +%d %s +%d %s +%d %s" % [IMG_DICE, data[1], IMG_SWORD, data[2], IMG_SHIELD, data[3], IMG_MEDAL]
				current_panel.append_console_log(msg)
		
		"dice_lost":
			print("🎲 -> %s lost dice: -%d ⚔️ | -%d 🛡️ | -%d 🎖️" % [data[0], data[1], data[2], data[3]])
			
			if current_panel:
				var msg := "%s -%d %s -%d %s -%d %s" % [IMG_DICE, data[1], IMG_SWORD, data[2], IMG_SHIELD, data[3], IMG_MEDAL]
				current_panel.append_console_log(msg)
		
		"dice_rerolled_log":
			print("🔄 [%s] Reroll: Lost 1 %s die -> Gained 1 %s die" % [data[0], data[1], data[2]])
			
			if current_panel:
				var msg := "%s -1 %s +1 %s" % [IMG_REROLL, str(data[1]), str(data[2])]
				current_panel.append_console_log(msg)
		
		"dice_converted":
			# Multi-type map ensures compatibility whether engine passes text, indices, or emojis
			var stat_icons := {
				"Offense": IMG_SWORD, "OFFENCE": IMG_SWORD, 1: IMG_SWORD,
				"Defense": IMG_SHIELD, "DEFENCE": IMG_SHIELD, 2: IMG_SHIELD,
				"Morale": IMG_MEDAL, "MORALE": IMG_MEDAL, 3: IMG_MEDAL
			}
			var stat_emojis := {
				"Offense": "⚔️", "OFFENCE": "⚔️", 1: "⚔️",
				"Defense": "🛡️", "DEFENCE": "🛡️", 2: "🛡️",
				"Morale": "🎖️", "MORALE": "🎖️", 3: "🎖️"
			}
			
			var role: String = data[0]
			var from_count: int = data[1]
			var from_stat = data[2]
			var to_count: int = data[3]
			var to_stat = data[4]
			
			var src_icon: String = stat_icons.get(from_stat, IMG_DICE)
			var tgt_icon: String = stat_icons.get(to_stat, IMG_DICE)
			var src_emo: String = stat_emojis.get(from_stat, "🎲")
			var tgt_emo: String = stat_emojis.get(to_stat, "🎲")
			
			print("🎲 -> %s converted dice: %d %s into %d %s" % [role, from_count, src_emo, to_count, tgt_emo])
			
			if current_panel:
				# Formats cleanly as: [Reroll] 2 [Sword] [Fast-Forward] +2 [Shield]
				var msg := "%s %d %s %s +%d %s" % [IMG_REROLL, from_count, src_icon, IMG_FAST_FORWARD, to_count, tgt_icon]
				current_panel.append_console_log(msg)
		
		"batch_dice_roll":
			var card_id: int = data[0]
			var target_role: String = data[1]
			var is_all_flush: bool = data[2]
			var actual_reroll_count: int = data[3]
			var pool_label: String = data[4]
			var removed_o: int = data[5]
			var removed_d: int = data[6]
			var removed_m: int = data[7]
			var added_o: int = data[8]
			var added_d: int = data[9]
			var added_m: int = data[10]

			var log_prefix := "Batch Roll Resolved %s:" % target_role if is_all_flush else "Tactical Reroll:"
			
			# Standard Terminal Output
			print("🎲 %s Selected %d %s dice (-%d Offense, -%d Defense, -%d Morale). New results -> +%d Offense | +%d Defense | +%d Morale" % [
				log_prefix, actual_reroll_count, pool_label, removed_o, removed_d, removed_m, added_o, added_d, added_m
			])

			if current_panel:
				var card_name := "Card #" + str(card_id)
				var controller = context.get("controller_ref")
				if controller:
					var fetched_name = controller.get_card_metadata(card_id, "card_name")
					if fetched_name != null and str(fetched_name) != "":
						card_name = str(fetched_name)

				# Formatted BBCode console message using rich inline image tags
				var summary_msg := "%s, %s %s Selected %d %s dice (-%d %s, -%d %s, -%d %s). \n New -> +%d %s | +%d %s | +%d %s" % [
					card_name,
					log_prefix,
					IMG_DICE,
					actual_reroll_count,
					pool_label,
					removed_o, IMG_SWORD,
					removed_d, IMG_SHIELD,
					removed_m, IMG_MEDAL,
					added_o, IMG_SWORD,
					added_d, IMG_SHIELD,
					added_m, IMG_MEDAL
				]
				current_panel.append_console_log(summary_msg)
				
		# =========================================================
		# CARDS
		# =========================================================
		"cards_drawn_to_hand":
			print("\n=== PHASE 1.5: DRAW CARDS ===")

			var controller = context.get("controller_ref")
			if controller and controller.has_method("_print_cards_drawn"):
				controller._print_cards_drawn(data[0], data[1])
		
		"card_icons_logged":
			var role_label: String = data[0]
			var off_icons: int = data[1]
			var def_icons: int = data[2]
			var mor_icons: int = data[3]
			var phase_context: String = data[4]
			
			print("🎴 %s card icons updated (%s) -> ⚔️ %d | 🛡️ %d | 🎖️ %d" % [role_label, phase_context, off_icons, def_icons, mor_icons])

			if current_panel != null:
				var is_attacker: bool = (role_label == "Attacker")
				current_panel.update_card_icons_displays(is_attacker, off_icons, def_icons, mor_icons, phase_context)
		
		"opponent_card_discarded":
			var controller = context.get("controller_ref")
			var active_card_name := "Card #" + str(data[0])
			var discarded_card_name := "Card #" + str(data[2])
			
			if controller:
				var active_fetched = controller.get_card_metadata(data[0], "card_name")
				if active_fetched != null and str(active_fetched) != "":
					active_card_name = str(active_fetched)
					
				var discarded_fetched = controller.get_card_metadata(data[2], "card_name")
				if discarded_fetched != null and str(discarded_fetched) != "":
					discarded_card_name = str(discarded_fetched)
			
			print("    [*] %s: ↳ 📇 Discard forced! %s chose and recycled '%s' from card slot %d back into their combat deck." % [active_card_name, data[1], discarded_card_name, data[3]])
			
			if current_panel:
				var msg := "%s ↳ %s %s %d" % [active_card_name, IMG_DISCARD, discarded_card_name, data[3]]
				current_panel.append_console_log(msg)
		# =========================================================
		# EXTRA ICONS
		# =========================================================
		
		"extra_icons_logged":
			print("🎴 %s extra icons updated (%s) -> %d ⚔️ | %d 🛡️ | %d 🎖️" % [data[0], data[4], data[1], data[2], data[3]])
			
			if current_panel:
				var is_attacker: bool = (data[0] == "Attacker")
				var phase_context: String = data[4]
				current_panel.update_extra_icons(is_attacker, data[1], data[2], data[3], phase_context)
		# =========================================================
		# ROUND FLOW
		# =========================================================
		"round_start":
			var round_num: int = data[0]
			print("")
			print("\n🔄--- COMBAT ROUND %d ---" % (round_num + 1))
		
		"assess_damage_step_start":
			if current_panel:
				var msg := "%s" % [IMG_RED_SQUARE]
				current_panel.append_console_log(msg)
			print("-- Assess Damage Step started. -- ")
		
		# =========================================================
		# CARD EFFECTS
		# =========================================================
		"card_icons_calculated":
			var role_label: String = data[0]
			var off_icons: int = data[1]
			var def_icons: int = data[2]
			var mor_icons: int = data[3]
			
			print("🎴 %s card icons -> ⚔️ %d | 🛡️ %d | 🎖️ %d" % [role_label, off_icons, def_icons, mor_icons])

			if current_panel != null:
				current_panel.set_assess_damage_step_card_icons(role_label, off_icons, def_icons, mor_icons)

		"ability_triggered":
			var controller = context.get("controller_ref")
			var card_name := "Card #" + str(data[0]) 

			if controller:
				var fetched_name = controller.get_card_metadata(data[0], "card_name")
				if fetched_name != null and str(fetched_name) != "":
					card_name = str(fetched_name)

			# --- SAFE OPTIONAL 3RD ARGUMENT ---
			var icon_bbcode := ""
			# Only look for data[2] if the array actually has a 3rd element
			if data.size() > 2 and str(data[2]) in ICON_MAP:
				icon_bbcode = ICON_MAP[str(data[2])] + " "
			# ----------------------------------

			print("  [*] %s: %s" % [card_name, data[1]])

			if current_panel:
				# Formats exactly as: "card name, ICON, text"
				# If no icon is passed, it cleanly falls back to "card name, text"
				var msg := "%s, %s%s" % [card_name, icon_bbcode, str(data[1])]
				current_panel.append_console_log(msg)
		
		"tokens_updated":
			var role_label: String = data[0]
			var offence: int = data[1]
			var defence: int = data[2]
			var phase_context: String = data[3] if data.size() > 3 else "damage_step"
			
			print("🪙 %s tokens updated (%s) -> %d ⚔️ | %d 🛡️" % [role_label, phase_context, offence, defence])


			if current_panel:
				if phase_context == "round_start":
					current_panel.set_round_start_tokens(role_label, offence, defence)
				else:
					current_panel.set_assess_damage_step_tokens(role_label, offence, defence)

		# =========================================================
		# DAMAGE PIPELINE
		# =========================================================

		# PHASE A: PRE DAMAGE
		"damage_pre_calculated":
			print("\n--- [PRE-DAMAGE SNAPSHOT] ---")
			print("%s %s -> ⚔️ %d | 🛡️ %d" % [_role_color(data[0]), data[0], data[1], data[2]])


		# PHASE B: RESOLVED DAMAGE
		"damage_resolved":
			print("\n--- [DAMAGE RESOLVED] ---")
			print("%s takes %d 💥" % [data[0], data[1]])

			if current_panel:
				current_panel.set_damage_assessment_pools(data[0], data[1])


		# =========================================================
		# DAMAGE APPLICATION EVENTS
		# =========================================================
		"unit_routed":
			print("🏳️ %s '%s' routed (took %d dmg)" % [data[0], data[1], data[2]])
			if current_panel:
				var message := "%s %d %s %s" % [str(data[1]), data[2], IMG_BOOM, IMG_ROUTED]
				current_panel.append_console_log(message)

		"unit_destroyed":
			var cond := "ROUTED" if data[3] else "HEALTHY"
			print("💀 %s '%s' (%s) destroyed (%d dmg)" % [data[0], data[1], cond, data[2]])
			if current_panel:
				var message := "%s %d %s %s" % [str(data[1]), data[2], IMG_BOOM, IMG_SKULL]
				current_panel.append_console_log(message)

		"damage_absorbed":
			print("🛡️ %s '%s' absorbed %d damage while routed" % [data[0], data[1], data[2]])
			if current_panel:
				var message := "%s %d %s" % [str(data[1]), data[2], IMG_SHIELD]
				current_panel.append_console_log(message)

		"unit_rallied":
			var controller = context.get("controller_ref")
			var card_name := "Card #" + str(data[3])

			if controller:
				card_name = controller.get_card_metadata(data[3], "card_name")

			print("🤝 %s rallied '%s' (%d HP) via %s" % [data[0], data[1], data[2], card_name])
			if current_panel:
				var message := "%s %d %s %s" % [str(data[1]), data[2], str(card_name), IMG_RALLY]
				current_panel.append_console_log(message)


		# =========================================================
		# TERMINATION / VICTORY
		# =========================================================
		"early_termination":
			var target_idx: int = min(active_round_index, active_round_panels.size() - 1)
			var target_panel = active_round_panels[target_idx] if target_idx >= 0 else null
			
			print("⚠️ SUDDEN DEATH: one side eliminated")
			if target_panel:
				var message := "One side was completely wiped out %s" % IMG_WARNING
				target_panel.append_console_log(message)
			
			for i in range(active_round_index + 1, active_round_panels.size()):
				if active_round_panels[i] != null:
					active_round_panels[i].update_unit_displays(true, "Match Terminated", "")
					active_round_panels[i].update_unit_displays(false, "Match Terminated", "")

		"victory_by_wipeout":
			var target_idx: int = min(active_round_index, active_round_panels.size() - 1)
			var target_panel = active_round_panels[target_idx] if target_idx >= 0 else null
			
			print("🏁 VICTORY BY WIPEOUT: %s" % data[0])
			if target_panel:
				var message := "%s wins %s" % [str(data[0]), IMG_FLAG]
				target_panel.append_console_log(message)

		"victory_mutual_annihilation":
			var target_idx: int = min(active_round_index, active_round_panels.size() - 1)
			var target_panel = active_round_panels[target_idx] if target_idx >= 0 else null
			
			print("💥 MUTUAL ANNIHILATION")
			if target_panel:
				var message := "Mutual Annihilation %s" % IMG_BOOM
				target_panel.append_console_log(message)

		"tiebreaker_morale":
			var target_idx: int = min(active_round_index, active_round_panels.size() - 1)
			var target_panel = active_round_panels[target_idx] if target_idx >= 0 else null
			
			print("--- TIEBREAKER ---\nATK %d | DEF %d" % [data[0], data[1]])
			if target_panel:
				var message := "TIEBREAKER Morale ATK %d | DEF %d" % [data[0], data[1]]
				target_panel.append_console_log(message)

#endregion
