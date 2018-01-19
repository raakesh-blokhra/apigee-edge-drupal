FROM wodby/drupal-php:7.1

RUN composer global require "hirak/prestissimo:^0.3"

ARG MODULE_NAME="drupal"

ARG DEPENDENCIES="highest"

ENV COMPOSER_OPTIONS="--working-dir=/var/www/html/web"

# We are using drupal-composer/drupal-project instead of drupal/drupal because we would like to update all
# libraries, including Drupal, to the latest version when doing "highest" testing.
RUN composer create-project drupal-composer/drupal-project:8.x-dev /var/www/html --no-interaction

# This library has to be updated to the latest version, because the lowest installed 2.0.4 is in conflict with
# one of the Apigee PHP SDK's required library's (symfony/property-info:^3.2) mininmum requirement.
# We have to update Drush too, because 8.1.15 does not work with Drupal 8.4 and also conflicts with
# phpdocumentor/reflection-docblock too.
RUN composer require drush/drush:^9.0 && composer require phpdocumentor/reflection-docblock:^3.0.2

COPY --chown=www-data:www-data . "${WODBY_DIR_FILES}/${MODULE_NAME}"

RUN composer config repositories.library path "${WODBY_DIR_FILES}/${MODULE_NAME}" \
    && composer require drupal/${MODULE_NAME}

RUN if [[ "$DEPENDENCIES" = 'highest' ]]; then composer update -o --with-dependencies; fi

# Show the installed package versions for debugging purposes.
RUN composer show
