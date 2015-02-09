CFLAGS = `pkg-config --cflags opencv`
LIBS = `pkg-config --libs opencv`

% : src/%.cpp
	g++ $(CFLAGS) -o $@ $< $(LIBS)