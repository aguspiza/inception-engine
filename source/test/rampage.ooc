use glew
import glew
import gfx/[RenderWindow, Cube, Scene, Grid, Camera]
import engine/[Engine, Entity, Property, Update, Message]

main: func {
    
    engine := Engine new()
	win := RenderWindow new(800, 400, 32, false, "render_window")
	engine addEntity(win)
    Ant count = 0
    for (i in 0..5) engine addEntity(Ant new())
    engine addEntity(Killer new())
    
    engine run()
    
}

Ant: class extends Entity {
   
    count : static Int
    
    init: func ~qm {
        name := "ant" + This count toString()
        //super(name)
        this name = name
        
        Ant count += 1
        
        listen(KillMessage, func (m: KillMessage) {
            "%s received message from %s, must die!" format(m target name toCString(), m sender name toCString()) println()
            //engine remove(this)
            Ant count -= 1
            if(Ant count <= 0) {
                "We're all dead!" println()
                exit(0)
            }
        }) 
    }
    
}


Killer: class extends Entity {
    
    init: func ~qm {
        //super("killer")
        name = "killer"
    }
    
    update: func {
        super()
        sendAll(KillMessage new())
    }
    
}
    
KillMessage: class extends Message {}

