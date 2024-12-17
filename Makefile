include .make.env

.ONESHELL:

REMOTE_ID:=1
ADDR:=606$(REMOTE_ID)
FGPROF:=go tool pprof -http=":8888" http://localhost:$(ADDR)/debug/fgprof
PPROF:=go tool pprof -http=":8889" http://localhost:$(ADDR)/debug/pprof/profile
SUBDIRS:=remote
SUBTARGETS:=bench maji pull replace backup replace app-replace nginx-replace mysql-replace restart app-restart nginx-restart mysql-restart fluentbit-enable fluentbit-disable build score log log-cont nginx-check mysql mysql-root metrics-on metrics-off access-on access-off kataribe slow slow-on slow-off

.PHONY: fgprof
fgprof:
	$(FGPROF)

.PHONY: pprof
pprof:
	$(PPROF)

.PHONY: $(SUBTARGETS)
$(SUBTARGETS): $(SUBDIRS)

.PHONY: $(SUBDIRS)
$(SUBDIRS):
	make -C $@ $(MAKECMDGOALS)
