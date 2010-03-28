import Update,Entity,Message
import structs/ArrayList

Float3: class {
	clients: Entity[]
	x,y,z: Float
	
	init: func(=x,=y,=z) {}
	
	set: func(=x,=y,=z){
		for(client in clients) {
			client send(client,ValueChange get(this))
		}
	}
	
	normalize: func {
		l := length()
		x /= l
		y /= l
		z /= l
	}
	
	length: func -> Float {
		return sqrt(x*x + y*y + z*z)
	}
	
	toString: func -> String {
		return "(%.2f,%.2f,%.2f)" format(x,y,z)
	}
}

operator * (v1: Float3, n: Float) -> Float3 {
	return Float3 new(v1 x * n, v1 y * n, v1 z * n)
}

operator + (v1,v2: Float3) -> Float3 {
	return Float3 new(v1 x + v2 x, v1 y + v2 y, v1 z + v2 z)
}

operator - (v1,v2: Float3) -> Float3 {
	return Float3 new(v1 x - v2 x, v1 y - v2 y, v1 z - v2 z)
}

operator ^ (v1,v2: Float3) -> Float3 {
	return Float3 new (
		v1 y * v2 z - v1 z * v2 y,
		v1 z * v2 x - v1 x * v2 z,
		v1 x * v2 y - v2 y * v2 x
	)
}

Float2: class {
	clients: Entity[]
	x,y: Float
	init: func(=x,=y) {}
	
	set: func(=x,=y){
		for(client in clients) {
			client send(client,ValueChange get(this))
		}
	}
}
