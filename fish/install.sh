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
PM=""
# A detecção do PM ainda é útil para mensagens de ajuda.
if command -v apt &> /dev/null; then PM="apt";
elif command -v pacman &> /dev/null; then PM="pacman";
elif command -v dnf &> /dev/null; then PM="dnf";
elif command -v zypper &> /dev/null; then PM="zypper";
elif test -d /data/data/com.termux; then PM="termux"; fi

# --- Lógica Principal ---

# 1. Verificar a instalação do 'which' (necessário para 'chsh' e outras verificações)
if ! command -v which &> /dev/null; then
    print_warning "O comando 'which' não está instalado."
    if [ "$PM" = "termux" ]; then
        print_info "Tentando instalar 'which' via pkg..."
        pkg install -y which
        [ $? -ne 0 ] && print_error "Falha ao instalar 'which'. O script não pode continuar."
    else
        # Na maioria dos sistemas Linux, 'which' vem pré-instalado.
        # Se não estiver, o usuário pode precisar de sudo.
        if command -v sudo &> /dev/null; then
            print_info "Tentando instalar 'which' via $PM com sudo..."
            case $PM in
                "apt")    sudo apt update && sudo apt install -y which ;;
                "pacman") sudo pacman -S --noconfirm which ;;
                "dnf")    sudo dnf install -y which ;;
                "zypper") sudo zypper install -y which ;;
                *)        print_warning "Não foi possível instalar 'which' automaticamente. O script pode falhar." ;;
            esac
        else
            print_warning "Comando 'sudo' não encontrado. Não é possível instalar 'which' automaticamente."
        fi
    fi
fi

# 2. Verificar a instalação do Fish Shell
print_info "Verificando a instalação do Fish Shell..."
if ! command -v fish &> /dev/null; then
    print_warning "O Fish Shell não está instalado."
    # Verifica se o sudo está disponível
    if command -v sudo &> /dev/null; then
        print_info "Tentando instalar o Fish Shell via $PM com sudo..."
        case $PM in
            "apt")    sudo apt update && sudo apt install -y fish ;;
            "pacman") sudo pacman -S --noconfirm fish ;;
            "dnf")    sudo dnf install -y fish ;;
            "zypper") sudo zypper install -y fish ;;
            "termux") pkg update -y && pkg upgrade -y && pkg install -y fish ;; # Termux não usa sudo
            *)        print_error "Gerenciador de pacotes '$PM' não suportado para instalação automática." ;;
        esac
        [ $? -ne 0 ] && print_error "Falha ao instalar o Fish Shell. Peça ajuda a um administrador."
        print_info "Fish Shell instalado com sucesso."
    else
        print_error "O comando 'sudo' não foi encontrado. Por favor, peça a um administrador para instalar o 'fish' no sistema."
    fi
else
    print_info "O Fish Shell já está instalado."
fi

# 3. Tentar definir o Fish como shell padrão
FISH_PATH=$(which fish)
[ -z "$FISH_PATH" ] && print_error "Não foi possível encontrar o executável do Fish no PATH."

if [ "$SHELL" != "$FISH_PATH" ]; then
    print_info "Tentando definir o Fish como o shell padrão..."
    # O chsh no Termux não precisa de privilégios especiais
    if [ "$PM" = "termux" ]; then
        chsh -s "$FISH_PATH"
        if [ $? -eq 0 ]; then
            print_info "Fish definido como shell padrão. Inicie uma nova sessão para a alteração ter efeito."
        else
            print_warning "Falha ao definir o shell padrão no Termux."
        fi
    else
        # Tenta usar chsh. Se falhar, oferece uma alternativa.
        chsh -s "$FISH_PATH"
        if [ $? -ne 0 ]; then
            print_warning "Não foi possível alterar o shell padrão com 'chsh'. Isso pode ser por falta de permissão ou porque '$FISH_PATH' não está em /etc/shells."
            print_info "Como alternativa, você pode iniciar o Fish automaticamente adicionando a seguinte linha ao seu arquivo de configuração de shell atual (ex: ~/.bashrc, ~/.zshrc ou ~/.profile):"
            echo ""
            echo "  if [ -t 1 ]; then"
            echo "    exec fish"
            echo "  fi"
            echo ""
        else
            print_info "Fish definido como shell padrão. Para que a alteração tenha efeito, pode ser necessário fazer logout e login novamente."
        fi
    fi
else
    print_info "O Fish já é o shell padrão."
fi

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