extends Object
class_name Set

var _iternal = {};


var values: 
	get():
		return _iternal.keys()

func append(value: Variant):
	_iternal[value] = null


func remove(value: Variant):
	_iternal.erase(value)
