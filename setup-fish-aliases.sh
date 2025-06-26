##Adicionar aliases
echo "Adicionando Aliases"
rm ~/.config/fish/config.fish
echo "
alias upd="apt update && apt upgrade && pkg update && pkg upgrade"
alias aliasconfig="nano ~/.config/fish/config.fish"
alias instale="apt install"
alias la="ls -a"
alias rst="cd ~"
alias cc="clear"
alias ubuntu="proot-distro login ubuntu"
alias llm="bash ~/Termux-doomsday-LLM/run.sh"
alias start-alpine="qemu-system-x86_64 -machine q35 -m 1024 -smp cpus=2 -cpu qemu64 \
  -drive if=pflash,format=raw,read-only,file=$PREFIX/share/qemu/edk2-x86_64-code.fd \
  -netdev user,id=n1,hostfwd=tcp::2222-:22 -device virtio-net,netdev=n1 \
  -nographic alpine.img"

clear
" >> ~/.config/fish/config.fish
echo "Aliases adicionados com sucesso!"
echo "Restarting"
sleep 2s
reset
