ARG GLPI_VERSION=11.0.8
FROM glpi/glpi:${GLPI_VERSION}

COPY --chown=www-data:www-data ./plugins* ${GLPI_MARKETPLACE_DIR}