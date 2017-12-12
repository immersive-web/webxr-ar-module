.PHONY: all spec/latest/index.html

all: latest

latest: spec/latest/index.html

spec/latest/index.html: spec/latest/index.bs
	curl https://api.csswg.org/bikeshed/ -F file=@spec/latest/index.bs -F output=err
	curl https://api.csswg.org/bikeshed/ -F file=@spec/latest/index.bs -F force=1 > spec/latest/index.html | tee
