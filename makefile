nodekit_linux = node-webkit-v0.4.2-linux-ia32
nodekit_linux_bin = $(nodekit_linux)/nw
r3_linux = r3-g6a79a7b

#r3 works on wine, node-stuff not
r3_windows = r3-g6a79a7b.exe
nodekit_windows = node-webkit-v0.4.2-win-ia32
nodekit_windows_bin = node-webkit-v0.4.2-win-ia32/nw.exe

all: coffee run-nk
#all: run-r3

run-r3-wine: $(r3_windows) r3.exe
	wine r3 -cs scrapbook.r3

run-r3: $(r3_linux) r3
	./r3 -cs scrapbook.r3

run-nk: coffee $(nodekit_linux_bin) $(r3_linux) r3
	$(nodekit_linux_bin) .
	pgrep r3; true #terminate-check
	
run-no: coffee
	node coffee/main.js
	
run-nos: coffee
	node coffee/scrapbook.js

coffee: coffee/main.js coffee/scrapbook.js

coffee/%.js: %.coffee
	coffee -c -o coffee/ $< 
	
$(nodekit_linux_bin):
	wget -c https://s3.amazonaws.com/node-webkit/v0.4.2/node-webkit-v0.4.2-linux-ia32.tar.gz
	tar -xzf $(nodekit_linux).tar.gz
	ls -l $(nodekit_linux_bin)

$(r3_linux):
	wget -c http://www.rebolsource.net/downloads/linux-x86/r3-g6a79a7b
	chmod +x $(r3_linux)
	rm r3
	ln -s $(r3_linux) r3

r3.exe:
	wget -c http://www.rebolsource.net/downloads/win32-x86/r3-g6a79a7b.exe
	cp -a $(r3_windows) r3.exe
	
	
#######################################	
# nodekit-childprocess does not work on wine, raw node crashes.
# could not test
#######################################

run-nk-w: coffee $(nodekit_windows_bin) $(r3_windows) r3.exe
	$(nodekit_windows_bin) .
	
$(nodekit_windows_bin): r3.exe
	wget -c https://s3.amazonaws.com/node-webkit/v0.4.2/node-webkit-v0.4.2-win-ia32.zip
	unzip node-webkit-v0.4.2-win-ia32.zip



