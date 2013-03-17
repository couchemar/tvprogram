REBAR = ./rebar

clean:
	${REBAR} clean

deps:
	${REBAR} get-deps

compile:
	${REBAR} compile

run:
	@erl -pa deps/*/ebin -pa ebin -s tvprogram

all: clean compile run