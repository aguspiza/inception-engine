use sdl, glew, glu
import sdl/[Core, Video, Event], glew, glu/Glu
import engine/[Message, Entity, Types]
import console/Console
import gfx/Scene

RenderWindow: class extends Entity {
	width, height, bpp, videoFlags : Int
	fullscreen := false
	isActive := false
	title := "r2l"
	surface: Surface*
	
    init: func ~renderWindow (=width, =height, =bpp, =fullscreen, =title) {
        
		super("render_window")
		listen(KeyboardMsg, This onKey)
		listen(ResizeEvent, This onResize)
		listen(QuitMessage, func(m: Message) { this := m target; quit() })
		
		/* initialize SDL */
		if (SDL init(SDL_INIT_EVERYTHING) < 0) {
            fprintf(stderr, "SDL initialization failed: %s\n", SDL getError())
			quit()
		}
        
        SDL enableUnicode(true)

		/* Fetch the video info */
		videoInfo := SDL getVideoInfo()

		if (!videoInfo) {
			fprintf(stderr, "SDL video query failed: %s\n", SDL getError())
			quit()
		}

		/* the flags to pass to SDL_SetVideoMode */
		videoFlags  = SDL_OPENGL          /* Enable OpenGL in SDL */
		videoFlags |= SDL_GL_DOUBLEBUFFER /* Enable double buffering */
		videoFlags |= SDL_HWPALETTE       /* Store the palette in hardware */
		videoFlags |= SDL_RESIZABLE       /* Enable window resizing */
		
		if(fullscreen) {
			videoFlags |= SDL_FULLSCREEN
		}

		/* This checks to see if surfaces can be stored in memory */
		if (videoInfo@ hw_available)
			videoFlags |= SDL_HWSURFACE
		else
			videoFlags |= SDL_SWSURFACE

		/* This checks if hardware blits can be done */
		if (videoInfo@ blit_hw)
			videoFlags |= SDL_HWACCEL

		/* Sets up OpenGL double buffering */
		SDL GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1)

		/* get a SDL surface */
		surface = SDLVideo setMode(width, height, bpp, videoFlags)

		/* Verify there is a surface */
		if (!surface) {
			fprintf(stderr,  "Video mode set failed: %s\n", SDL getError())
			quit()
		}

		/* initialize OpenGL */
		if (initGL() == false)
		{
			fprintf(stderr, "Could not initialize OpenGL.\n")
			quit()
		}

		/* Resize the initial window */
		resizeWindow(width, height)
		
		SDL enableKeyRepeat(300, 30)
		//glColorMaterial(GL_FRONT, GL_AMBIENT_AND_DIFFUSE)
		//glEnable(GL_COLOR_MATERIAL)
		title(title)
		
		//SDL WM_GrabInput(SDL_GRAB_ON)
		SDL showCursor(SDL_DISABLE)
        
		glewInit()
        
	}
    
	quit: func {
        if(fullscreen) {
			SDL WM_ToggleFullScreen(surface)
		}
		SDL quit()
		exit(0)
	}
	
	resizeWindow: func(=width, =height) -> Bool {
		
		/* Height / width ration */
		ratio: GLfloat

		/* Protect against a divide by zero */
		if (height == 0)
			height = 1

		ratio = width as GLfloat / height as GLfloat

		/* Setup our viewport. */
		glViewport(0, 0, width as GLint, height as GLint)

		/* change to the projection matrix and set our viewing volume. */
		glMatrixMode(GL_PROJECTION)
		glLoadIdentity()

		/* Set our perspective */
		gluPerspective(45.0, ratio, 0.1, 1000.0)
		//gluOrtho2D(0, width, height, 0);

		/* Make sure we're changing the model view and not the projection */
		glMatrixMode(GL_MODELVIEW)

		/* Reset The View */
		glLoadIdentity()
		
		glEnable(GL_DEPTH_TEST)
		//glEnable(GL_BLEND)
		//glDisable(GL_DEPTH_TEST)
		//glBlendFunc(GL_SRC_ALPHA, GL_ONE)
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)

		return true
	}
		
	onKey: static func(m: KeyboardMsg) {
		this := m target
		if(m key == SDLK_F11 && m type == SDL_KEYUP) {
			toggleFullScreen()
		} else if (m key == SDLK_q) {
			quit()
		}
	}
    
    toggleFullScreen: func {
        SDL WM_ToggleFullScreen(surface)
        fullscreen = !fullscreen
    }
	
	onResize: static func(m: ResizeEvent) {
		this := m target
		resizeWindow(m x, m y)
	}
	
	
	/* general OpenGL initialization function */
	initGL: func() -> Bool {

		/* Enable smooth shading */
		glShadeModel(GL_SMOOTH)

		/* Set the background black */
		glClearColor(0.0, 0.0, 0.0, 0.0)

		/* Depth buffer setup */
		glClearDepth(1.0)

		/* Enables Depth Testing */
		//glDisable(GL_DEPTH_TEST)

		/* The Type Of Depth Test To Do */
		//glDepthFunc(GL_LEQUAL)

		/* Really Nice Perspective Calculations */
		//glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST)

		return true
        
	}
    
    onAdd: func {        
        //engine addEntity(Console new(10, 10, width * 2/5, height * 2/5))
    }
	
	
	title: func(=title) {
		SDLVideo wmSetCaption(title toCString(), null)
	}
}
