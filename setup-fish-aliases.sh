#!/bin/bash

# Define o caminho do arquivo de configuração
CONFIG_FILE="$HOME/.config/fish/config.fish"

echo "Iniciando a configuração dos aliases do Fish shell..."

# 1. Excluir o arquivo existente (se houver)
if [ -f "$CONFIG_FILE" ]; then
    echo "Removendo arquivo de configuração existente: $CONFIG_FILE"
    rm "$CONFIG_FILE"
else
    echo "Arquivo de configuração não encontrado, criando um novo."
fi

# 2. Criar o diretório se ele não existir (importante para ~/.config/fish)
mkdir -p "$(dirname "$CONFIG_FILE")"

# 3. Adicionar os aliases ao novo arquivo
echo "Adicionando Aliases..."
echo "
alias upd=\"apt update && apt upgrade && pkg update && pkg upgrade\"
alias aliasconfig=\"nano ~/.config/fish/config.fish\"
alias instale=\"apt install\"
alias la=\"ls -a\"
alias rst=\"cd ~\"
alias cc=\"clear\"
" > "$CONFIG_FILE" # Use '>' para criar/sobrescrever o arquivo

echo "Aliases adicionados com sucesso em $CONFIG_FILE!"

# 4. Instruções para o usuário recarregar o Fish shell
echo "Para que os aliases entrem em vigor, por favor, **inicie uma nova sessão do Fish shell** ou execute o seguinte comando no seu terminal Fish atual:"
echo "source ~/.config/fish/config.fish"

sleep 2s
clear

echo "Configuração concluída."
