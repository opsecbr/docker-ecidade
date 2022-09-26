# docker-ecidade

Repositório com Dockerfile para uso no desenvolvimento do e-cidade na versão 5.6 do PHP

## Requisitos

- A estação de trabalho deve ter o docker instalado
- Clone deste respositório na máquina local

## Criando a imagem do container

```bash
$ git clone https://github.com/opsecbr/docker-ecidade.git
$ cd docker-ecidade
$ docker build --rm -t opsec:php56-dev .
```

## Inicalizando o container

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

> Você também pode inicializar o container a partir de qualquer diretório, informando o caminho absoluto da aplicação do e-cidade, por exemplo:
>
> ```bash
> docker run --rm -d -v /caminho/onde/esta/aplicação/e-cidade:/var/www/html -p 8080:80 opsec:php56-dev
> ```

## Acessando o ambiente do container

Após executar o comando para inicializar o container, abra o navegador e acesse o endereço:

`http://localhost:8080/`

> Caso não seja possível acessar a aplicação, pode ser problema de permissão e/ou problema com o proprietário dos arquivos, para corrigir esta situação execute o comando para entrar no container:
>
> ```bash
> $ docker exec -it ecidade bash
> ```
> 
> Em seguida, execute os comandos comandos abaixo **DENTRO DO CONTAINER** para acertar as permissões e propriedades dos arquivos para o usuário **www-data** (apache):
> 
> ```bash
> $ find /var/www/html -type d -print | xargs -I% --max-args=1 --max-procs=100 chmod 775 "%"
> $ find /var/www/html -type f -print | xargs -I% --max-args=1 --max-procs=100 chmod 664 "%
> $ chown -R www-data.www-data /var/www/html
> ```