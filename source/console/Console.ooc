use glew, glu, sdl, ftgl
import ftgl
import sdl/[Sdl,Event]
import glew,glu/Glu
import engine/[Engine, Entity, Property, Types, Message, EventMapper]
import gfx/[RenderWindow, Model]
import structs/[LinkedList, HashMap]
import text/StringTokenizer

import Command

Console: class extends Model {

	lines := LinkedList<String> new()  //stores all lines for displaying(you don't want messages in the history, do you)
	history := LinkedList<String> new() //only entered commands here
	commands := HashMap<String, Command> new()
	
	font := Ftgl new(80, 72, "data/fonts/Terminus.ttf")
	buffer := String new(128)
	inputHeight := 12
	caretStart := 0
	
	printedLine := true
	
	size := Float2 new(800, 600)
	
	focus := true
	alpha := 128

	selected := false
	hovered := false
	
	border:= 10  //in pixels
	
	//hover bools
	bottom := false
	top := false
	left := false
	right := false
	
	ulcorner := false
	urcorner := false
	dlcorner := false
	drcorner := false
	
	//select bools
	bottoms := false
	tops := false
	lefts := false
	rights := false
	
	ulcorners := false
	urcorners := false
	dlcorners := false
	drcorners := false
	
	
	browsingHistory := false
	iterator: LinkedListIterator<String>
	
	COMMAND = 0, SHOW = 1, ENT = 2 : Int
	
	init: func ~posSize (x, y, width, height: Float) {
        
		super("console")
		set("position", Float3 new(x, y, 0))
		set("size",     Float2 new(width, height))
		listen(KeyboardMsg, This handleKey)
		listen(MouseButton, This mouseHandle)
		listen(MouseMotion, This mouseMotion)
		show = false
		initCommands()
        
	}
	
	initCommands: func {
		addCommand(Command new("show", "show [entity] [...]", func (console: Console, st: StringTokenizer) {
            ename := st nextToken()
            pname := st nextToken()
            
            ent := console engine getEntity(ename)
            if(ent == null) {
                console cprintln("sorry, no such entity [%s]" format(ename))
                return
            }
                
            // display a particular property
            if(pname != null && !pname isEmpty()) {
                prop := ent props get(pname)
                if(prop == null) {
                    console cprintln("sorry, entity [%s] doesn't have a property named [%s]" format(ename, pname))
                    return
                }
                console cprintln(prop toString())
                return
            }
            
            // display all properties
            console cprintln("%s:" format(ename))
            for(prop in ent props) {
                console cprintln("- %s = %s" format(prop name, prop toString()))
            }
        }))
        
		addCommand(Command new("help", "help [command]", func (console: Console, st: StringTokenizer) {
            name := st nextToken()
            
            if(name == null) {
                console cprintln("usage: help [command]")
            } else {
                command := console commands get(name)
                if(command != null) {
                    console cprintln("%s: %s" format(name, command getHelp()))
                } else {
                    console cprintln("unknown command: %s" format(name))
                }
            }
        }))
        
		addCommand(Command new("quit", "quits r2l", func (console: Console, st: StringTokenizer) {
            console sendAll(QuitMessage new())
        }))
	}
    
    addCommand: func (c: Command) {
        commands put(c getName(), c)
        c console = this
    }
	
	
	mouseHandle: static func(m: MouseButton) {
		this := m target
		if(m type == SDL_MOUSEBUTTONDOWN) {
			if(hovered) {
				selected = true
			} 
			if(bottom) {
				bottoms = true
			} 
			if(top) {
				tops = true
			} 
			if(left) {
				lefts = true
			} 
			if(right) {
				rights = true
			} 
			if(ulcorner) {
				ulcorners = true
			} 
			if(urcorner) {
				urcorners = true
			} 
			if(dlcorner) {
				dlcorners = true
			} 
			if(drcorner) {
				drcorners = true
			} 
		}
		
		if(m type == SDL_MOUSEBUTTONUP) {
			selected = false
			bottoms = false
			tops = false
			lefts = false
			rights = false
			ulcorners = false
			urcorners = false
			dlcorners = false
			drcorners = false
		}
	}
	
	mouseMotion: static func(m: MouseMotion) {
		this := m target
		pos := get("position", Float3)
		size := get("size", Float2)
		
		left = false
		right = false
		top = false
		bottom = false
		hovered = false
		ulcorner = false
		urcorner = false
		dlcorner = false
		drcorner = false
		
		//testing for center bounds, for console moving
		if(m x >= pos x && m x <= (pos x + size x) && 
		   m y >= pos y && m y <= (pos y + size y)) {
			   hovered = true
		   } 
	
		//now left border
		if(m x >= pos x - border && m x < pos x && 
		   m y > pos y && m y < pos y + size y) {
			   left = true
		   }
		   
		//now right border
		if(m x > pos x + size x && m x <= pos x + size x + border && 
		   m y > pos y && m y < pos y + size y) {
			   right = true
		   }
		   
		//now top border
		if(m x >= pos x && m x <= pos x + size x &&
		   m y >= pos y - border && m y < pos y) {
			   top = true
		   }
		   
		//now bottom border
		if(m x >= pos x && m x <= pos x + size x &&
		   m y > pos y + size y && m y <= pos y + size y + border) {
			   bottom = true
		   }
		   
		//now upper left corner
		if(m x < pos x && m x >= pos x - border &&
		   m y < pos y && m y >= pos y - border) {
			   ulcorner = true
		   }
		   
		//now upper right corner
		if(m x > pos x  + size x && m x <= pos x + size x + border &&
		   m y < pos y && m y >= pos y - border) {
			   urcorner = true
		   }
		   
		//now lower right corner
		if(m x > pos x  + size x && m x <= pos x + size x + border &&
		   m y > pos y + size y && m y <= pos y + size y + border) {
			   drcorner = true
		   }
		   
		// now lower left corner
		if(m x < pos x && m x >= pos x - border &&
		   m y > pos y + size y && m y <= pos y + size y + border) {
			   dlcorner = true
		   }
		   
		if(selected)
			pos set(pos x + m dx, pos y + m dy,0)
			
		if(lefts) {
			size set(size x - m dx, size y)
			pos set(pos x + m dx, pos y,0)
		}
		
		if(rights) {
			size set(size x + m dx, size y)
			pos set(pos x, pos y,0)
		}
		
		if(tops) {
			size set(size x , size y - m dy)
			pos set(pos x, pos y + m dy,0)
		}
		
		if(bottoms) {
			size set(size x , size y + m dy)
			pos set(pos x, pos y,0)
		}
		
		if(ulcorners) {
			size set(size x - m dx , size y - m dy)
			pos set(pos x + m dx, pos y + m dy,0)
		}
		
		if(urcorners) {
			size set(size x + m dx , size y - m dy)
			pos set(pos x, pos y + m dy,0)
		}
		
		if(drcorners) {
			size set(size x + m dx , size y + m dy)
			pos set(pos x, pos y,0)
		}
		
		if(dlcorners) {
			size set(size x - m dx , size y + m dy)
			pos set(pos x + m dx, pos y,0)
		}
		
		if(size x < border * 2) {
			bottoms = false
			tops = false
			lefts = false
			rights = false
			ulcorners = false
			urcorners = false
			dlcorners = false
			drcorners = false
			size x = border * 2
		}
			
		if(size y < border * 2) {
			bottoms = false
			tops = false
			lefts = false
			rights = false
			ulcorners = false
			urcorners = false
			dlcorners = false
			drcorners = false
			size y = border * 2
		}
			
		
	}
	
	toggleShow: func {
		show = !show
		if(show) {
			block()
			
			focus = true
		}
		else {
			unblock()
			
			focus = false
		}
	}
	
	toggleFocus: func {
		focus = !focus
		if(focus) {
			alpha = 128
			block()
		} else {
			alpha = 64
			unblock()
		}
	}
	
	block: func {
		send(engine getEntity("event_mapper"),GrabKeyboard new())
		send(engine getEntity("event_mapper"),GrabMouse new())
		SDL showCursor(SDL_ENABLE)
	}
	
	unblock: func {
		send(engine getEntity("event_mapper"),UngrabKeyboard new())
		send(engine getEntity("event_mapper"),UngrabMouse new())
		SDL showCursor(SDL_DISABLE)
	}
	
	handleKey: static func(m: KeyboardMsg) {
		this := m target
		state := SDL getModState()
		
		if(m type != SDL_KEYDOWN)
			return
		
		if(m key == SDLK_BACKQUOTE && !(state & KMOD_LCTRL)) {
			toggleShow()
			browsingHistory = false
			return
		} else if(m key == SDLK_BACKQUOTE) {
			toggleFocus()
		}
		
		if(!show || !focus)
			return
		
		match(m key) {
			case SDLK_RETURN => {
				command(buffer)
				buffer = String new(128)
				caretStart = 0
				browsingHistory = false
			}
			
			case SDLK_UP => {
				if(!browsingHistory) {
					iterator = history iterator()
					browsingHistory = true
				}
				
				if(iterator hasNext()) {
					setBuffer(iterator next() clone())
				}
			}
			
			case SDLK_DOWN => {
				if(!browsingHistory) {
					iterator = history iterator()
					browsingHistory = true
				}
				
				if(iterator hasPrev()) {
					setBuffer(iterator prev() clone())
				} else {
					buffer = String new(128)
					browsingHistory = false
				}
			}
			
			case SDLK_TAB => {
				completion(buffer clone())
			}
			
			case SDLK_l => {
				if(state & KMOD_LCTRL)
					lines clear()
			}
		} 
		
		ch := (m unicode & 0x7f) as Char
		
		// haha c'est tout mom keye.
		if(m key == SDLK_BACKSPACE && caretStart > 0) {
			buffer = buffer substring(0, caretStart - 1) + buffer substring(caretStart, buffer length())
			caretStart -= 1
			
		} else if(m key == SDLK_DELETE && caretStart < buffer length()) {
			buffer = buffer substring(0, caretStart) + buffer substring(caretStart + 1, buffer length())
			
		} else if(m key == SDLK_RIGHT && caretStart < buffer length() ) {
			caretStart += 1
			
		} else if(m key == SDLK_LEFT && caretStart > 0) {
			caretStart -= 1
			
		} else if(m key == SDLK_HOME) {
			caretStart = 0
			
		} else if(m key== SDLK_END) {
			caretStart = buffer length()
			
		} else if((ch isPrintable() && ch != SDLK_LSHIFT && ch!= SDLK_RSHIFT) && !((state & KMOD_LCTRL) || (state & KMOD_RCTRL))) {
			if(caretStart == buffer length()) {
				buffer = buffer + ch
			} else {
				buffer = buffer substring(0, caretStart) + ch + buffer substring(caretStart, buffer length())
			}
			caretStart += 1
		}
	}
	
	setBuffer: func(text: String) {
		buffer = text clone()
		caretStart = buffer length()
	}
	
	begin2D: func {
        glDisable(GL_DEPTH_TEST);
		glEnable(GL_BLEND)
        glMatrixMode(GL_PROJECTION);
        glPushMatrix();
		glLoadIdentity();
        
		rw := engine getEntity("render_window") as RenderWindow
		gluOrtho2D(0, rw width, rw height, 0);
		glMatrixMode(GL_MODELVIEW);
		glPushMatrix();
        glLoadIdentity();
	}
	
	completion: func(begin: String) {
		suggs := LinkedList<String> new()
		tokenizer := StringTokenizer new(begin, " ")
		correctTokens := LinkedList<String> new()
		status := COMMAND
		
		level := 0
		for(token in tokenizer) {
			match(level) {
				case 0 => {
					suggs clear()
					if(commands get(token) == null) {
						for(key in commands getKeys()) {
							if(key startsWith(token)) {
								suggs add(key)
							}
						}
						break
					} else {
						correctTokens add(token clone())
					}
				}
				
				case 1 => {
					suggs clear()
					if(correctTokens last() == "show") {
						status = SHOW
						ent := engine getEntity(token)
						if(ent == null) {
							for(key in engine entities getKeys()) {
								if(key startsWith(token)) {
									suggs add(key)
								}
							}
							break
						} else {
							correctTokens add(token clone())
						}
					}
				}
				
				case 2 => {
					match(status) {
						case SHOW => {
							status = ENT
							suggs clear()
							ent := engine getEntity(correctTokens last())
							prop := ent props get(token)
							if(prop == null) {
								for(key in ent props getKeys()) {
									if(key startsWith(token)) {
										suggs add(key)
									}
								}
								break
							} else {
								correctTokens add(token clone())
							}
						}
					}
				}
			}
			level += 1
		}
		
		correctToken := ""
		for(token in correctTokens) {
			correctToken += token
			correctToken += " "
		}
		
		if(begin == "") {
			for(key in commands getKeys()) {
				if(key startsWith("")) {
					suggs add(key)
				}
			}
		}
		
		if(suggs size() > 1) {
			if(correctToken == "") {
				cprintln("avalaible commands:")
			} else {
				cprintln("%s →" format(buffer))
			}
			for(sugg in suggs) {
				cprintln(" • %s" format(sugg))
			}
            
            limit := 9999999
            for(sugg in suggs) {
                len := sugg length()
                if(limit > len) {
                    limit = len
                }
            }
            
            finished := false
            best := 0
            while(best < limit) {
                for(sugg1 in suggs) {
                    for(sugg2 in suggs) {
                        if(sugg1 as Pointer == sugg2 as Pointer) continue
                        if(sugg1[best] != sugg2[best]) {
                            finished = true
                            break
                        }
                    }
                    if (finished) break
                }
                if (finished) break
                best += 1
            }
            setBuffer("%s%s" format(correctToken, suggs[0] substring(0, best)))
            
		} else if(suggs size() == 1) {
			setBuffer("%s%s " format(correctToken, suggs[0]))
		} else {
			match(status) {
				case COMMAND => cprintln("Sorry, no command begins with '%s'"  format(buffer))
				case SHOW    => cprintln("Sorry, no entity begins with '%s'"   format(correctTokens last()))
				case ENT     => cprintln("Sorry, no property begins with '%s'" format(correctTokens last()))
			}
		}
			
	}
	
	cprint: func(line: String) {
		firstLine: String = null
		if(lines size() > 0)
			firstLine = lines get(0)
		
		if(firstLine != null) {
			lines set(0,firstLine + line)
		} else {
			lines add(0,"")
			lines set(0,line)
		}
			
		printedLine = false
	}
	
	cprintln: func ~withcontent(line: String) {
		if(!printedLine) {
			first := lines get(0)
			if(first != null) {
				lines set(0,first + line)
			} else {
				lines add(0,line)
				printedLine = true
			}	
		} else {
			lines add(0,line)
			printedLine = true
		}
		
		if(lines size() > 100)
			lines removeLast()
	}
	
	cprintln: func ~empty {
		if(printedLine) {
			lines add(0,"")
		}
		printedLine = true
		if(lines size() > 100)
			lines removeLast()
	}
	
	end2D: func {
		glMatrixMode(GL_PROJECTION);
        glPopMatrix();
        glMatrixMode(GL_MODELVIEW);
        glPopMatrix();

        glEnable(GL_DEPTH_TEST);
        glDisable(GL_BLEND)
	}
	
	background: func {
		alpha2 := alpha
		if(hovered && !bottoms && !tops && !lefts && !rights && !ulcorners && !urcorners && !dlcorners && !drcorners && focus)
			alpha2 = alpha + 30
		
		glBegin(GL_QUADS)
			glColor4ub(255, 255, 255,alpha2)
			glVertex2i(0, 0)
			glVertex2i(size x, 0)
			glVertex2i(size x,size y)
			glVertex2i(0, size y)
		glEnd()         
	}
	
	drawText: func {
		//printf("rendering text\n")
		glPushMatrix()
		glTranslated(0,size y - 2 * inputHeight,0)
		bufferDraw()
		glPopMatrix()
	}
	
	render: func {
		pos  = get("position", Float3)
		size = get("size", Float2)
		
		begin2D()
		glTranslated(pos x, pos y, 0)
		background()
		round(border)
		glDisable(GL_BLEND)
		drawText()
		end2D()	
	}
	
	bufferDraw: func {
		glPushMatrix()
		glColor3ub(255,255,255)
		glTranslated(0, 0, 0)
		font render(1, inputHeight, 0.2, 1, buffer)
        
        // draw caret
        if(caretStart > 0) {
			bbox := font getFontBBox(caretStart)
            textWidth : Float = (bbox urx / 5)
            glTranslated(textWidth - 2, 0, 0)
        }
        font render(1, inputHeight, 0.2, 1, "|")
        
        upperpos := pos y
        posy := pos y + size y + 5
        
         if(caretStart > 0) {
			bbox := font getFontBBox(caretStart)
            textWidth : Float = (bbox urx / 5)
            glTranslated(2 - textWidth, 0, 0)
        }
        
        for(line in lines) {
			posy = posy - inputHeight
			if(posy < (upperpos + inputHeight*2))
				break
				
			if(posy == posy - inputHeight)
				break
			glTranslated(0,-inputHeight,0)
			font render(1, inputHeight, 0.2, 1, line)
		}
        
		glPopMatrix()
	}
	
	breakLine: func(_line: String) -> LinkedList<String> {
		elems := LinkedList<String> new()
		lastSpace := 0
		elemStart := 0
		line := _line clone()
		
		
		for(i in 0..line length()) {
			bbox := font getFontBBox(i - elemStart)
			textWidth : Float = (bbox urx / 5)
			if(textWidth > (size x - 50)) {
				//line split()
			}
			if(line[i] == ' ')
				lastSpace = i
		}
		return elems
	}
	
	command: func(cm: String) {
		if(cm == "") {
			cprintln(String new(20))
			return
		}
		history add(0,cm)
		lines add(0,cm)
		tokenizer := StringTokenizer new(cm," ")
		
		
		token := tokenizer nextToken()
        command := commands get(token)
        if(command == null) {
            cprintln("Unknown command: " + token)
        } else {
            command action(this, tokenizer)
		}
		
		/*
		match(token) {
			case "quit" => {sendAll(QuitMessage new())}
		}
		*/
		
	}
	
	round: func(size: Float) {
		alpha2 := alpha
		if(((bottom || top || left || right || ulcorner || urcorner || dlcorner || drcorner && !selected) ||
			(bottoms || tops || lefts || rights || ulcorners || urcorners || dlcorners || drcorners)) && focus)
			alpha2 += 30
		glColor4ub(255,255,255,alpha2)
		glPushMatrix()
		//drawing the upper left corner
		angle1 := PI
		angle2 := 3.0*PI/2.0
		step := PI/2.0/10.0
		glBegin(GL_TRIANGLE_FAN)
		glVertex2f(0,0)
		while(angle1 <= angle2) {
			glVertex2f(cos(angle1)*size,sin(angle1)*size)
			angle1 += step
		}
		glVertex2f(cos(angle2)*size,sin(angle2)*size)
		glEnd()
		
		//upper right
		glTranslated(this size x,0,0)
		angle1 = 3.0*PI/2.0
		angle2 = 4.0*PI/2.0
		glBegin(GL_TRIANGLE_FAN)
		glVertex2f(0,0)
		while(angle1 <= angle2) {
			glVertex2f(cos(angle1)*size,sin(angle1)*size)
			angle1 += step
		}
		glVertex2f(cos(angle2)*size,sin(angle2)*size)
		glEnd()
		
		//lower right
		glTranslated(0,this size y,0)
		angle1 = 0.0
		angle2 = PI/2.0
		glBegin(GL_TRIANGLE_FAN)
		glVertex2f(0,0)
		while(angle1 <= angle2) {
			glVertex2f(cos(angle1)*size,sin(angle1)*size)
			angle1 += step
		}
		glVertex2f(cos(angle2)*size,sin(angle2)*size)
		glEnd()
		
		//lower left
		glTranslated(-this size x,0,0)
		angle1 = PI/2.0
		angle2 = PI
		step = angle1/10.0
		glBegin(GL_TRIANGLE_FAN)
		glVertex2f(0,0)
		while(angle1 <= angle2) {
			glVertex2f(cos(angle1)*size,sin(angle1)*size)
			angle1 += step
		}
		glVertex2f(cos(angle2)*size,sin(angle2)*size)
		glEnd()
		
		glPopMatrix()
		
		glPushMatrix()
		glBegin(GL_QUADS)
			glVertex2f(0,0)
			glVertex2f(0 - size,0)
			glVertex2f(0 - size,0 + this size y)
			glVertex2f(0,0 + this size y)
		glEnd()
		
		glBegin(GL_QUADS)
			glVertex2f(0,0 - size)
			glVertex2f(0 + this size x,0 - size)
			glVertex2f(0 + this size x,0)
			glVertex2f(0,0)
		glEnd()
		
		glBegin(GL_QUADS)
			glVertex2f(0 + this size x,0)
			glVertex2f(0 + this size x + size,0)
			glVertex2f(0 + this size x + size,0 + this size y)
			glVertex2f(0 + this size x,0 + this size y)
		glEnd()
		
		glBegin(GL_QUADS)
			glVertex2f(0,0 + this size y)
			glVertex2f(0,0 + this size y + size)
			glVertex2f(0 + this size x,0 + this size y + size)
			glVertex2f(0 + this size x,0 + this size y)
		glEnd()
		glPopMatrix()
	}
}