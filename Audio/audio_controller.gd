extends Node2D

@export var mute: bool = false

#func _ready():
	#if not mute:
		#play_gameMusic()
		
func play_titleMusic():
	if not mute:
		$TitleMusic.play()

func stop_titleMusic():
	if not mute:
		$TitleMusic.stop()

func play_gameMusic():
	if not mute:
		$GameMusic.play()
		
func stop_gameMusic():
	if not mute:
		$GameMusic.stop()

func play_victoryMusic():
	if not mute:
		$Victory.play()
		
func stop_victoryMusic():
	if not mute:
		$Victory.stop()
		
func play_fall():
	if not mute:
		$Fall.play()
		
func play_crash():
	if not mute:
		$Crash.play()

func play_explode():
	if not mute:
		$Explode.play()

func gun_cannon():
	if not mute:
		$Gun_CANNON.play()

func gun_rocket():
	if not mute:
		$Gun_ROCKET.play()

func gun_lazer():
	if not mute:
		$Gun_LASER.play()
		
func gun_mg():
	if not mute:
		$Gun_MG.play()
		
func gun_sg():
	if not mute:
		$Gun_SG.play()

func pickup_gun():
	if not mute:
		$Pickup_GUN.play()
		
func pickup_part():
	if not mute:
		$Pickup_PART.play()
