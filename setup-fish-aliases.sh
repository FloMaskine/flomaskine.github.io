#!/bin/bash

# Define o caminho completo para o arquivo de configuração do Fish shell
CONFIG_FILE="$HOME/.config/fish/config.fish"

echo "Iniciando a adição de aliases ao seu arquivo Fish shell..."

# 1. Garante que o diretório ~/.config/fish exista
# O '-p' cria os diretórios pais se não existirem e não dá erro se já existirem.
mkdir -p "$(dirname "$CONFIG_FILE")"
echo "Verificando/criando o diretório: $(dirname "$CONFIG_FILE")"

# 2. Adiciona os aliases ao final do arquivo config.fish usando um "here document"
# O '>>' é usado para ADICIONAR (append) ao final do arquivo.
# O 'cat <<- EOF' lê as linhas seguintes até encontrar o 'EOF' final,
# e redireciona esse conteúdo para o arquivo.
# O '-' após '<<' remove as tabulações do início de cada linha, mantendo o arquivo limpo.
echo "Adicionando os seguintes aliases ao $CONFIG_FILE:"
cat <<- EOF >> "$CONFIG_FILE"

# Aliases adicionados via script bash em $(date +"%Y-%m-%d %H:%M:%S")
alias upd="apt update && apt upgrade && pkg update && pkg upgrade"
alias aliasconfig="nano ~/.config/fish/config.fish"
alias instale="apt install"
alias la="ls -a"
alias rst="cd ~"
alias cc="clear"
EOF

echo "Aliases adicionados com sucesso!"
