#!/bin/sh
################################################################################
# OpenBSD 8.0 no ThinkPad X230: desktop Xfce                                   #
#                                                                              #
# Replica, até onde o OpenBSD permite, os programas do gnome.Brewfile          #
# (https://github.com/pedrohqb/brewfile), trocando por equivalentes o que      #
# não existe nos pacotes do OpenBSD.                                           #
#                                                                              #
# USO (depois da instalação, já com rede e com o seu usuário criado):          #
#   doas sh openbsd-x230.sh            # usa o usuário que chamou o doas       #
#   doas sh openbsd-x230.sh pedro      # ou indica o usuário                   #
#                                                                              #
# - Pode ser executado mais de uma vez: pacotes já instalados são pulados e    #
#   todo arquivo de configuração alterado ganha antes uma cópia .orig.         #
# - Pacote que não existir na sua versão não interrompe o script: ele entra    #
#   num resumo no fim.                                                         #
# - Exclua ou comente, nas listas abaixo, o que não for necessário.            #
#                                                                              #
# Licença: CC0-1.0. Pedro Henrique Quitete Barreto 2026                        #
################################################################################

set -u

# ------------------------------------------------------------------------------
# Ajustes rápidos
# ------------------------------------------------------------------------------
LAYOUT="xfce"                     # "xfce": painel padrão do Xfce; "gnome": barra superior, dock e janelas só com o botão de fechar
GTK_THEME="Greybird-dark"         # tema das janelas e dos programas
ICON_THEME="Papirus-Dark"         # tema de ícones
UI_FONT="Cantarell 11"            # fonte da interface (a clássica do GNOME)
MONO_FONT="JetBrains Mono 10"     # fonte do terminal e dos editores
IDIOMA="pt_BR.UTF-8"              # idioma da sessão gráfica
XKB_LAYOUT="us"                   # teclado: inglês americano...
XKB_VARIANT="intl"                # ...internacional, com teclas mortas para os acentos (' + c = ç)
TRACKPOINT_SCROLL="sim"           # rolar segurando o botão do meio do TrackPoint
LOGIN_BG="#241f31"                # cor de fundo da tela de login (xenodm)
TERMINAL_SHELL="/usr/local/bin/fish"  # shell que o Terminal do Xfce abre (vazio: o ksh de login)
HYPERTHREADING="sim"              # usa os 4 threads do processador (o OpenBSD desliga por segurança; "nao" mantém o padrão)
CACHE_DISCO=40                    # % da RAM para cache de arquivos (padrão do OpenBSD: 20)
WIFI_SSID=""                      # nome da rede Wi-Fi de casa (vazio: não configura)
WIFI_SENHA=""                     # senha da rede Wi-Fi (WPA2)
WEBAPP_BROWSER="chrome"           # navegador dos atalhos de aplicativos web

# ------------------------------------------------------------------------------
# Listas de pacotes (uma por categoria, na ordem do gnome.Brewfile)
# Formato: pacote  # descrição
# ------------------------------------------------------------------------------
PKG_DESKTOP='
xfce                    # Xfce: ambiente de trabalho (instalação básica)
xfce-extras             # Xfce: Whisker Menu, gerenciador de energia, volume, captura de tela, terminal e demais complementos
xfce4-docklike          # Docklike: barra de aplicativos em forma de dock (usada no LAYOUT="gnome")
greybird                # Greybird: tema de janelas e programas para o Xfce
papirus-icon-theme      # Papirus: tema de ícones
cantarell-fonts         # Cantarell: fonte de interface do GNOME
jetbrains-mono          # JetBrains Mono: fonte monoespaçada
noto-fonts              # Noto: fontes com cobertura ampla de idiomas
noto-emoji              # Noto Emoji: emojis coloridos
liberation-fonts        # Liberation: fontes com as métricas de Arial, Times e Courier
gvfs                    # GVfs: lixeira e pastas de rede no Thunar
gvfs-smb                # GVfs SMB: compartilhamentos Samba e Windows no Thunar (smb://servidor/pasta)
xdg-user-dirs           # xdg-user-dirs: cria Documentos, Downloads, Imagens etc.
xarchiver               # Xarchiver: compacta e extrai arquivos pelo Thunar
unzip                   # unzip: extrai arquivos .zip
7zip                    # 7-Zip: compacta e extrai .7z e outros formatos
papers                  # Papers: leitor de PDF do GNOME
mpv                     # mpv: reprodutor de vídeo
cups                    # CUPS: sistema de impressão
cups-filters            # cups-filters: filtros e drivers genéricos de impressão
system-config-printer   # system-config-printer: configura impressoras
brlaser                 # brlaser: driver de impressoras laser monocromáticas da Brother
xfce4-mount             # Mount: botão no painel para montar e desmontar pendrives e discos externos
xfce4-power-manager     # Gerenciador de energia do Xfce: bateria, brilho e desligamento da tela
upower                  # UPower: informa o estado da bateria ao Xfce
ntfs_3g                 # NTFS-3G: lê e grava discos externos em NTFS
exfat-fuse              # exFAT: lê e grava pendrives e cartões em exFAT
'

# Equivalentes dos aplicativos que já vêm instalados no Bluefin.
PKG_BLUEFIN='
galculator              # Galculator: calculadora (no lugar da Calculadora do GNOME)
gucharmap               # Gucharmap: mapa de caracteres (no lugar do Caracteres)
baobab                  # Baobab: analisador de uso de disco
simple-scan             # Simple Scan: digitalização de documentos
gnome-font-viewer       # Fontes: visualiza e instala fontes
thunderbird             # Thunderbird: cliente de e-mail da Mozilla
thunderbird-i18n-pt-BR  # Thunderbird: tradução para o português do Brasil
# (já cobertos pelo Xfce: Orage = agenda, Ristretto = imagens, Parole = vídeo e áudio,
#  Mousepad = editor de texto, Xarchiver = compactador, plugin de clima no painel;
#  o Snapshot, da webcam, depende do PipeWire e não roda: use o comando 'video')
'

PKG_CLI='
# Desenvolvimento
git                     # Git: controle de versão (necessário para o GitHub CLI)
github-cli              # GitHub CLI: gerencia repositórios, issues, pull requests e releases do GitHub pelo terminal
node                    # Node.js: executa JavaScript fora do navegador; inclui o npm

# Inteligência Artificial
codex                   # Codex: agente de IA da OpenAI que roda no terminal
# (Claude Code não tem versão para OpenBSD)

# Internet e Nuvem
rclone                  # rclone: sincroniza pastas com o OneDrive e outras nuvens (no lugar do onedrive-cli)
wireguard-tools         # WireGuard: comandos wg e wg-quick, para usar um arquivo .conf de VPN
yt-dlp                  # yt-dlp: baixa vídeos e áudios do YouTube e de centenas de outros sites

# PDF e OCR
ocrmypdf                # OCRmyPDF: adiciona camada de texto pesquisável (OCR) a PDFs digitalizados
pdfgrep                 # pdfgrep: pesquisa texto dentro de arquivos PDF, ao estilo do grep
qpdf                    # qpdf: divide, junta e gira PDFs pelo terminal
tesseract               # Tesseract: motor de OCR (usado pelo OCRmyPDF)
tesseract-por           # Tesseract: dados do idioma português

# Utilitários
GraphicsMagick          # GraphicsMagick: converte, redimensiona e edita imagens em lote
fdupes                  # fdupes: localiza arquivos duplicados (no lugar do rdfind)
ripgrep                 # ripgrep: procura texto dentro de arquivos em pastas inteiras
sysbench--              # sysbench: testa o desempenho de CPU, memória e disco pelo terminal
fastfetch               # fastfetch: mostra um resumo do sistema no terminal
nano                    # nano: editor de texto simples para o terminal
fish->=4                # fish: shell com sugestões e autocompletar (só no terminal gráfico; o login continua em ksh)
'

PKG_GUI='
# Áudio e Vídeo
audacity                # Audacity: editor e gravador de áudio multipista
kdenlive                # Kdenlive: editor de vídeo não linear
obs-studio              # OBS Studio: gravação de tela e transmissão ao vivo

# Comunicação
evolution               # Evolution: cliente de e-mail, contatos e calendário
evolution-ews           # Evolution EWS: contas do Microsoft 365 e do Exchange no Evolution
gnome-keyring           # GNOME Keyring: cofre de senhas (org.freedesktop.secrets) que o Evolution exige
tdesktop                # Telegram: cliente oficial de mensagens do Telegram
# (Discord, Teams, WhatsApp e Zoom: atalhos de aplicativo web, criados mais abaixo)

# Desenvolvimento
meld                    # Meld: compara e mescla arquivos e pastas lado a lado

# Escritório e PDF
libreoffice             # LibreOffice: suíte de escritório livre e completa
libreoffice-i18n-pt-br  # LibreOffice: tradução para o português do Brasil
pdfarranger             # PDF Arranger: junta, divide, gira, recorta e reordena páginas de PDFs
qownnotes               # QOwnNotes: notas em Markdown (no lugar do Joplin)
# (ONLYOFFICE e PDFsam Basic não existem para OpenBSD)

# Estudo e Leitura
# (o BibleTime não existe para OpenBSD)

# Gravação de Mídias
cdrtools                # cdrtools: grava CDs e DVDs pelo terminal (no lugar do Brasero)
dvd+rw-tools            # dvd+rw-tools: grava DVDs e Blu-rays pelo terminal

# Imagens e Fotografia
gimp->=3                # GIMP: editor de imagens avançado
pinta                   # Pinta: editor de imagens simples
shotwell                # Shotwell: organizador e visualizador de fotos

# Internet e Nuvem
chromium                # Chromium: navegador (no lugar do Brave); também abre os aplicativos web
firefox                 # Firefox: navegador livre da Mozilla
firefox-i18n-pt-BR      # Firefox: tradução para o português do Brasil
remmina                 # Remmina: cliente de área de trabalho remota, RDP e VNC (no lugar do Connections)
qbittorrent             # qBittorrent: cliente BitTorrent livre e sem anúncios

# Música e Rádio
gradio                  # Gradio: rádio pela internet (no lugar do Shortwave)
# (Spotify: sem cliente que funcione no OpenBSD 8.0; veja as observações do README)

# Segurança e Senhas
keepassxc--browser      # KeePassXC: gerenciador de senhas offline e de código aberto, com integração aos navegadores
opensc                  # OpenSC: tokens e cartões com suporte livre, como o ePass2003
ccid                    # CCID: driver genérico de leitoras de cartão USB
pcsc-lite               # PC/SC Lite: serviço de acesso a leitoras e tokens
# (Tessera e os drivers SafeNet, SafeSign e SerproID dependem de Linux;
#  o PJeOffice Pro tem script próprio: pjeoffice-openbsd.sh)

# Virtualização
qemu                    # QEMU: emulador de máquinas (sem aceleração; para VMs rápidas, use o vmd do próprio OpenBSD)
# (Wine, que substituiria o Bottles, não existe nos pacotes do OpenBSD 8.0)
'

# Aplicativos web: id|Nome|URL|ícone|categorias|navegador
# Ícone "site:dominio": baixa o ícone do próprio site (o tema não tem um para ele).
# Navegador "app": janela própria no $WEBAPP_BROWSER. Navegador "firefox": janela
# do Firefox, para Teams e Zoom, porque a webcam não funciona no Chromium do
# OpenBSD (ele abre a câmera, mas não recebe imagem).
WEBAPPS='
chatgpt|ChatGPT|https://chatgpt.com/|site:chatgpt.com|Network;|app
claude|Claude|https://claude.ai/|site:claude.ai|Network;|app
discord|Discord|https://discord.com/app|discord|Network;InstantMessaging;|app
teams|Microsoft Teams|https://teams.microsoft.com/|teams|Network;InstantMessaging;|firefox
whatsapp|WhatsApp|https://web.whatsapp.com/|whatsapp|Network;InstantMessaging;|app
zoom|Zoom|https://app.zoom.us/wc|Zoom|Network;VideoConference;|firefox
'

# ------------------------------------------------------------------------------
# Funções auxiliares
# ------------------------------------------------------------------------------
msg()  { printf '\n==> %s\n' "$*"; }
info() { printf '    %s\n' "$*"; }
warn() { printf '    AVISO: %s\n' "$*" >&2; AVISOS="${AVISOS}
  - $*"; }
AVISOS=""
FALTANDO=""

# Guarda uma cópia .orig antes da primeira alteração de um arquivo existente.
backup() { [ -e "$1" ] && [ ! -e "$1.orig" ] && cp -p "$1" "$1.orig"; return 0; }

# Grava a entrada padrão no arquivo indicado, criando a pasta e a cópia .orig.
put() {
	mkdir -p "$(dirname "$1")"
	backup "$1"
	cat > "$1"
}

# Instala os pacotes de uma lista, um a um, sem parar se algum não existir.
install_list() {
	printf '%s\n' "$1" | sed -e 's/#.*//' -e 's/[[:space:]]*$//' -e '/^$/d' |
	while read -r pkg; do
		# "nome->=N" escolhe a versão quando o OpenBSD oferece mais de uma.
		# "nome--variante" escolhe a variante (flavor) do pacote.
		case "$pkg" in
		*-\>*|*-\<*) spec="$pkg" ;;
		*--*)        spec="${pkg%%--*}-*" ;;
		*)           spec="${pkg}-*" ;;
		esac
		if pkg_info -e "$spec" >/dev/null 2>&1; then
			info "já instalado: $pkg"
			continue
		fi
		# O pkg_add nem sempre acusa erro quando o pacote tem variantes,
		# então o resultado é conferido com o pkg_info, não pelo retorno.
		pkg_add -I "$pkg" >/dev/null 2>&1
		pkg_info -e "$spec" >/dev/null 2>&1 || pkg_add -I "${pkg}--" >/dev/null 2>&1
		if pkg_info -e "$spec" >/dev/null 2>&1; then
			info "instalado:    $pkg"
		else
			info "NÃO INSTALOU: $pkg"
			echo "$pkg" >> "$TMP_FALTANDO"
		fi
	done
}

# ------------------------------------------------------------------------------
# Verificações
# ------------------------------------------------------------------------------
[ "$(uname -s)" = "OpenBSD" ] || { echo "Este script é para OpenBSD." >&2; exit 1; }
[ "$(id -u)" -eq 0 ] || { echo "Execute como root: doas sh $0 [usuário]" >&2; exit 1; }

ALVO="${1:-${DOAS_USER:-}}"
[ -n "$ALVO" ] || { echo "Indique o usuário: doas sh $0 usuário" >&2; exit 1; }
id "$ALVO" >/dev/null 2>&1 || { echo "Usuário '$ALVO' não existe." >&2; exit 1; }
[ "$ALVO" != "root" ] || { echo "Indique o seu usuário comum, não o root." >&2; exit 1; }
CASA="$(getent passwd "$ALVO" | cut -d: -f6)"
GRUPO="$(id -gn "$ALVO")"
[ -d "$CASA" ] || { echo "Pasta pessoal '$CASA' não encontrada." >&2; exit 1; }

TMP_FALTANDO="$(mktemp /tmp/faltando.XXXXXX)"
trap 'rm -f "$TMP_FALTANDO"' EXIT

msg "OpenBSD $(uname -r) em $(sysctl -n hw.version 2>/dev/null || sysctl -n hw.product); usuário: $ALVO"

# ------------------------------------------------------------------------------
# 1. Sistema: correções, firmware e doas
# ------------------------------------------------------------------------------
msg "Correções de segurança e firmware"
syspatch || info "syspatch: nada a aplicar (ou indisponível agora)"
fw_update || warn "fw_update falhou; rode 'doas fw_update' com a rede funcionando (Wi-Fi e vídeo Intel dependem dele)"

# Wi-Fi: o driver (iwn, rtwn...) é detectado pelo sistema; aqui só se grava a rede.
WLAN="$(ifconfig wlan 2>/dev/null | sed -n 's/^\([a-z]*[0-9]*\):.*/\1/p' | head -1)"
if [ -z "$WLAN" ]; then
	warn "nenhuma placa Wi-Fi reconhecida; veja 'dmesg | grep -i \"not configured\"' e rode 'doas fw_update' com o cabo de rede ligado"
elif [ -n "$WIFI_SSID" ] && [ ! -e "/etc/hostname.$WLAN" ]; then
	msg "Wi-Fi: rede '$WIFI_SSID' na placa $WLAN"
	( umask 027
	  printf 'join "%s" wpakey "%s"\ninet autoconf\ninet6 autoconf\n' \
		"$WIFI_SSID" "$WIFI_SENHA" > "/etc/hostname.$WLAN" )
	sh /etc/netstart "$WLAN" || warn "não consegui subir a rede $WLAN"
else
	msg "Wi-Fi: placa $WLAN reconhecida"
	[ -e "/etc/hostname.$WLAN" ] && info "/etc/hostname.$WLAN já existe: mantido" ||
		info "preencha WIFI_SSID e WIFI_SENHA no topo do script para gravar a rede"
fi

# doas: o grupo wheel administra com senha; montar e desmontar discos
# externos não pede senha (é o que o botão "Mount" do painel usa).
msg "doas (administração e montagem de discos externos)"
backup /etc/doas.conf
touch /etc/doas.conf
chmod 600 /etc/doas.conf
for regra in "permit persist :wheel" \
             "permit nopass $ALVO as root cmd mount" \
             "permit nopass $ALVO as root cmd umount" \
             "permit nopass $ALVO as root cmd ntfs-3g"; do
	grep -qxF "$regra" /etc/doas.conf || echo "$regra" >> /etc/doas.conf
done
doas -C /etc/doas.conf || warn "/etc/doas.conf com erro de sintaxe; confira (cópia em /etc/doas.conf.orig)"

# Desligar e reiniciar pelo menu do Xfce, sem senha de root.
usermod -G _shutdown "$ALVO" || warn "não consegui pôr $ALVO no grupo _shutdown"
mkdir -p "$CASA/usb" && chown "$ALVO:$GRUPO" "$CASA/usb"

# ------------------------------------------------------------------------------
# 2. Pacotes
# ------------------------------------------------------------------------------
msg "Ambiente de trabalho"
install_list "$PKG_DESKTOP"
msg "Aplicativos padrão do Bluefin (equivalentes)"
install_list "$PKG_BLUEFIN"
msg "Programas de linha de comando"
install_list "$PKG_CLI"
msg "Programas gráficos"
install_list "$PKG_GUI"

# ------------------------------------------------------------------------------
# 3. Sistema: serviços, energia e limites de memória
# ------------------------------------------------------------------------------
msg "Serviços"
for svc in messagebus xenodm apmd cupsd pcscd; do
	if rcctl enable "$svc" 2>/dev/null; then info "ativado: $svc"
	else warn "não consegui ativar o serviço $svc"; fi
done
# apmd: ajusta o desempenho sozinho e suspende com 7% de bateria.
rcctl set apmd flags -A -z 7 2>/dev/null || warn "não consegui ajustar o apmd"

# Fechar a tampa suspende o notebook, na tomada ou na bateria.
msg "Energia, desempenho, microfone e câmera (sysctl)"
backup /etc/sysctl.conf
touch /etc/sysctl.conf
DESEMPENHO="kern.bufcachepercent=$CACHE_DISCO"
# hw.blockcpu lista os tipos de núcleo fora do agendador; o padrão é SL
# (S = Hyper-Threading, L = núcleos lentos). Sem o S, o Hyper-Threading volta.
[ "$HYPERTHREADING" = "sim" ] && DESEMPENHO="$DESEMPENHO hw.blockcpu=L"
for linha in "machdep.lidaction=1" "kern.audio.record=1" "kern.video.record=1" $DESEMPENHO; do
	grep -qxF "$linha" /etc/sysctl.conf || echo "$linha" >> /etc/sysctl.conf
	sysctl "$linha" >/dev/null 2>&1 || true
done

# A webcam (/dev/video0) pertence ao root. O xenodm executa o GiveConsole como
# root a cada login gráfico; esta linha entrega a câmera a quem entrou.
msg "Webcam para o usuário da sessão gráfica"
GIVE=/etc/X11/xenodm/GiveConsole
if [ -f "$GIVE" ]; then
	grep -q '/dev/video0' "$GIVE" ||
		{ backup "$GIVE"; echo 'chown $USER /dev/video0' >> "$GIVE"; }
	[ -e /dev/video0 ] && chown "$ALVO" /dev/video0
else
	warn "$GIVE não existe; a webcam vai exigir 'doas chown $ALVO /dev/video0'"
fi

# Tela bloqueada ao voltar da suspensão. O apmd executa /etc/apm/suspend logo
# antes de suspender; isso cobre a tampa fechada e a bateria baixa. O botão
# "Suspender" do Xfce segue outro caminho e é coberto pela opção LockScreen.
msg "Bloqueio de tela ao suspender (/etc/apm/suspend)"
put /etc/apm/suspend <<'EOF'
#!/bin/sh
# /etc/apm/suspend: o apmd executa este script, como root, logo antes de
# suspender (tampa fechada, botão "Suspender" ou bateria baixa).
# Bloqueia a tela de quem está na sessão gráfica, para o notebook voltar pedindo senha.

# Dono da sessão gráfica: o xenodm entrega /dev/console a quem entrou.
U="$(stat -f %Su /dev/console 2>/dev/null)"
[ -n "$U" ] && [ "$U" != "root" ] || exit 0
CASA="$(getent passwd "$U" | cut -d: -f6)"
ADDR="$(cat "$CASA/.cache/dbus-sessao" 2>/dev/null)"

# Tenta o protetor de tela do Xfce; se não responder, usa o xlock do sistema.
if [ -n "$ADDR" ] && su -l "$U" -c \
     "DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS='$ADDR' xfce4-screensaver-command --lock" \
     >/dev/null 2>&1; then
	sleep 1
else
	su -l "$U" -c "DISPLAY=:0 /usr/X11R6/bin/xlock -mode blank" >/dev/null 2>&1 &
	sleep 2
fi
exit 0
EOF
chmod 755 /etc/apm/suspend

msg "Toque para clicar no touchpad"
touch /etc/wsconsctl.conf
grep -q '^mouse.tp.tapping' /etc/wsconsctl.conf ||
	{ backup /etc/wsconsctl.conf; echo "mouse.tp.tapping=1" >> /etc/wsconsctl.conf; }
wsconsctl mouse.tp.tapping=1 >/dev/null 2>&1 || true

# Navegadores e o LibreOffice precisam de mais memória do que o padrão permite.
# A classe "desktop" libera metade da RAM (no mínimo 2 GB) por processo.
msg "Limites de memória (classe de login 'desktop')"
RAM_MB=$(( $(sysctl -n hw.physmem) / 1048576 ))
DATA_MB=$(( RAM_MB / 2 ))
[ "$DATA_MB" -lt 2048 ] && DATA_MB=2048
put /etc/login.conf.d/desktop <<EOF
desktop:\\
	:path=/usr/bin /bin /usr/sbin /sbin /usr/X11R6/bin /usr/local/bin /usr/local/sbin:\\
	:umask=022:\\
	:datasize-cur=${DATA_MB}M:\\
	:datasize-max=infinity:\\
	:maxproc-cur=1024:\\
	:maxproc-max=2048:\\
	:openfiles-cur=4096:\\
	:openfiles-max=8192:\\
	:stacksize-cur=8M:\\
	:ignorenologin:\\
	:requirehome@:
EOF
usermod -L desktop "$ALVO" || warn "não consegui pôr $ALVO na classe 'desktop'"
info "datasize: ${DATA_MB} MB (RAM: ${RAM_MB} MB)"

msg "noatime nas partições (menos gravações nos SSDs)"
if grep -q ' ffs rw' /etc/fstab && ! grep -q noatime /etc/fstab; then
	backup /etc/fstab
	sed -i 's/ ffs rw/ ffs rw,noatime/' /etc/fstab
	info "aplicado; vale a partir do próximo boot"
else
	info "já aplicado (ou fstab fora do padrão): nada alterado"
fi

msg "Tela de login (xenodm) sem o console, sem bipe e com fundo liso"
XSETUP=/etc/X11/xenodm/Xsetup_0
if [ -f "$XSETUP" ]; then
	backup "$XSETUP"
	sed -i '/^[^#]*xconsole /s/^/#/' "$XSETUP"
	grep -q 'xsetroot -solid' "$XSETUP" ||
		echo "/usr/X11R6/bin/xsetroot -solid '$LOGIN_BG'" >> "$XSETUP"
	grep -q 'xset b off' "$XSETUP" ||
		echo "/usr/X11R6/bin/xset b off" >> "$XSETUP"
else
	warn "$XSETUP não existe; os conjuntos do X (xbase, xserv, xfont, xshare) foram instalados?"
fi

# ------------------------------------------------------------------------------
# 4. Usuário: sessão, aparência e painel
# ------------------------------------------------------------------------------
msg "Sessão gráfica de $ALVO (teclado: $XKB_LAYOUT $XKB_VARIANT)"
TP_LINHAS="# rolagem pelo TrackPoint desativada"
if [ "$TRACKPOINT_SCROLL" = "sim" ]; then
	TP_LINHAS='# TrackPoint: segurar o botão do meio e mover rola a página.
xinput set-prop "/dev/wsmouse" "WS Pointer Wheel Emulation" 1 2>/dev/null
xinput set-prop "/dev/wsmouse" "WS Pointer Wheel Emulation Button" 2 2>/dev/null
xinput set-prop "/dev/wsmouse" "WS Pointer Wheel Emulation Axes" 6 7 4 5 2>/dev/null'
fi
put "$CASA/.xsession" <<EOF
#!/bin/sh
# Sessão do Xfce iniciada pelo xenodm.
export LANG=$IDIOMA
export LC_CTYPE=$IDIOMA
export ENV=\$HOME/.kshrc
[ -f "\$HOME/.Xresources" ] && xrdb -merge "\$HOME/.Xresources"
setxkbmap -layout "$XKB_LAYOUT" -variant "$XKB_VARIANT"
$TP_LINHAS
exec /usr/local/bin/startxfce4 --with-ck-launch
EOF
chmod 755 "$CASA/.xsession"

# Terminal: histórico, prompt colorido e autocompletar do ksh.
msg "Terminal (ksh): histórico, prompt e autocompletar"
put "$CASA/.kshrc" <<'EOF'
# ~/.kshrc: lido pelo ksh em toda sessão interativa.
set -o emacs
HISTFILE=$HOME/.ksh_history
HISTSIZE=20000
HISTCONTROL=ignoredups:ignorespace
PS1='\[\e[1;32m\]\u@\h\[\e[0m\]:\[\e[1;34m\]\w\[\e[0m\]\$ '

alias ll='ls -lhF'
alias la='ls -lAhF'

# Autocompletar com Tab: além de comandos e arquivos, estes argumentos.
set -A complete_rcctl_1 -- check disable enable get ls order reload restart set start stop
set -A complete_rcctl_2 -- $(rcctl ls all 2>/dev/null)
set -A complete_pkg_delete -- $(ls /var/db/pkg 2>/dev/null)
set -A complete_pkg_info -- $(ls /var/db/pkg 2>/dev/null)
set -A complete_kill_1 -- -9 -HUP -INFO -KILL -TERM
set -A complete_ifconfig_1 -- $(ifconfig 2>/dev/null | sed -n 's/^\([a-z0-9]*\):.*/\1/p')
set -A complete_ssh -- $(awk '{split($1,h,","); print h[1]}' ~/.ssh/known_hosts 2>/dev/null)
set -A complete_scp -- $(awk '{split($1,h,","); print h[1]}' ~/.ssh/known_hosts 2>/dev/null)
set -A complete_git_1 -- add branch checkout clone commit diff fetch log merge pull push rebase reset restore show stash status switch tag
set -A complete_gh_1 -- api auth browse issue pr release repo run workflow
set -A complete_doas_1 -- fw_update halt mount pkg_add pkg_delete rcctl reboot sh syspatch sysupgrade umount vi
set -A complete_man -- $(ls /usr/share/man/man1 /usr/share/man/man8 2>/dev/null | sed 's/\.[0-9].*//' | sort -u)
EOF
touch "$CASA/.profile"
grep -q 'ENV=' "$CASA/.profile" ||
	{ backup "$CASA/.profile"; echo 'export ENV=$HOME/.kshrc' >> "$CASA/.profile"; }
chown "$ALVO:$GRUPO" "$CASA/.kshrc" "$CASA/.profile"

CFG="$CASA/.config"
XML="$CFG/xfce4/xfconf/xfce-perchannel-xml"

if [ "$LAYOUT" = "gnome" ]; then
	DECOR="menu:close";  BOTOES="O|C";    MENU_SUPER="xfce4-popup-whiskermenu"
else
	DECOR="menu:minimize,maximize,close"; BOTOES="O|HMC"; MENU_SUPER="xfce4-popup-applicationsmenu"
fi

msg "Aparência: $GTK_THEME, ícones $ICON_THEME, fonte $UI_FONT (layout: $LAYOUT)"
put "$XML/xsettings.xml" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xsettings" version="1.0">
  <property name="Net" type="empty">
    <property name="ThemeName" type="string" value="$GTK_THEME"/>
    <property name="IconThemeName" type="string" value="$ICON_THEME"/>
    <property name="EnableEventSounds" type="bool" value="false"/>
  </property>
  <property name="Gtk" type="empty">
    <property name="FontName" type="string" value="$UI_FONT"/>
    <property name="MonospaceFontName" type="string" value="$MONO_FONT"/>
    <property name="CursorThemeName" type="string" value="Adwaita"/>
    <property name="DecorationLayout" type="string" value="$DECOR"/>
  </property>
  <property name="Xft" type="empty">
    <property name="Antialias" type="int" value="1"/>
    <property name="Hinting" type="int" value="1"/>
    <property name="HintStyle" type="string" value="hintslight"/>
    <property name="RGBA" type="string" value="rgb"/>
  </property>
</channel>
EOF

# Janelas: tema, fonte do título, composição ligada e encaixe nas bordas e nos
# cantos ao arrastar (para isso, arrastar não troca de área de trabalho).
put "$XML/xfwm4.xml" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfwm4" version="1.0">
  <property name="general" type="empty">
    <property name="theme" type="string" value="$GTK_THEME"/>
    <property name="title_font" type="string" value="${UI_FONT% *} Bold ${UI_FONT##* }"/>
    <property name="title_alignment" type="string" value="center"/>
    <property name="button_layout" type="string" value="$BOTOES"/>
    <property name="use_compositing" type="bool" value="true"/>
    <property name="workspace_count" type="int" value="4"/>
    <property name="snap_to_border" type="bool" value="true"/>
    <property name="tile_on_move" type="bool" value="true"/>
    <property name="wrap_windows" type="bool" value="false"/>
  </property>
</channel>
EOF

# Teclado: o Xfce mantém o mesmo layout definido no .xsession.
put "$XML/keyboard-layout.xml" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<channel name="keyboard-layout" version="1.0">
  <property name="Default" type="empty">
    <property name="XkbDisable" type="bool" value="false"/>
    <property name="XkbLayout" type="string" value="$XKB_LAYOUT"/>
    <property name="XkbVariant" type="string" value="$XKB_VARIANT"/>
  </property>
</channel>
EOF

# Energia: na bateria, escurece a tela em 2 min e a desliga em 6; bloqueia ao suspender.
put "$XML/xfce4-power-manager.xml" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfce4-power-manager" version="1.0">
  <property name="xfce4-power-manager" type="empty">
    <property name="show-tray-icon" type="bool" value="true"/>
    <property name="dpms-enabled" type="bool" value="true"/>
    <property name="brightness-on-battery" type="uint" value="120"/>
    <property name="brightness-level-on-battery" type="uint" value="30"/>
    <property name="dpms-on-battery-sleep" type="uint" value="5"/>
    <property name="dpms-on-battery-off" type="uint" value="6"/>
    <property name="dpms-on-ac-sleep" type="uint" value="15"/>
    <property name="dpms-on-ac-off" type="uint" value="20"/>
    <property name="lock-screen-suspend-hibernate" type="bool" value="true"/>
  </property>
</channel>
EOF

# Terminal do Xfce: abre o fish; o shell de login (console, SSH e root) segue em ksh.
if [ -n "$TERMINAL_SHELL" ]; then
	put "$XML/xfce4-terminal.xml" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfce4-terminal" version="1.0">
  <property name="run-custom-command" type="bool" value="true"/>
  <property name="custom-command" type="string" value="$TERMINAL_SHELL"/>
</channel>
EOF
fi

# Janela de saída sem "Hibernar" nem "Suspensão híbrida": a hibernação exige um
# swap maior que a RAM, o que o particionamento automático não entrega.
# LockScreen bloqueia a tela quando se suspende pelo botão do menu de saída.
# LaunchGNOME inicia o gnome-keyring com a sessão: sem ele, o Evolution falha
# com "org.freedesktop.secrets was not provided".
put "$XML/xfce4-session.xml" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfce4-session" version="1.0">
  <property name="shutdown" type="empty">
    <property name="LockScreen" type="bool" value="true"/>
    <property name="ShowHibernate" type="bool" value="false"/>
    <property name="ShowHybridSleep" type="bool" value="false"/>
  </property>
  <property name="compat" type="empty">
    <property name="LaunchGNOME" type="bool" value="true"/>
  </property>
</channel>
EOF

# Só no LAYOUT="gnome": sem ícones na área de trabalho, barra superior e dock.
# No LAYOUT="xfce", o painel e a área de trabalho ficam no padrão do Xfce.
if [ "$LAYOUT" = "gnome" ]; then
# Área de trabalho sem ícones, como no GNOME.
put "$XML/xfce4-desktop.xml" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfce4-desktop" version="1.0">
  <property name="desktop-icons" type="empty">
    <property name="style" type="int" value="0"/>
  </property>
</channel>
EOF

# Painel 1: barra superior (menu "Atividades", relógio no centro, indicadores).
# Painel 2: dock inferior, que se esconde quando uma janela encosta nele.
msg "Painel: barra superior e dock"
put "$XML/xfce4-panel.xml" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfce4-panel" version="1.0">
  <property name="configver" type="int" value="2"/>
  <property name="panels" type="array">
    <value type="int" value="1"/>
    <value type="int" value="2"/>
    <property name="dark-mode" type="bool" value="true"/>
    <property name="panel-1" type="empty">
      <property name="position" type="string" value="p=6;x=0;y=0"/>
      <property name="length" type="uint" value="100"/>
      <property name="position-locked" type="bool" value="true"/>
      <property name="size" type="uint" value="28"/>
      <property name="icon-size" type="uint" value="16"/>
      <property name="plugin-ids" type="array">
        <value type="int" value="1"/>
        <value type="int" value="2"/>
        <value type="int" value="3"/>
        <value type="int" value="4"/>
        <value type="int" value="5"/>
        <value type="int" value="6"/>
        <value type="int" value="7"/>
        <value type="int" value="8"/>
        <value type="int" value="9"/>
      </property>
    </property>
    <property name="panel-2" type="empty">
      <property name="position" type="string" value="p=10;x=0;y=0"/>
      <property name="length" type="uint" value="1"/>
      <property name="length-adjust" type="bool" value="true"/>
      <property name="position-locked" type="bool" value="true"/>
      <property name="size" type="uint" value="48"/>
      <property name="autohide-behavior" type="uint" value="1"/>
      <property name="plugin-ids" type="array">
        <value type="int" value="10"/>
      </property>
    </property>
  </property>
  <property name="plugins" type="empty">
    <property name="plugin-1" type="string" value="whiskermenu">
      <property name="button-title" type="string" value="Atividades"/>
      <property name="show-button-title" type="bool" value="true"/>
      <property name="show-button-icon" type="bool" value="false"/>
    </property>
    <property name="plugin-2" type="string" value="separator">
      <property name="expand" type="bool" value="true"/>
      <property name="style" type="uint" value="0"/>
    </property>
    <property name="plugin-3" type="string" value="clock">
      <property name="mode" type="uint" value="2"/>
      <property name="digital-layout" type="uint" value="3"/>
      <property name="digital-time-format" type="string" value="%a, %d de %b  %H:%M"/>
      <property name="digital-time-font" type="string" value="${UI_FONT% *} Bold ${UI_FONT##* }"/>
    </property>
    <property name="plugin-4" type="string" value="separator">
      <property name="expand" type="bool" value="true"/>
      <property name="style" type="uint" value="0"/>
    </property>
    <property name="plugin-5" type="string" value="systray">
      <property name="square-icons" type="bool" value="true"/>
    </property>
    <property name="plugin-6" type="string" value="notification-plugin"/>
    <property name="plugin-7" type="string" value="pulseaudio"/>
    <property name="plugin-8" type="string" value="power-manager-plugin"/>
    <property name="plugin-9" type="string" value="actions">
      <property name="appearance" type="uint" value="0"/>
    </property>
    <property name="plugin-10" type="string" value="docklike"/>
  </property>
</channel>
EOF
fi

# Programas GTK 3 e GTK 4 em modo escuro.
for v in 3.0 4.0; do
	put "$CFG/gtk-$v/settings.ini" <<EOF
[Settings]
gtk-application-prefer-dark-theme=1
EOF
done

# ------------------------------------------------------------------------------
# 5. Usuário: aplicativos web e primeiro login
# ------------------------------------------------------------------------------
msg "Atalhos de aplicativos web (janela própria no $WEBAPP_BROWSER; Teams e Zoom no Firefox)"
APPS="$CASA/.local/share/applications"
printf '%s\n' "$WEBAPPS" | sed '/^$/d' | while IFS='|' read -r id nome url icone cats nav; do
	if [ "$nav" = "firefox" ]; then cmd="firefox --new-window $url"
	else cmd="$WEBAPP_BROWSER --app=$url"; fi
	case "$icone" in
	site:*)
		mkdir -p "$CASA/.local/share/icons"
		arq="$CASA/.local/share/icons/webapp-$id.png"
		if [ -s "$arq" ] || ftp -V -o "$arq" \
		    "https://www.google.com/s2/favicons?sz=128&domain=${icone#site:}" 2>/dev/null; then
			icone="$arq"
		else
			rm -f "$arq"; icone="applications-internet"
		fi ;;
	esac
	put "$APPS/webapp-$id.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=$nome
Comment=$nome (aplicativo web)
Exec=$cmd
Icon=$icone
Categories=$cats
StartupWMClass=$id
EOF
	info "$nome"
done

# No primeiro login: cria as pastas pessoais e grava os atalhos de teclado.
put "$CASA/.local/bin/primeiro-login.sh" <<EOF
#!/bin/sh
xdg-user-dirs-update
atalho() { xfconf-query -c xfce4-keyboard-shortcuts -p "\$1" -n -t string -s "\$2"; }
# Super+Espaço abre o menu. (Super sozinha atrapalharia as combinações abaixo.)
atalho "/commands/custom/<Super>space" "$MENU_SUPER"
# Super+setas encaixam a janela: metades, maximizar e minimizar.
# Cada ação aceita um atalho só, então os padrões das mesmas ações saem antes
# (os do teclado numérico, que o X230 não tem, e Alt+F9 e Alt+F10).
for antigo in "<Super>KP_Left" "<Super>KP_Right" "<Alt>F9" "<Alt>F10"; do
	xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/\$antigo" -r 2>/dev/null
done
atalho "/xfwm4/custom/<Super>Left"  tile_left_key
atalho "/xfwm4/custom/<Super>Right" tile_right_key
atalho "/xfwm4/custom/<Super>Up"    maximize_window_key
atalho "/xfwm4/custom/<Super>Down"  hide_window_key
xfwm4 --replace >/dev/null 2>&1 &
rm -f "\$HOME/.config/autostart/primeiro-login.desktop"
EOF
chmod 755 "$CASA/.local/bin/primeiro-login.sh"
# A cada login, anota o endereço do barramento da sessão, para o
# /etc/apm/suspend (que roda como root) conseguir pedir o bloqueio da tela.
put "$CFG/autostart/dbus-sessao.desktop" <<'EOF'
[Desktop Entry]
Type=Application
Name=Endereco da sessao (para bloquear ao suspender)
Exec=sh -c "umask 077; echo \"$DBUS_SESSION_BUS_ADDRESS\" > $HOME/.cache/dbus-sessao"
EOF
put "$CFG/autostart/primeiro-login.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=Ajustes do primeiro login
Exec=$CASA/.local/bin/primeiro-login.sh
EOF

chown -R "$ALVO:$GRUPO" "$CASA/.xsession" "$CFG" "$CASA/.local"
[ -e "$CASA/.xsession.orig" ] && chown "$ALVO:$GRUPO" "$CASA/.xsession.orig"

# ------------------------------------------------------------------------------
# Resumo
# ------------------------------------------------------------------------------
msg "Concluído"
if [ -s "$TMP_FALTANDO" ]; then
	echo "    Pacotes não instalados (rode 'doas pkg_add nome' para ver o motivo):"
	sed 's/^/      - /' "$TMP_FALTANDO"
fi
[ -n "$AVISOS" ] && printf '    Avisos:%s\n' "$AVISOS"
cat <<EOF

    Próximos passos:
      1. Reinicie: doas reboot. A tela de login gráfica (xenodm) abre sozinha.
      2. OneDrive: rclone config (escolha "Microsoft OneDrive").
      3. Pendrive no painel: veja o nome dele com 'dmesg | tail' (por exemplo sd3)
         e registre-o no /etc/fstab:
           /dev/sd3i $CASA/usb msdos rw,noauto,nodev,nosuid 0 0
         Depois: clique direito no painel > Painel > Adicionar novos itens >
         "Montar dispositivos". Nas propriedades, exclua os discos internos e,
         em Comandos, use:  doas mount %m  e  doas umount %m
         Feche a janela do Thunar na pasta antes de desmontar.
      4. Token ePass2003 no Firefox: Configurações > Privacidade e Segurança >
         Dispositivos de segurança > Carregar:
         /usr/local/lib/pkcs11/opensc-pkcs11.so

EOF
