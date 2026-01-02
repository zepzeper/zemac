lua_fmt:
	echo "===> Formatting"
	stylua lua/ --config-path=.stylua.toml

lua_test:
	echo "===> Formatting"
	sleep 1000
	stylua lua/ --config-path=.stylua.toml

lua_fmt_check:
	echo "===> Checking format"
	stylua lua/ --config-path=.stylua.toml --check

lua_lint:
	echo "===> Linting"
	luacheck lua/ --globals vim

lua_clean:
	echo "===> Cleaning"
	rm /tmp/lua_*

pr_ready: lua_lint lua_test lua_fmt_check
