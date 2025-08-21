extends Node


var checkout = preload("res://Entities/BuildingObjects/checkout.tscn")
var shelf = preload("res://Entities/BuildingObjects/shelf.tscn")
var computer = preload("res://Entities/BuildingObjects/PCDesk.tscn")

var product = preload("res://Entities/Product/product.tscn")

var fixtures = {
	"checkout" : checkout,
	"shelf" : shelf,
	"computer" : computer,
}


var fixture_prices = {
	"checkout" : 500,
	"shelf" : 200,
	"computer" : 500,
}


var products = {
	"product" : product
}
