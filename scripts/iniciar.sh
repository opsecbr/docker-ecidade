#!/bin/bash

# Habilita o vhost do e-cidade no apache2
a2ensite ecidade.conf

: ${WWW_UID:=33}
: ${WWW_GID:=33}

# Mapeia o usuário e grupo do apache caso tenham sido configurados
# via variável de ambiente
usermod -u $WWW_UID www-data
groupmod -g $WWW_GID www-data

# Inicializa o supervisord
exec /usr/bin/supervisord  -n -c /etc/supervisor/supervisord.conf
