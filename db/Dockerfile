FROM postgres:11.19-bullseye

ENV DEBIAN_FRONTEND noninteractive

RUN echo "Acquire::http {No-Cache=True;};" > /etc/apt/apt.conf.d/no-cache

RUN apt-get update

RUN apt-get install -y --no-install-recommends tzdata \
  locales \
  myspell-pt \
  myspell-pt-br \
  wbrazilian \
  wportuguese

ENV TZ America/Sao_Paulo
RUN echo $TZ > /etc/timezone && \
  cp /usr/share/zoneinfo/${TZ} /etc/localtime && \
  dpkg-reconfigure -f noninteractive tzdata

RUN sed -i "s|copy \"iso14651_t1\"|copy \"iso14651_t1\"\nreorder-after <U00A0>\n<U0020><CAP>;<CAP>;<CAP>;<U0020>\nreorder-end|" /usr/share/i18n/locales/pt_BR && \
  sed -i "s|^#\ pt_BR ISO-8859-1|pt_BR ISO-8859-1|g" /etc/locale.gen && \
  sed -i "s|^#\ pt_BR.UTF-8 UTF-8|pt_BR.UTF-8 UTF-8|g" /etc/locale.gen

RUN localedef -i pt_BR -c -f ISO-8859-1 -A /usr/share/locale/locale.alias pt_BR && \
  locale-gen pt_BR
#  echo "locales locales/default_environment_locale select pt_BR.UTF-8" | debconf-set-selections && \
#  dpkg-reconfigure --frontend noninteractive locales

ENV LANG pt_BR.UTF-8
ENV LANGUAGE pt_BR:pt
ENV LC_ALL pt_BR.UTF-8

