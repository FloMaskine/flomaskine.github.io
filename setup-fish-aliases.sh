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

# 2. Criar o diretório se ele não existir
mkdir -p "$(dirname "$CONFIG_FILE")"

# 3. Adicionar os aliases ao novo arquivo usando um "here document"
echo "Adicionando Aliases..."

# O 'cat << EOF' envia o texto entre 'EOF' para o arquivo especificado.
# O '-' após '<<' permite que você indente o texto no script sem que a indentação
# seja gravada no arquivo final. 'EOF' pode ser qualquer marcador único.
cat <<- EOF > "$CONFIG_FILE"
alias upd="apt update && apt upgrade && pkg update && pkg upgrade"
alias aliasconfig="nano ~/.config/fish/config.fish"
alias instale="apt install"
alias la="ls -a"
alias rst="cd ~"
alias cc="clear"
EOF

echo "Aliases adicionados com sucesso em $CONFIG_FILE!"

# 4. Instruções para o usuário recarregar o Fish shell
echo "Para que os aliases entrem em vigor, por favor, **inicie uma nova sessão do Fish shell** ou execute o seguinte comando no seu terminal Fish atual:"
echo "source ~/.config/fish/config.fish"

sleep 2s
clear

echo "Configuração concluída."
