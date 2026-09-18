DOCKER =
COMPOSE =
EXEC =
GLPI =
GLPI_EXEC =
GLPI_CLI =
GLPI_MARKETPLACE =

docker-setter:
	$(eval DOCKER := docker)
	$(eval COMPOSE := $(DOCKER) compose)
	$(eval EXEC := $(COMPOSE) exec -T)
	$(eval EXEC_ROOT := $(COMPOSE) exec -T -u root)

glpi-setter: docker-setter
	$(eval GLPI := glpi)
	$(eval GLPI_EXEC := $(EXEC) $(GLPI))
	$(eval GLPI_EXEC_ROOT := $(EXEC_ROOT) $(GLPI))
	$(eval GLPI_CLI := $(GLPI_EXEC) php bin/console)
	$(eval GLPI_MARKETPLACE := $(shell $(GLPI_EXEC) env | grep '^GLPI_MARKETPLACE_DIR=' | cut -d= -f2-))


up: docker-setter
	$(COMPOSE) up -d --build

down: docker-setter
	$(COMPOSE) down -v --remove-orphans

prune: docker-setter
	$(COMPOSE) prune -a --force

install: glpi-setter
	$(GLPI_CLI) plugin:install $(plugin) -n
	$(GLPI_CLI) plugin:enable $(plugin) -n

uninstall: glpi-setter
	$(GLPI_CLI) plugin:disable $(plugin) -n
	$(GLPI_CLI) plugin:uninstall $(plugin) -n
	$(GLPI_CLI) cache:clear -n

update-files: glpi-setter
	$(GLPI_EXEC_ROOT) rm -rf $(GLPI_MARKETPLACE)/$(plugin)
	$(COMPOSE) cp plugins/$(plugin) $(GLPI):$(GLPI_MARKETPLACE)/
	$(GLPI_EXEC_ROOT) chown -R www-data:www-data $(GLPI_MARKETPLACE)/$(plugin)

plugin-reset: glpi-setter uninstall update-files install
