CFG_DIR  = $(DESTDIR)/etc/panetrie
HOOK_DIR = $(DESTDIR)/usr/share/libalpm/hooks
HOOK_BIN_DIR = $(DESTDIR)/usr/share/libalpm/scripts
BIN_DIR  = $(DESTDIR)/usr/bin

CFGFILENAME = panetrie.conf

.PHONY: install
install:
	@mkdir -p $(CFG_DIR)
	@mkdir -p $(HOOK_DIR)
	@mkdir -p $(BIN_DIR)
	@mkdir -p ${HOOK_BIN_DIR}
	@cp src/panetrie.sh $(HOOK_BIN_DIR)
	@chmod 755 $(HOOK_BIN_DIR)/panetrie.sh
	@ln -s $(HOOK_BIN_DIR)/panetrie.sh $(BIN_DIR)/panetrie
	@cp src/panetrie.hook $(HOOK_DIR)
	@chmod 644 $(HOOK_DIR)/panetrie.hook
	@cp etc/panetrie.conf $(CFG_DIR)
	@chmod 644 $(CFG_DIR)/panetrie.conf

.PHONY: uninstall
uninstall:
	@rm -rf $(CFG_DIR)
	@rm $(HOOK_DIR)/panetrie.hook
	@rm $(BIN_DIR)/panetrie
	@rm ${HOOK_BIN_DIR}/panetrie.sh