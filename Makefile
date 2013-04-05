REBAR = ./rebar

clean:
	${REBAR} clean

get-deps:
	${REBAR} get-deps

compile:
	${REBAR} compile

run:
	@coffee -o priv/public/js/ --join app.js -cw priv/public/coffee/ &
	@erl -pa deps/*/ebin -pa ebin -s tvprogram

all: clean compile run
