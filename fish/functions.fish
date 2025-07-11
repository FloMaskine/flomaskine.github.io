# Funções do Fish Shell para múltiplos ambientes
# Instalado por script em $(date)

# Atualiza os pacotes do sistema (detecta o gerenciador de pacotes)
function upd
    if command -v apt &> /dev/null
        sudo apt update && sudo apt upgrade -y
    else if command -v pacman &> /dev/null
        sudo pacman -Syuu --noconfirm
    else if command -v dnf &> /dev/null
        sudo dnf upgrade -y
    else if command -v zypper &> /dev/null
        sudo zypper dup --non-interactive
    else if command -v pkg &> /dev/null
        pkg update -y && pkg upgrade -y
    else
        echo "Gerenciador de pacotes não suportado para atualização."
    end
end

# Instala pacotes (detecta o gerenciador de pacotes)
function instale
    if command -v apt &> /dev/null
        sudo apt install -y $argv
    else if command -v pacman &> /dev/null
        sudo pacman -S --noconfirm $argv
    else if command -v dnf &> /dev/null
        sudo dnf install -y $argv
    else if command -v zypper &> /dev/null
        sudo zypper install -y $argv
    else if command -v pkg &> /dev/null
        pkg install -y $argv
    else
        echo "Gerenciador de pacotes não suportado para instalação."
    end
end

# Edita a configuração do fish
function fishconfig
    if command -v nano &> /dev/null
        nano ~/.config/fish/config.fish
    else
        vi ~/.config/fish/config.fish
    end
end

# Recarrega a configuração do fish
function fishreload
    source ~/.config/fish/config.fish
end

# Lista todos os arquivos, incluindo os ocultos
function la
    ls -a $argv
end

# Vai para o diretório raiz (ou home para o termux) e limpa a tela
function rst
    if test -d /data/data/com.termux
        cd ~ && clear
    else
        cd / && clear
    end
end

# Limpa a tela
function c
    clear
end

# Funções para o Git
function gs
    git status
end

function ga
    git add $argv
end

function gc
    git commit -m "$argv"
end

function gp
    git push
end
