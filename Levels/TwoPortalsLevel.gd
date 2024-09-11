extends Node


@export var PortA: Node2D
@export var PortB: Node2D

@export var PortC: Node2D
@export var PortD: Node2D

func config(rootScript):
	rootScript.create_connection(PortA, PortB, false)

	if PortC and PortD:
		rootScript.create_connection(PortC, PortD, false)
