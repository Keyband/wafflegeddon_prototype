extends Node

var jogador
var alvo
var plataformas
var dificuldade = 1

var a1
var b1
var a2
var b2

var dano_projetil = 1
var delay_das_torres = 2
var bateria_maxima_das_torres = 100
var range_das_torres = 40

var bgm = preload("res://Scenes/bgm.tscn")

func _ready():
	randomize()
	OS.window_size *= 3
	add_child(bgm.instance())

func gameover():
	pass
#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
