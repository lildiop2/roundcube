FROM roundcube/roundcubemail:latest

# Instalar dependências e tzdata para o fuso horário
RUN apt-get update && apt-get install -y \
    unzip \
    git \
    cron \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Configurar fuso horário para Brasil/São Paulo no sistema
ENV TZ=America/Sao_Paulo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Instalar o Composer e o plugin (conforme antes)
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
WORKDIR /var/www/html
RUN composer require "texxasrulez/scheduled_sending" --no-update && composer update --no-dev

# CRON e Entrypoint (conforme antes)
RUN echo "* * * * * www-data /usr/bin/php /var/www/html/plugins/scheduled_sending/bin/send_scheduled.php > /dev/null 2>&1" >> /etc/cron.d/roundcube-schedule
RUN chmod 0644 /etc/cron.d/roundcube-schedule
RUN echo '#!/bin/bash\ncron\ndocker-php-entrypoint apache2-foreground' > /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]