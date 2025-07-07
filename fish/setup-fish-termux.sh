#!/data/data/com.termux/files/usr/bin/bash

# Define o caminho completo para o diretório de configuração do Fish shell no Termux
CONFIG_DIR="$HOME/.config/fish"
CONFIG_FILE="$CONFIG_DIR/config.fish"

echo "--- Iniciando a configuração do Fish Shell no Termux ---"

# 1. Instalar o Fish Shell no Termux
echo "1. Instalando o Fish Shell..."
# Verifica se o Fish já está instalado
if ! command -v fish &> /dev/null; then
    pkg update -y
    pkg upgrade -y
    pkg install -y fish
    if [ $? -eq 0 ]; then
        echo "Fish Shell instalado com sucesso."
    else
        echo "Erro ao instalar o Fish Shell. Verifique sua conexão ou repositórios."
        exit 1
    fi
else
    echo "Fish Shell já está instalado."
fi

# 2. Configurar o Termux para iniciar o Fish como shell padrão
echo "2. Configurando o Fish como seu shell padrão no Termux..."
# No Termux, você define o shell padrão usando o comando 'termux-setup-storage'
# e modificando o arquivo '~/.bashrc' ou usando 'chsh'. 'chsh' é o mais comum, mas
# para o Termux, é mais robusto adicionar a chamada ao fish no .bashrc.
# No entanto, o Termux tem um comando 'chsh' simplificado que podemos usar.
FISH_PATH=$(which fish)

if [ -z "$FISH_PATH" ]; then
    echo "Não foi possível encontrar o executável do Fish. Algo deu errado na instalação."
    exit 1
fi

# Tenta usar o chsh do Termux (é diferente do chsh de sistemas Linux completos)
chsh -s "$FISH_PATH"
if [ $? -eq 0 ]; then
    echo "Fish Shell definido como padrão. Esta mudança terá efeito na próxima sessão do Termux."
else
    echo "Erro ao definir o Fish como shell padrão com chsh. Tentando método alternativo no .bashrc..."
    # Método alternativo para o Termux: Adicionar 'fish' ao .bashrc para iniciar
    # Nota: Este método pode causar um loop se o fish não estiver configurado corretamente.
    # É geralmente preferível usar 'chsh' no Termux se ele funcionar.
    if ! grep -q "exec fish" "$HOME/.bashrc"; then
        echo -e "\n# Iniciar Fish Shell automaticamente\nexec fish" >> "$HOME/.bashrc"
        echo "Adicionado 'exec fish' ao ~/.bashrc para iniciar o Fish automaticamente."
    else
        echo "A linha 'exec fish' já existe no ~/.bashrc."
    fi
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

# Aliases adicionados via script bash no Termux em $(date +"%Y-%m-%d %H:%M:%S")
alias upd='pkg update -y && pkg upgrade -y'
alias aliasconfig='nano $HOME/.config/fish/config.fish'
alias aliasupd='source $HOME/.config/fish/config.fish'
alias la='ls -a'
alias rst='cd /data/data/com.termux/files/home && clear' # Redireciona para o HOME do Termux
alias c='clear'
alias instale='pkg install -y'
EOF

echo "Aliases adicionados com sucesso ao $CONFIG_FILE!"
echo "---"

echo "Configuração concluída!"
echo "Para que as mudanças entrem em vigor (especialmente o novo shell padrão e os aliases):"
echo "1. Feche e abra uma nova sessão do Termux."
echo "2. Ou, se já estiver no Fish, execute: source ~/.config/fish/config.fish"
echo ""
echo "Nota: O alias 'rst' agora aponta para o diretório HOME padrão do Termux: '/data/data/com.termux/files/home'."