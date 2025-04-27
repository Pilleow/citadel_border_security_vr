extends Node3D

var hasnot_played_news := true

func _ready():
	$newsIntro.modulate.v = 0.0
	$CRT_tv_static.max_distance = 0.1
	await get_tree().create_timer(2.0).timeout
	$newsIntro/newsIntroSFX.play()
	$newsIntro.modulate.v = 1.0
	$CRT_tv_static.max_distance = 0

func _process(delta):
	if hasnot_played_news and $newsIntro.modulate.v == 0.0:
		return
	if hasnot_played_news and $newsIntro/newsIntroSFX.get_playback_position() < 3.5:
		$newsIntro.modulate.a = min(1, 3.5 - $newsIntro/newsIntroSFX.get_playback_position())
		return
	if hasnot_played_news:
		$newsIntro.hide()
		hasnot_played_news = false
		$newsBG/newsSound.play()
	if not $newsBG/newsSound.playing and not $newsIntro.visible:
		$CRT_tv_static.max_distance = 0.1
		$newsIntro.modulate.v = 0.0
		$newsIntro.show()
