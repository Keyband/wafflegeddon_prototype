extends Area2D

var alvo = null
var alvo_wr = null
var energia_maxima = 100
var energia = 100
var consumo = 20

var tiro = preload("res://Scenes/turret1/turret_shot.tscn")
var dano_str = preload("res://Scenes/etc/str_damage.tscn")

func _ready():
	add_to_group('Torreta')
	set_physics_process(true)
	$tmr_attack.wait_time = global.delay_das_torres

func _physics_process(delta):
	if alvo != null:
		$sprite.rotation = 0 if not alvo_wr.get_ref() else (alvo.global_position - self.global_position).angle() - (PI/2)

func atacar():
#	energia_maxima = global.bateria_maxima_das_torres
#	$range/collision_shape_2d.shape.radius = global.range_das_torres
	if energia >= 0:
		var possiveis_alvos = []
		for body in $range.get_overlapping_bodies():
			if body.is_in_group('Inimigo'): possiveis_alvos.append(body)
		
		if possiveis_alvos.size() == 0:
			alvo = null
			return

		alvo = possiveis_alvos[0]
		for body in possiveis_alvos: if (body.global_position - self.global_position).length() < (alvo.global_position - self.global_position).length() and alvo.global_position.y > self.global_position.y: alvo = body
		alvo_wr = weakref(alvo)
		
		energia -= consumo
		$snd_shot.play()
		var i = tiro.instance()
		i.dano = 1000
		i.velocidade_maxima *= 2
		i.global_position = self.global_position
		i.vetor_direcao = Vector2(1,0).rotated((alvo.global_position - self.global_position).angle())
		get_parent().add_child(i)

func recarregar(quantidade): pass#energia += quantidade

func _on_tmr_attack_timeout(): atacar()


func _on_range_body_entered(body): if body.is_in_group('Inimigo'): atacar()
