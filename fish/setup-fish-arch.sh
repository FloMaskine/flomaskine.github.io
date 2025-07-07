#!/bin/bash

# Define o caminho completo para o diretório de configuração do Fish shell
CONFIG_DIR="$HOME/.config/fish"
CONFIG_FILE="$CONFIG_DIR/config.fish"

echo "--- Iniciando a configuração do Fish Shell ---"

# 1. Instalar o Fish Shell
echo "1. Instalando o Fish Shell..."
# Verifica se o Fish já está instalado
if ! command -v fish &> /dev/null; then
    sudo pacman -S --noconfirm fish
    if [ $? -eq 0 ]; then
        echo "Fish Shell instalado com sucesso."
    else
        echo "Erro ao instalar o Fish Shell. Verifique sua conexão ou permissões."
        exit 1
    fi
else
    echo "Fish Shell já está instalado."
fi

# 2. Definir o Fish como o shell padrão
echo "2. Definindo o Fish como seu shell padrão..."
# Obtém o caminho completo do executável do Fish
FISH_PATH=$(which fish)

if [ -z "$FISH_PATH" ]; then
    echo "Não foi possível encontrar o executável do Fish. Certifique-se de que ele está no seu PATH."
    exit 1
fi

# Adiciona o Fish à lista de shells válidos se ainda não estiver lá
if ! grep -q "$FISH_PATH" /etc/shells; then
    echo "$FISH_PATH" | sudo tee -a /etc/shells > /dev/null
    echo "Adicionado '$FISH_PATH' a /etc/shells."
fi

# Altera o shell padrão para o usuário atual
echo "Você será solicitado a digitar sua senha para alterar o shell padrão."
chsh -s "$FISH_PATH"
if [ $? -eq 0 ]; then
    echo "Fish Shell definido como padrão. Esta mudança terá efeito na próxima sessão de terminal."
else
    echo "Erro ao definir o Fish como shell padrão. Tente manualmente: chsh -s $(which fish)"
fi

# 3. Criar o diretório ~/.config/fish se ele não existir
echo "3. Verificando/criando o diretório de configuração do Fish: $CONFIG_DIR"
mkdir -p "$CONFIG_DIR"

# 4. Adicionar os aliases ao final do arquivo config.fish
echo "4. Adicionando os aliases ao $CONFIG_FILE..."

# Usa um "here document" para adicionar o bloco de aliases
# O '>>' adiciona ao final do arquivo.
# O '-' após '<<' remove as tabulações do início de cada linha, mantendo o arquivo limpo.
cat <<- 'EOF' >> "$CONFIG_FILE"

# Aliases adicionados via script bash em $(date +"%Y-%m-%d %H:%M:%S")
alias upd='sudo pacman -Syuu'
alias aliasconfig='nano $HOME/.config/fish/config.fish'
alias aliasupd='source $HOME/.config/fish/config.fish'
alias la='ls -a'
alias rst='cd / && clear'
alias c='clear'
alias instale='sudo pacman -S'
EOF

echo "Aliases adicionados com sucesso ao $CONFIG_FILE!"
echo "---"

echo "Configuração concluída!"
echo "Para que as mudanças entrem em vigor (especialmente o novo shell padrão e os aliases):"
echo "1. Feche e abra uma nova janela/aba do terminal."
echo "2. Ou, na sua sessão atual do Fish, execute: source ~/.config/fish/config.fish"