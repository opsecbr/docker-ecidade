FROM ubuntu:22.04

LABEL maintainer="github@opsec.com.br"
ENV GIT_SSH_COMMAND "ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"

# Habilita modo não interativo na instalação de pacotes
ENV DEBIAN_FRONTEND noninteractive

# Desabilita o cache do gerenciador de pacote
RUN echo "Acquire::http {No-Cache=True;};" > /etc/apt/apt.conf.d/no-cache

# Atualiza a lista de repositórios
RUN apt-get update

# Instala as dependências deste container
RUN apt-get install -y --no-install-recommends tzdata \
  locales \
  software-properties-common \
  curl \
  unzip \
  zip \
  pigz \
  vim \
  sqlite3 \
  wget \
  language-pack-gnome-pt \
  language-pack-pt-base \
  myspell-pt \
  myspell-pt-br \
  wbrazilian \
  wportuguese \
  ghostscript \
  git \
  gpg-agent \
  ssh \
  file \
  supervisor

# Instala o repositório do PostgreSQL
RUN wget -O- https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor | tee /usr/share/keyrings/postgresql.gpg && \
  echo "deb [arch=amd64,arm64,ppc64el signed-by=/usr/share/keyrings/postgresql.gpg] http://apt.postgresql.org/pub/repos/apt/ jammy-pgdg main" | tee /etc/apt/sources.list.d/postgresql.list

# Instala o repositório PPA do PHP
RUN apt-add-repository -y ppa:ondrej/php

# Configura a timezone do container para America/Sao_Paulo
ENV TZ America/Sao_Paulo
RUN echo $TZ > /etc/timezone && \
  cp /usr/share/zoneinfo/${TZ} /etc/localtime && \
  dpkg-reconfigure -f noninteractive tzdata

# Ajusta a codificação de ordenação para o LATIN1
RUN sed -i "s|copy \"iso14651_t1\"|copy \"iso14651_t1\"\nreorder-after <U00A0>\n<U0020><CAP>;<CAP>;<CAP>;<U0020>\nreorder-end|" /usr/share/i18n/locales/pt_BR

# Regera o locales
RUN localedef -i pt_BR -c -f ISO-8859-1 -A /usr/share/locale/locale.alias pt_BR && \
  locale-gen pt_BR && \
  echo "locales locales/default_environment_locale select pt_BR.UTF-8" | debconf-set-selections && \
  dpkg-reconfigure --frontend noninteractive locales

# Atualiza a lista de repositórios
RUN apt-get update

# Aceita os termos EULA para o pacote MS Core Fonts e instala o pacote
RUN echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | debconf-set-selections && \
  apt-get install -y --no-install-recommends ttf-mscorefonts-installer

# Instala o cliente PSQL
RUN apt-get install -y --no-install-recommends postgresql-client-11

# Instala o Libreoffice Writer
RUN apt-get install -y --no-install-recommends libreoffice-writer

# Instala o pacote do servidor web Apache2
RUN apt-get install -y --no-install-recommends \
  apache2

# Instala os pacotes do PHP como módulo FPM
RUN apt-get install -y --no-install-recommends \
  php5.6 \
  php5.6-bcmath \
  php5.6-bz2 \
  php5.6-cli \
  php5.6-common \
  php5.6-curl \
  php5.6-imagick \
  php5.6-gd \
  php5.6-interbase \
  php5.6-json \
  php5.6-mbstring \
  php5.6-mcrypt \
  php5.6-pgsql \
  php5.6-soap \
  php5.6-sqlite3 \
  php5.6-xml \
  php5.6-xmlrpc \
  php5.6-zip \
  php5.6-intl \
  php5.6-opcache \
  php5.6-readline \
  php5.6-fpm \
  php5.6-xdebug

# Habilita o xdebug no PHP
RUN echo "xdebug.remote_enable=on" >> /etc/php/5.6/mods-available/xdebug.ini && \
  echo "xdebug.remote_autostart=off" >> /etc/php/5.6/mods-available/xdebug.ini

# Ajusta a permissão do imagick
RUN sed -i "s|<policy domain=\"coder\" rights=\"none\" pattern=\"PDF\" />|<policy domain=\"coder\" rights=\"read\|write\" pattern=\"PDF\" />|" /etc/ImageMagick-6/policy.xml

# Ajusta as configurações PHP como módulo FPM
RUN sed -i "s|^pm\ =.*|pm = ondemand|" /etc/php/5.6/fpm/pool.d/www.conf && \
  sed -i "s|^pm.max_children.*|pm.max_children = 300|" /etc/php/5.6/fpm/pool.d/www.conf && \
  sed -i "s|^pm.process_idle_timeout.*|pm.process_idle_timeout = 60s|" /etc/php/5.6/fpm/pool.d/www.conf && \
  sed -i "s|^pm.max_requests.*|pm.max_requests = 500|" /etc/php/5.6/fpm/pool.d/www.conf

# Ajusta as configurações do Apache2
RUN sed -i "s|^MaxRequestWorkers.*|MaxRequestWorkers         350|" /etc/apache2/mods-available/mpm_event.conf && \
  echo "umask 002" >> /etc/apache2/envvars && \
  a2enmod rewrite ssl proxy_fcgi setenvif && \
  a2enconf php5.6-fpm && \
  a2disconf serve-cgi-bin && \
  a2dissite 000-default.conf

# Instala o composer
RUN curl -sS https://getcomposer.org/installer -o composer-setup.php && \
  php composer-setup.php --install-dir=/usr/local/bin --filename=composer && \
  rm composer-setup.php

# Instala o node.js para suporte a módulos compilados com o NPM
RUN curl -sL https://deb.nodesource.com/setup_16.x | bash - && \
  apt-get install -y gcc g++ make nodejs

# Exporta variável que permite a execução do composer como root sem emitir avisos
ENV PATH=$PATH:/root/composer/vendor/bin COMPOSER_ALLOW_SUPERUSER=1

# Adiciona vhosts
ADD apache2/ecidade.conf /etc/apache2/sites-available/

# Configura o php.ini com os parâmetros necessários para o e-cidade
RUN ln -s /dev/stderr /var/log/php_errors.log && \
  chown www-data. /var/log/php_errors.log && \
  sed -i 's|^short_open_tag = .*|short_open_tag = On|g' /etc/php/5.6/fpm/php.ini && \
  sed -i 's|^session.gc_maxlifetime = .*|session.gc_maxlifetime = 7200|g' /etc/php/5.6/fpm/php.ini && \
  sed -i 's|^;date.timezone =.*|date.timezone = "America/Sao_Paulo"|g' /etc/php/5.6/fpm/php.ini && \
  sed -i 's|^;error_log.*|error_log = /var/log/php_errors.log|g' /etc/php/5.6/fpm/php.ini && \
  sed -i 's|^short_open_tag = .*|short_open_tag = On|g' /etc/php/5.6/cli/php.ini && \
  sed -i 's|^session.gc_maxlifetime = .*|session.gc_maxlifetime = 7200|g' /etc/php/5.6/cli/php.ini && \
  sed -i 's|^;date.timezone =.*|date.timezone = "America/Sao_Paulo"|g' /etc/php/5.6/cli/php.ini && \
  sed -i 's|^;error_log.*|error_log = /var/log/php_errors.log|g' /etc/php/5.6/cli/php.ini

# Configura o Supervisor
RUN mkdir -p /run/php/
COPY supervisord/supervisord.conf /etc/supervisor/supervisord.conf
COPY supervisord/conf.d/ /etc/supervisor/conf.d/

RUN useradd -d /home/dbseller -g www-data -G sudo,adm,cdrom,dip,plugdev -k /etc/skel -m -s /bin/bash dbseller

# Limpa os temporários
RUN apt-get clean && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/cache/*

# Adiciona o script de inicialiação
COPY ./scripts/iniciar.sh /iniciar.sh
RUN chmod 755 /iniciar.sh

EXPOSE 80

WORKDIR /var/www/html

CMD ["/bin/bash", "/iniciar.sh"]
