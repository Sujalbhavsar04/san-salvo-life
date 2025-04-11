class_name PlayerDetectionZone # definiamo lo script come una classe globalmente accessibile con il nome 'PlayerDetectionZone'
extends Area2D # estendiamo la classe Area2D (e quindi ne ereditiamo metodi e proprietà)

var player = null # definiamo una variabile che conterrà il riferimento al player che sarà entrato nella PlayerDetectionZone

# funzione che controlla se il player è visibile o meno
func can_see_player():
	return player != null # se la reference al player è null allora non c'è nessun player all'interno della PlayerDetectionZone

# funzione che viene chiamata quando Area2D spara il signal body_entered
func _on_body_entered(body):
	player = body # salviamo il riferimento del player all'interno della variabile poichè esso è appena entrato nella PlayerDetectionZone

# funzione che viene chiamata quando Area2D spara il signal body_exited
func _on_body_exited(_body):
	player = null # 'perdiamo' il riferimento del player poichè esso è appena uscito dalla PlayerDetectionZone
