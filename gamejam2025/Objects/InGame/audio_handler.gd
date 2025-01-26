extends Node3D

@onready var bgm_1 = $BackgroundMusic/BGM1
@onready var bgm_2 = $BackgroundMusic/BGM2

@onready var sound_effect_player = $SoundEffects.get_children()
@onready var sound_effect_player_everywhere = $AlwaysSoundEffects.get_children()

const BgmVolume = 0.1
const SoundVolume = 2.0

var current_player_idx := 0
var current_player_everywhere_idx := 0
var current_bgm_player := 0
var music_fade_time := 4.0
var continuous_bgm_transition := false

var background_tweener : Tween

func add_sound_effect(sound, position, pitch=1.0, hear_dist=10, volume_shift=0.0):
	self.sound_effect_player[self.current_player_idx].global_position = position
	self.sound_effect_player[self.current_player_idx].stream = sound
	if not is_instance_of(sound, AudioStreamWAV):
		self.sound_effect_player[self.current_player_idx].stream.loop = false
	self.sound_effect_player[self.current_player_idx].pitch_scale = pitch
	self.sound_effect_player[self.current_player_idx].unit_size = hear_dist
	self.sound_effect_player[self.current_player_idx].volume_db = volume_shift + self.SoundVolume
	self.sound_effect_player[self.current_player_idx].play()
	self.current_player_idx += 1
	if self.current_player_idx >= len(self.sound_effect_player):
		self.current_player_idx = 0


func add_sound_everwhere(sound, pitch=1.0):
	self.sound_effect_player_everywhere[self.current_player_everywhere_idx].stream = sound
	if not is_instance_of(sound, AudioStreamWAV):
		self.sound_effect_player_everywhere[self.current_player_everywhere_idx].stream.loop = false
	self.sound_effect_player_everywhere[self.current_player_everywhere_idx].pitch_scale = pitch
	self.sound_effect_player_everywhere[self.current_player_everywhere_idx].volume_db = self.SoundVolume
	self.sound_effect_player_everywhere[self.current_player_everywhere_idx].play()
	self.current_player_everywhere_idx += 1
	if self.current_player_everywhere_idx >= len(self.sound_effect_player_everywhere):
		self.current_player_everywhere_idx = 0


func set_bgm(new_bgm):
	if not new_bgm:
		return
	if not self.bgm_1.playing and not self.bgm_2.playing:
		self.bgm_1.stream = new_bgm
		self.bgm_1.volume_db = self.BgmVolume
		self.bgm_1.play()
	if self.current_bgm_player == 0:
		if self.bgm_1.stream == new_bgm:
			return # same background music as before nothing to do
		self.switch_bgm(self.bgm_1, self.bgm_2, new_bgm)
		self.current_bgm_player = 1
	else:
		if self.bgm_2.stream == new_bgm:
			return # same background music as before nothing to do
		self.switch_bgm(self.bgm_2, self.bgm_1, new_bgm)
		self.current_bgm_player = 0


func switch_bgm(current_player, new_player, new_bgm):
	new_player.stream = new_bgm
	new_player.volume_db = -20
	
	if self.continuous_bgm_transition:
		new_player.play(current_player.get_playback_position())
	else:
		new_player.play()
		
	if self.background_tweener:
		self.background_tweener.kill()
	self.background_tweener = create_tween()
	self.background_tweener.tween_property(current_player, "volume_db", -80, self.music_fade_time)
	self.background_tweener.parallel().tween_property(new_player, "volume_db", self.BgmVolume, self.music_fade_time)
	await self.background_tweener.finished
	current_player.playing = false
