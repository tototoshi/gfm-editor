init:
	pip install -r requirements.txt
	git submodule update --init
	(cd py-gfm && python setup.py install)
	npm install
build_asset:
	grunt coffee
	grunt less
run:
	nodemon --exec "python main.py"

.PHONY: init build_asset run
