#!/bin/bash

# Script universal para instalar e configurar o Fish Shell.
# Detecta automaticamente o gerenciador de pacotes (apt, pacman, dnf, zypper, termux).

# --- Configuração ---
CONFIG_DIR="$HOME/.config/fish"
CONFIG_FILE="$CONFIG_DIR/config.fish"
FUNCTIONS_SOURCE_FILE="$(dirname "$0")/functions.fish"

# --- Funções Auxiliares ---
print_info() {
    echo "INFO: $1"
}

print_error() {
    echo "ERRO: $1" >&2
    exit 1
}

# --- Detecção de Ambiente e Gerenciador de Pacotes ---
PM=""
if command -v apt &> /dev/null; then
    PM="apt"
    print_info "Detectado gerenciador de pacotes APT (Debian/Ubuntu)."
elif command -v pacman &> /dev/null; then
    PM="pacman"
    print_info "Detectado gerenciador de pacotes PACMAN (Arch Linux)."
elif command -v dnf &> /dev/null; then
    PM="dnf"
    print_info "Detectado gerenciador de pacotes DNF (Fedora/CentOS)."
elif command -v zypper &> /dev/null; then
    PM="zypper"
    print_info "Detectado gerenciador de pacotes ZYPPER (openSUSE)."
elif test -d /data/data/com.termux; then
    PM="termux"
    print_info "Detectado ambiente Termux."
else
    print_error "Nenhum gerenciador de pacotes suportado foi encontrado."
fi

# --- Lógica de Instalação ---

# 1. Instalar o Fish Shell
print_info "Verificando a instalação do Fish Shell..."
if ! command -v fish &> /dev/null; then
    print_info "Instalando o Fish Shell via $PM..."
    case $PM in
        "apt")    sudo apt update && sudo apt install -y fish ;;
        "pacman") sudo pacman -S --noconfirm fish ;;
        "dnf")    sudo dnf install -y fish ;;
        "zypper") sudo zypper install -y fish ;;
        "termux") pkg update -y && pkg upgrade -y && pkg install -y fish ;;
    esac
    [ $? -ne 0 ] && print_error "Falha ao instalar o Fish Shell."
    print_info "Fish Shell instalado com sucesso."
else
    print_info "O Fish Shell já está instalado."
fi

# 2. Definir o Fish como shell padrão
FISH_PATH=$(which fish)
[ -z "$FISH_PATH" ] && print_error "Não foi possível encontrar o executável do Fish no PATH."

if [ "$SHELL" != "$FISH_PATH" ]; then
    print_info "Definindo o Fish como o shell padrão..."
    if [ "$PM" = "termux" ]; then
        chsh -s "$FISH_PATH" || print_error "Falha ao definir o shell padrão no Termux."
    else
        # Para a maioria das distros Linux
        if ! grep -qF "$FISH_PATH" /etc/shells; then
            print_info "Adicionando '$FISH_PATH' a /etc/shells."
            echo "$FISH_PATH" | sudo tee -a /etc/shells > /dev/null
        fi
        chsh -s "$FISH_PATH" || print_error "Falha ao definir o shell padrão. Tente manualmente: chsh -s $FISH_PATH"
    fi
    print_info "Fish definido como shell padrão. Inicie uma nova sessão para a alteração ter efeito."
else
    print_info "O Fish já é o shell padrão."
fi

# 3. Configurar o Fish
print_info "Configurando o Fish..."
mkdir -p "$CONFIG_DIR"
[ ! -f "$FUNCTIONS_SOURCE_FILE" ] && print_error "Arquivo de funções '$FUNCTIONS_SOURCE_FILE' não encontrado."

# Faz backup e adiciona as funções
if [ -f "$CONFIG_FILE" ]; then
    BACKUP_FILE="$CONFIG_FILE.bak.$(date +%F-%T)"
    print_info "Fazendo backup da configuração existente para $BACKUP_FILE"
    cp "$CONFIG_FILE" "$BACKUP_FILE"
fi

{
    echo ""
    echo "# --- Funções Personalizadas (Última atualização: $(date)) ---"
    cat "$FUNCTIONS_SOURCE_FILE"
    echo "# --- Fim das Funções ---"
} >> "$CONFIG_FILE"

print_info "Funções adicionadas com sucesso a '$CONFIG_FILE'."
echo ""
echo "--- Configuração Concluída! ---"
echo "Por favor, reinicie seu terminal ou execute 'source ~/.config/fish/config.fish' para aplicar as alterações."
