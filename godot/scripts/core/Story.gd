extends Node

## Story dialogue + glossary registry.
##
## Loads the curated stage intro / boss intro / clear lines defined in
## `data/story_dialogues.json` and the glossary entries in
## `data/story_terms.json`. UI scripts ask Story for *already-localized* lines
## so callers do not need to know about the on-disk schema.

const DIALOGUES_PATH := "res://data/story_dialogues.json"
const TERMS_PATH := "res://data/story_terms.json"

var _dialogues: Dictionary = {}
var _terms: Array = []

func _ready() -> void:
	_load_dialogues()
	_load_terms()

func _load_dialogues() -> void:
	if not FileAccess.file_exists(DIALOGUES_PATH):
		push_error("Story: dialogues file missing at %s" % DIALOGUES_PATH)
		return
	var f := FileAccess.open(DIALOGUES_PATH, FileAccess.READ)
	if f == null:
		return
	var text := f.get_as_text()
	f.close()
	var parsed = JSON.parse_string(text)
	if parsed is Dictionary:
		_dialogues = parsed
	else:
		push_error("Story: dialogues JSON invalid")

func _load_terms() -> void:
	if not FileAccess.file_exists(TERMS_PATH):
		return
	var f := FileAccess.open(TERMS_PATH, FileAccess.READ)
	if f == null:
		return
	var text := f.get_as_text()
	f.close()
	var parsed = JSON.parse_string(text)
	if parsed is Dictionary:
		var list = parsed.get("terms", [])
		if list is Array:
			_terms = list

## Returns an Array of {speaker: String, text: String} dictionaries for the
## given stage and slot ("intro", "boss_intro", "clear"). Speaker name and
## line text are already resolved to the current Localization language.
func get_stage_lines(stage_id: String, slot: String) -> Array:
	var stages: Dictionary = _dialogues.get("stages", {})
	var stage_block: Dictionary = stages.get(stage_id, {})
	var raw_lines = stage_block.get(slot, [])
	if not (raw_lines is Array):
		return []
	var out: Array = []
	for entry in raw_lines:
		if not (entry is Dictionary):
			continue
		out.append({
			"speaker": _speaker_name(String(entry.get("speaker", ""))),
			"text": _localized_text(entry),
		})
	return out

func has_stage_lines(stage_id: String, slot: String) -> bool:
	return not get_stage_lines(stage_id, slot).is_empty()

func get_repeat_hint() -> String:
	var hints = _dialogues.get("repeat_hints", [])
	if not (hints is Array) or hints.is_empty():
		return ""
	var entry = hints[randi() % hints.size()]
	if entry is Dictionary:
		return _localized_text(entry)
	return ""

func get_terms() -> Array:
	return _terms

func get_term(id: String) -> Dictionary:
	for t in _terms:
		if t is Dictionary and String(t.get("id", "")) == id:
			return t
	return {}

# --- internal helpers ---

func _speaker_name(key: String) -> String:
	if key.is_empty():
		return ""
	var speakers: Dictionary = _dialogues.get("speakers", {})
	var entry = speakers.get(key, null)
	if entry is Dictionary:
		return _localized_text(entry)
	return key

func _localized_text(entry: Dictionary) -> String:
	var lang: String = Localization.current_lang if Localization else "en"
	if entry.has(lang):
		return String(entry[lang])
	if entry.has("en"):
		return String(entry["en"])
	if entry.has("ko"):
		return String(entry["ko"])
	return ""
