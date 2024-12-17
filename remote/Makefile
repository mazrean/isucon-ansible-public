include ../.make.env

REMOTE:=isu$(REMOTE_ID)

.ONESHELL:
SHELL:=ssh
.SHELLFLAGS:=-t -A $(REMOTE)

MYSQL_CMD:=mysql -h$(DB_HOST) -P$(DB_PORT) -u$(DB_USER) -p$(DB_PASS) $(DB_NAME)

.PHONY: bench
bench: backup pull replace fluentbit-enable metrics-on access-on build restart slow-on

.PHONY: maji
maji: backup pull replace fluentbit-disable metrics-off access-off build restart slow-off

.PHONY: pull
pull:
	cd $(REPO_DIR)
	git pull origin $(REPO_BRANCH)

.PHONY: backup
backup:
	sudo bash -c "when=$$(date "+%s")
	mkdir -p ~/logs/$$when
	if [ -f $(NGX_LOG) ]; then
		sudo mv -f $(NGX_LOG) ~/logs/$$when/
	fi
	if [ -f $(MYSQL_LOG) ]; then
		sudo mv -f $(MYSQL_LOG) ~/logs/$$when/
	fi"

.PHONY: replace
replace: app-replace nginx-replace mysql-replace other-replace

.PHONY: app-replace
app-replace:
	cd $(REPO_DIR)
	for p in $(APP_LIST); do
		cp -r -T $(REPO_DIR)/$(REPO_APP_PATH)/$$p $(APP_BASE)/$$p
	done

.PHONY: nginx-replace
nginx-replace:
	cd $(REPO_DIR)
	for p in $(NGX_CFG_LIST); do
		sudo cp -r -T $(REPO_DIR)/$(REPO_NGX_PATH)/$$p $(NGX_CFG_DIR)/$$p
	done

.PHONY: mysql-replace
mysql-replace:
	cd $(REPO_DIR)
	for p in $(MYSQL_CFG_LIST); do
		sudo cp -r -T $(REPO_DIR)/$(REPO_MYSQL_PATH)/$$p $(MYSQL_CFG_DIR)/$$p
		sudo chmod 644 $(MYSQL_CFG_DIR)/$$p
	done
	sudo chown -R $(MYSQL_USER):$(MYSQL_USER) $(MYSQL_CFG_DIR)

.PHONY: other-replace
other-replace:
	cd $(REPO_DIR)
	for p in $(OTHER_LIST); do
		sudo cp -r -T $(REPO_DIR)/$(REPO_OTHER_PATH)/$$(basename $$p) $$p
	done

.PHONY: restart
restart: app-restart nginx-restart mysql-restart

.PHONY: app-restart
app-restart:
	-sudo systemctl restart $(APP_SRV_NAME)

.PHONY: nginx-restart
nginx-restart: nginx-check
	-sudo systemctl restart $(NGX_SRV_NAME)

.PHONY: mysql-restart
mysql-restart:
	-sudo systemctl restart $(MYSQL_SRV_NAME)
	# 設定ファイルのpermission設定ミスなどでの読み込みスキップを検出
	! sudo journalctl -e -u  $(MYSQL_SRV_NAME) | tail -n 4 | grep -q ignored

.PHONY: fluentbit-enable
fluentbit-enable:
	-sudo systemctl enable $(FB_SRV_NAME)
	sudo systemctl start $(FB_SRV_NAME)

.PHONY: fluentbit-disable
fluentbit-disable:
	-sudo systemctl stop $(FB_SRV_NAME)
	sudo systemctl disable $(FB_SRV_NAME)

.PHONY: build
build:
	source ~/.profile
	cd $(BUILD_DIR)
	$(BUILD_CMD)

.PHONY: score
score:
	read -p "Enter score: " score
	curl -X POST -d "score=$$score" http://localhost:6060/benchmark/score

.PHONY: log
log:
	sudo journalctl -e -u $(APP_SRV_NAME)

.PHONY: log-cont
log-cont:
	sudo journalctl -e -f -u $(APP_SRV_NAME)

.PHONY: nginx-check
nginx-check:
	sudo nginx -t

.PHONY: mysql
mysql:
	$(MYSQL_CMD)

.PHONY: mysql-root
mysql-root:
	sudo mysql

.PHONY: slow
slow:
	sudo pt-query-digest $(MYSQL_LOG)

.PHONY: kataribe
kataribe:
	sudo cat $(NGX_LOG) | kataribe -f ./kataribe.toml

.PHONY: metrics-on
metrics-on:
	sudo sed -i -e 's/^Environment=ISUTOOLS_ENABLE=.*/Environment=ISUTOOLS_ENABLE=true/g' $(APP_SRV_FILE)
	sudo systemctl daemon-reload

.PHONY: metrics-off
metrics-off:
	sudo sed -i -e 's/^Environment=ISUTOOLS_ENABLE=.*/Environment=ISUTOOLS_ENABLE=false/g' $(APP_SRV_FILE)
	sudo systemctl daemon-reload

.PHONY: access-on
access-on:
	sudo sed -i -e 's/^.*access_log .*/  access_log ${NGX_LOG//\//\\\/} kataribe;/g' $(NGX_MAIN_CFG)

.PHONY: access-off
access-off:
	sudo sed -i -e 's/^.*access_log .*/  access_log off;/g' $(NGX_MAIN_CFG)

.PHONY: slow-on
slow-on:
	sudo mysql -e "set global slow_query_log=ON;set global slow_query_log_file='$(MYSQL_LOG)';set global long_query_time=0;"

.PHONY: slow-off
slow-off:
	sudo mysql -e "set global slow_query_log=OFF;"
