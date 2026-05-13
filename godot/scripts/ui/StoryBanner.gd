extends CanvasLayer
class_name StoryBanner

## Non-blocking subtitle banner that queues short story lines.
##
## - The game keeps running underneath; this never pauses input.
## - Lines are queued and shown one at a time: fade in, hold, fade out.
## - Lines are passed as already-localized Dictionaries (`{speaker, text}`),
##   typically obtained from Story.get_stage_lines().

signal queue_finished

const FADE_IN_SEC: float = 0.4
const FADE_OUT_SEC: float = 0.6
const PER_CHAR_SEC: float = 0.045
const MIN_HOLD_SEC: float = 2.4
const MAX_HOLD_SEC: float = 5.5

@onready var panel: PanelContainer = $Anchor/Panel
@onready var speaker_label: Label = $Anchor/Panel/VBox/Speaker
@onready var line_label: Label = $Anchor/Panel/VBox/Line

var _queue: Array = []
var _is_playing: bool = false
var _active_tween: Tween

func _ready() -> void:
	layer = 30
	panel.modulate.a = 0.0
	panel.visible = false

## Replace any currently-queued lines and start playing the given ones.
## Interrupts the current line if one is in flight. Each entry is
## `{speaker: String, text: String}`.
func play_lines(lines: Array) -> void:
	_queue.clear()
	if lines is Array:
		for entry in lines:
			if entry is Dictionary:
				_queue.append(entry)
	if _active_tween and _active_tween.is_valid():
		_active_tween.kill()
	_is_playing = false
	_play_next()

## Append lines to the existing queue without interrupting the current line.
func append_lines(lines: Array) -> void:
	if not (lines is Array):
		return
	for entry in lines:
		if entry is Dictionary:
			_queue.append(entry)
	if not _is_playing:
		_play_next()

func clear() -> void:
	_queue.clear()
	if _active_tween and _active_tween.is_valid():
		_active_tween.kill()
	panel.modulate.a = 0.0
	panel.visible = false
	_is_playing = false

func _play_next() -> void:
	if _queue.is_empty():
		_is_playing = false
		queue_finished.emit()
		return
	_is_playing = true
	var entry: Dictionary = _queue.pop_front()
	var speaker_name: String = String(entry.get("speaker", ""))
	var text: String = String(entry.get("text", ""))
	if text.is_empty():
		_play_next()
		return
	speaker_label.text = speaker_name
	speaker_label.visible = not speaker_name.is_empty()
	line_label.text = text
	panel.visible = true
	var hold: float = clamp(PER_CHAR_SEC * float(text.length()), MIN_HOLD_SEC, MAX_HOLD_SEC)
	if _active_tween and _active_tween.is_valid():
		_active_tween.kill()
	_active_tween = create_tween()
	_active_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_active_tween.tween_property(panel, "modulate:a", 1.0, FADE_IN_SEC)
	_active_tween.tween_interval(hold)
	_active_tween.tween_property(panel, "modulate:a", 0.0, FADE_OUT_SEC)
	_active_tween.tween_callback(_after_line)

func _after_line() -> void:
	if _queue.is_empty():
		panel.visible = false
		_is_playing = false
		queue_finished.emit()
	else:
		_play_next()
