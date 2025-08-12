#!/bin/bash

# Script universal para instalar e configurar o Fish Shell.
# Adaptado para funcionar em ambientes com e sem privilégios de sudo.

# --- Configuração ---
CONFIG_DIR="$HOME/.config/fish"
CONFIG_FILE="$CONFIG_DIR/config.fish"
FUNCTIONS_SOURCE_FILE="$(dirname "$0")/functions.fish"

# --- Funções Auxiliares ---
print_info() {
    echo "INFO: $1"
}

print_warning() {
    echo "AVISO: $1"
}

print_error() {
    echo "ERRO: $1" >&2
    exit 1
}

# --- Detecção de Ambiente ---
# Prioriza a detecção do Termux
if test -d /data/data/com.termux; then
    PM="termux"
else
    PM=""
    if command -v apt &> /dev/null; then PM="apt";
    elif command -v pacman &> /dev/null; then PM="pacman";
    elif command -v dnf &> /dev/null; then PM="dnf";
    elif command -v zypper &> /dev/null; then PM="zypper";
    fi
fi

# --- Lógica Principal ---

# Se for Termux, executa um fluxo de instalação simplificado
if [ "$PM" = "termux" ]; then
    print_info "Ambiente Termux detectado. Iniciando configuração para Termux."

    # 1. Instalar dependências ('which' e 'fish')
    print_info "Verificando e instalando dependências (which, fish)..."
    pkg update -y && pkg upgrade -y
    pkg install -y which fish
    [ $? -ne 0 ] && print_error "Falha ao instalar pacotes essenciais no Termux."

    # 2. Definir Fish como shell padrão
    FISH_PATH=$(which fish)
    if [ -z "$FISH_PATH" ]; then
        print_error "Não foi possível encontrar o executável do Fish após a instalação."
    fi

    if [ "$SHELL" != "$FISH_PATH" ]; then
        print_info "Definindo Fish como o shell padrão..."
        chsh -s "$FISH_PATH"
        if [ $? -eq 0 ]; then
            print_info "Fish definido como shell padrão. Reinicie o Termux para aplicar."
        else
            print_warning "Falha ao definir o shell padrão no Termux."
        fi
    else
        print_info "O Fish já é o shell padrão."
    fi

else
    # --- Lógica para outros sistemas (Linux com sudo) ---
    print_info "Ambiente Linux padrão detectado. Verificando privilégios de sudo..."

    if ! command -v sudo &> /dev/null; then
        print_error "O comando 'sudo' não foi encontrado. Para instalar o Fish, execute este script com um usuário que tenha privilégios de sudo ou peça a um administrador para instalar o 'fish'."
    fi

    # 1. Verificar a instalação do 'which'
    if ! command -v which &> /dev/null; then
        print_warning "O comando 'which' não está instalado."
        print_info "Tentando instalar 'which' via $PM com sudo..."
        case $PM in
            "apt")    sudo apt update && sudo apt install -y which ;;
            "pacman") sudo pacman -S --noconfirm which ;;
            "dnf")    sudo dnf install -y which ;;
            "zypper") sudo zypper install -y which ;;
            *)        print_warning "Não foi possível instalar 'which' automaticamente. O script pode falhar." ;;
        esac
    fi

    # 2. Verificar a instalação do Fish Shell
    if ! command -v fish &> /dev/null; then
        print_warning "O Fish Shell não está instalado."
        print_info "Tentando instalar o Fish Shell via $PM com sudo..."
        case $PM in
            "apt")    sudo apt update && sudo apt install -y fish ;;
            "pacman") sudo pacman -S --noconfirm fish ;;
            "dnf")    sudo dnf install -y fish ;;
            "zypper") sudo zypper install -y fish ;;
            *)        print_error "Gerenciador de pacotes '$PM' não suportado para instalação automática." ;;
        esac
        [ $? -ne 0 ] && print_error "Falha ao instalar o Fish Shell."
        print_info "Fish Shell instalado com sucesso."
    else
        print_info "O Fish Shell já está instalado."
    fi

    # 3. Tentar definir o Fish como shell padrão
    FISH_PATH=$(which fish)
    [ -z "$FISH_PATH" ] && print_error "Não foi possível encontrar o executável do Fish no PATH."

    if [ "$SHELL" != "$FISH_PATH" ]; then
        print_info "Tentando definir o Fish como o shell padrão..."
        chsh -s "$FISH_PATH"
        if [ $? -ne 0 ]; then
            print_warning "Não foi possível alterar o shell padrão com 'chsh'. Verifique se '$FISH_PATH' está em /etc/shells."
            print_info "Como alternativa, adicione 'exec fish' ao seu ~/.bashrc ou ~/.zshrc."
        else
            print_info "Fish definido como shell padrão. Faça logout e login novamente."
        fi
    else
        print_info "O Fish já é o shell padrão."
    fi
fi

# --- Configuração Comum a Todos os Ambientes ---

# 4. Configurar as funções do Fish (operação a nível de usuário)
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
    echo "# --- Funções Personalizadas (Instaladas em: $(date)) ---"
    cat "$FUNCTIONS_SOURCE_FILE"
    echo "# --- Fim das Funções ---"
} >> "$CONFIG_FILE"

print_info "Funções adicionadas com sucesso a '$CONFIG_FILE'."
echo ""
echo "--- Configuração Concluída! ---"
echo "Por favor, reinicie seu terminal ou execute 'source ~/.config/fish/config.fish' para aplicar as alterações."
