# docker-ecidade

Repositório com Dockerfile para uso no desenvolvimento do e-cidade na versão 5.6 do PHP

## Requisitos

- A estação de trabalho deve ter o docker instalado
- Clone deste respositório na máquina local

## Usando os recursos no modo `standalone`

### Criando a imagem do container para o modo `standalone`

```bash
$ git clone https://github.com/opsecbr/docker-ecidade.git
$ cd docker-ecidade
$ docker build --rm -t opsec:php56-dev ./web
```

### Inciando o container no modo `standalone`

```bash
$ cd /caminho/onde/esta/aplicação/e-cidade
$ docker run --rm -d -v ${PWD:-.}:/var/www/html -p 8080:80 --name ecidade opsec:php56-dev
```

O comando acima tem as seguintes funções:
- `docker run` : Comando para colocar um container em execução;
- `--rm` : Opção que remove o container quando o mesmo é finalizado;
- `-d` : Opção que faz com que o container seja executado em segundo plano;
- `-v ${PWD:-.}:/var/www/html` : Opção que mapeia o diretório local para dentro do container;
- `-p 8080:80` : Opção que mapeia a porta 8080 da estação local para a porta 80 dentro do container;
- `--name ecidade` : Opção que atribui um nome para o container em execução;
- `opsec:php56-dev` : Opção que define a imagem que será utilizada para iniciar o container.

> Caso o seu sistema operacional não seja Linux, você pode informar o caminho absoluto para o diretório do e-cidade no comando de inicialização do container.

Você também pode inicializar o container a partir de qualquer diretório, informando o caminho absoluto da aplicação do e-cidade, por exemplo:

```bash
docker run --rm -d -v /caminho/onde/esta/aplicação/e-cidade:/var/www/html -p 8080:80 opsec:php56-dev
```

### Variáveis de ambiente para o modo `standalone`

O uso das variáveis de ambiente é **opcional**.

> Se a variável não for informada, ou se seu valor for vazio, não será realizada nenhuma alteração nos arquivos de configuração.

> A inicialização do container só realizará alterações se os arquivos `libs/db_conn.php` e `.env` já existirem no projeto.

DB_USUARIO
- Parâmetro opcional. Informa qual é o usuário de acesso ao banco de dados.

DB_SENHA
- Parâmetro opcional. Informa qual é a senha de acesso ao banco de dados.

DB_SERVIDOR
- Parâmetro opcional. Informa qual o endereço do servidor de banco de dados.

DB_PORTA
- Parâmetro opcional. Informa qual é a porta do servidor de banco de dados.

DB_BASE
- Parâmetro opcional. Informa qual é o nome do banco de dados a ser utilizado.

### Inciando o container no modo `standalone` utilizando variáveis de ambiente

```bash
$ cd /caminho/onde/esta/aplicação/e-cidade
$ docker run --rm -d -v ${PWD:-.}:/var/www/html -p 8080:80 --name ecidade \
    -e DB_USUARIO=ecidade \
    -e DB_SENHA=senha \
    -e DB_SERVIDOR=192.168.10.100 \
    -e DB_PORTA=5432 \
    -e DB_BASE=basededados \
    opsec:php56-dev
```

> **Não utilize os valores `localhost` ou `127.0.0.1` na configuração de conexão do container, pois ele vai considerar a conexão da interface de rede do `loopback/interna dentro do container` e não vai conseguir no banco de dados do computador hospedeiro.**

## Usando os recursos no modo `stack`

### Configurando as variáveis dos containers para o modo `stack`

```bash
$ git clone https://github.com/opsecbr/docker-ecidade.git
$ cd docker-ecidade
$ nano .env
```

O uso das variáveis de ambiente é **obrigatório**.

> A inicialização do container `web` só realizará alterações se os arquivos `libs/db_conn.php` e `.env` já existirem no projeto.

CAMINHO_FONTES_ECIDADE
- Parâmetro obrigatório. Define qual é o caminho dos fontes do e-cidade.

PORTA_HTTP_ECIDADE
- Parâmetro obrigatório. Define qual é a porta HTTP que será utilizada para acessar a aplicação do e-cidade.

PORTA_HTTP_ADMINER
- Parâmetro obrigatório. Define qual é a porta HTTP que será utilizada para acessar a aplicação Adminer.

DB_USUARIO
- Parâmetro obrigatório. Define qual é o usuário de acesso ao banco de dados.

DB_SENHA
- Parâmetro obrigatório. Define qual é a senha de acesso ao banco de dados.

DB_SERVIDOR
- Parâmetro obrigatório. Define qual o endereço do servidor de banco de dados.

DB_BASE
- Parâmetro obrigatório. Define qual é o nome do banco de dados a ser utilizado.

### Inciando os containers no modo `stack`

Após configurar o arquivo **.env** execute o comando dentro do diretório do projeto:

```bash
$ docker compose up -d
```

### Realizando a carga da base de dados no modo `stack`

Testando a conexão na base de dados:

```bash
$ docker exec -i docker-ecidade-db-1 psql -U ecidade -d ecidade -l
```

Se o comando foi executado com sucesso, a carga da base de dados pode ser realizada através do comando:

```bash
$ docker exec -i docker-ecidade-db-1 psql -U ecidade -d ecidade < /caminho/arquivo/sql/da/base.sql
```

## Acessando o ambiente do container

Após executar o comando para inicializar o(s) container(s), abra o navegador e acesse o endereço:

`http://localhost:8080/`

> Caso não seja possível acessar a aplicação, pode ser problema de permissão e/ou problema com o proprietário dos arquivos, para corrigir esta situação execute o comando para entrar no container:

```bash
$ docker exec -it ecidade bash
```
 
> Em seguida, execute os comandos comandos abaixo **DENTRO DO CONTAINER** para acertar as permissões e propriedades dos arquivos para o usuário **www-data** (apache):
 
```bash
$ find /var/www/html -type d -print | xargs -I% --max-args=1 --max-procs=100 chmod 775 "%"
$ find /var/www/html -type f -print | xargs -I% --max-args=1 --max-procs=100 chmod 664 "%
$ chown -R www-data.www-data /var/www/html
```
