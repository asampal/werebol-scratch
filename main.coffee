inBrowser = typeof window != "undefined"
haveNode = typeof process != "undefined"
haveNodekit = inBrowser && haveNode

if not inBrowser && 1 # testmacromatic
	bye = () ->
		quitR3()
	setTimeout bye, 1000
	
if haveNode
	spawn = require('child_process').spawn

if haveNodekit
	console.error "IGNORE rendersandbox when in nodekit, not implemented"
	gui = require 'nw.gui'
	win = gui.Window.get()
	quitR3 = null
	win.on 'close', () ->
		quitR3()
		this.close true
		
dir = if haveNodekit then "#{process.cwd()}/coffee" else __dirname

g_id = 0
ls = null
nextTick = null

G = (name) ->
	this.log = []
	this.start = new Date()
	this.id = ++ g_id
	this.name = name
	this
	
g = null

main = () ->
	plog "dir #{dir} exe #{process.execPath}"

	d = "#{dir}/.."
	log "spawning"	
	ls = spawn "#{d}/r3", ["-cs","#{d}/partner.r3"], {stdio: 'pipe'}

	send "init"
	
	process.nextTick task "listen", () ->
		
		buf = ""
		
		quitR3 = callout () ->
			send "quit"
			plog()
			
		ls.stdout.on "data", callout (data) ->
			#log "stdout: " + data
			buf += data
			#log "buf: #{buf}"
			while m = buf.match /(.*?)\n([^]*)/m
				line = m[1]
				buf = m[2]
				#log "got #{m[1]} --- #{m[2]}"
				if line.match /^\*\* /
					log "r3error: #{line}#{buf}"
					clearTimeout nextTick
					#process.exit()
				else if line.match /^~ /
					plog "< #{line}"
					if a = line.match /^~ (\w*) (.*)/
						cmd = a[1]
						args = a[2]
						args = JSON.parse args if args
						handle cmd, args
					else 
						a = line.match /^~ (.*)/
						cmd = a[1]
						handle cmd
				else
					r3log line
			plog()		

		ls.stderr.on "data", callout (data) ->
		  plog "stderr: " + data

		ls.on "exit", callout (code) ->
		  plog "child done res: " + code

	plog "done"
	
send = (s, v) ->
	if v
		v = JSON.stringify v
		log "-> #{s} #{v}"
		ls.stdin.write "#{s} #{v}\n"
	else
		log "-> #{s}"
		ls.stdin.write "#{s}\n"
	
plog = (o) ->
	if o != undefined then log o
	d = new Date()
	header = "task: #{g.id}, #{g.name} @#{d}"
	console.log header
	console.log g.log
	logBrowser "#{header}\n#{JSON.stringify g.log}\n"
	g.log = ["..."]
	
logBrowser = (s) ->
	if inBrowser 
		$("#log").append s
		$("#log").prop "scrollTop", $("#log").prop "scrollHeight"


log = (o) ->
	g.log.push o
	o
	
r3log = (o) ->
	o = "r3log: #{o}"
	console.log o
	logBrowser "#{o}\n"

callout = (f, go = g) ->
	f.g = go
	(args...) ->
		if g
			throw new Exception "task runs in task!"
		g = f.g
		try f args... catch e
			console.log "callout failed:"
			console.log e.stack
			log e
			plog()
			g = null
			return
		g = null
		
task = (name,f) ->
	callout f, new G(name)
	
handle = (cmd, args) ->
	plog "#{cmd} -:- #{args}"
	# switch cmd
	# 	when "info" then log "#{args[0]} #{args[2]}"
	plog()

	
#last!
if inBrowser then Zepto task "main",main else do task "main",main

		
		




