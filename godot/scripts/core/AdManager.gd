extends Node

## Rewarded-ad bridge.
##
## Wiring contract (so AdMob SDK can be dropped in later without touching UI):
##   - is_supported()        — true once a real ad plugin is attached and ad units are loaded
##   - is_rewarded_ready()   — call before showing a CTA button
##   - show_rewarded(tag)    — opens the ad; tag is just a label for telemetry
##   - rewarded_granted(tag) — signal fired on successful completion only
##   - rewarded_dismissed(tag) — signal fired if the user closes before the reward
##   - rewarded_failed(tag, reason) — signal fired on load/show error
##
## Why all the indirection: per docs/COMMERCIALIZATION_ANALYSIS.md §5.4 and
## Google Play's rewarded-ad policy, the player must explicitly opt in before
## any ad shows, and the reward only applies after the ad completes. UI code
## hands us a tag, waits on the signal, and applies the reward — no UI lives
## inside this autoload.
##
## Current state: SDK NOT yet linked. ENABLED stays false. UI surfaces hide
## their CTAs while ENABLED is false, so the game ships ad-free until the
## user-supplied AdMob app ID + rewarded-ad-unit ID land in the placeholders
## below and the Android plugin is actually wired. See docs/ADMOB_SETUP.md.

signal rewarded_granted(tag: String)
signal rewarded_dismissed(tag: String)
signal rewarded_failed(tag: String, reason: String)

# Flip to true once the AdMob plugin .aar is added to godot/addons/, the
# Android export plugin is registered, and the IDs below are real.
const ENABLED: bool = false

# AdMob app ID — replace with the value from https://admob.google.com →
# Apps → (this app) → App settings → "App ID" (format: ca-app-pub-XXXX~YYYY).
const ADMOB_APP_ID: String = "ca-app-pub-0000000000000000~0000000000"

# Rewarded-ad unit ID — replace with the value from AdMob →
# Apps → (this app) → Ad units → (rewarded unit) → "Ad unit ID"
# (format: ca-app-pub-XXXX/ZZZZ). Use Google's test ID
# "ca-app-pub-3940256099942544/5224354917" during development.
const REWARDED_UNIT_ID: String = "ca-app-pub-3940256099942544/5224354917"

const REWARD_TAG_REVIVE: String = "revive"
const REWARD_TAG_DOUBLE_GOLD: String = "double_gold"

var _plugin: Node = null
var _rewarded_loaded: bool = false
var _pending_tag: String = ""

func _ready() -> void:
	if not ENABLED:
		return
	if OS.get_name() != "Android":
		return
	_init_plugin()

func _init_plugin() -> void:
	# Placeholder for the real AdMob plugin lookup. Once an AdMob Godot
	# Android plugin is added, swap this for:
	#   if Engine.has_singleton("AdMob"):
	#       _plugin = Engine.get_singleton("AdMob")
	#       _plugin.initialize(ADMOB_APP_ID)
	#       _plugin.load_rewarded(REWARDED_UNIT_ID)
	#       _plugin.rewarded_loaded.connect(_on_rewarded_loaded)
	#       _plugin.rewarded_user_earned_reward.connect(_on_user_earned_reward)
	#       _plugin.rewarded_ad_dismissed.connect(_on_rewarded_dismissed)
	#       _plugin.rewarded_ad_failed_to_show.connect(_on_rewarded_failed)
	# Kept as a no-op for now so the shipping build has zero ad surface.
	pass

func is_supported() -> bool:
	return ENABLED and _plugin != null

func is_rewarded_ready() -> bool:
	return is_supported() and _rewarded_loaded

# Tag is recorded so UI can disambiguate which reward to grant when the
# rewarded_granted signal fires (e.g., revive vs. double_gold).
func show_rewarded(tag: String) -> void:
	if not is_rewarded_ready():
		rewarded_failed.emit(tag, "not_ready")
		return
	_pending_tag = tag
	if _plugin and _plugin.has_method("show_rewarded"):
		_plugin.show_rewarded()

func _on_rewarded_loaded() -> void:
	_rewarded_loaded = true

func _on_user_earned_reward(_type: String, _amount: int) -> void:
	var tag := _pending_tag
	_pending_tag = ""
	_rewarded_loaded = false
	rewarded_granted.emit(tag)
	# Pre-load the next rewarded ad so the player doesn't wait next time.
	if _plugin and _plugin.has_method("load_rewarded"):
		_plugin.load_rewarded(REWARDED_UNIT_ID)

func _on_rewarded_dismissed() -> void:
	var tag := _pending_tag
	_pending_tag = ""
	_rewarded_loaded = false
	rewarded_dismissed.emit(tag)
	if _plugin and _plugin.has_method("load_rewarded"):
		_plugin.load_rewarded(REWARDED_UNIT_ID)

func _on_rewarded_failed(_code: int, message: String) -> void:
	var tag := _pending_tag
	_pending_tag = ""
	_rewarded_loaded = false
	rewarded_failed.emit(tag, message)
