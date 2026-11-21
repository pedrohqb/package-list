#!/bin/sh
# Revisão da instalação feita pelo openbsd-x230.sh. Só confere; não altera nada.
# Uso (com o seu usuário, sem doas):  sh revisao-openbsd.sh
PKGS="xfce xfce-extras xfce4-docklike greybird papirus-icon-theme cantarell-fonts jetbrains-mono noto-fonts noto-emoji liberation-fonts gvfs gvfs-smb xdg-user-dirs xarchiver unzip 7zip papers mpv cups cups-filters system-config-printer xfce4-mount xfce4-power-manager upower ntfs_3g exfat-fuse galculator gucharmap baobab deja-dup simple-scan gnome-font-viewer git github-cli node codex rclone wireguard-tools yt-dlp ocrmypdf pdfgrep qpdf tesseract tesseract-por GraphicsMagick fdupes ripgrep sysbench fastfetch nano fish audacity kdenlive obs-studio evolution evolution-ews tdesktop meld libreoffice libreoffice-i18n-pt-br pdfarranger qownnotes sword cdrtools dvd+rw-tools gimp pinta shotwell chromium firefox firefox-i18n-pt-BR remmina qbittorrent gradio spotify-qt keepassxc opensc ccid pcsc-lite qemu "
ok=0; falta=0
bom()  { ok=$((ok+1)); }
ruim() { falta=$((falta+1)); printf '  FALTA: %s\n' "$*"; }

echo "== Pacotes"
for p in $PKGS; do
	if pkg_info -e "$p-*" >/dev/null 2>&1; then bom; else ruim "pacote $p"; fi
done

echo "== Serviços ativados no boot"
for s in messagebus xenodm apmd cupsd pcscd; do
	if rcctl ls on 2>/dev/null | grep -qx "$s"; then bom; else ruim "serviço $s"; fi
done

echo "== Ajustes do sistema (sysctl)"
for par in machdep.lidaction=1 kern.audio.record=1 kern.video.record=1 \
           kern.bufcachepercent=40 hw.blockcpu=L; do
	atual="$(sysctl -n "${par%%=*}" 2>/dev/null)"
	if [ "$atual" = "${par#*=}" ]; then bom
	else ruim "sysctl ${par%%=*} está em '$atual' (esperado ${par#*=})"; fi
	grep -qxF "$par" /etc/sysctl.conf 2>/dev/null || ruim "linha '$par' em /etc/sysctl.conf"
done

echo "== Arquivos de configuração"
X="$HOME/.config/xfce4/xfconf/xfce-perchannel-xml"
for f in "$HOME/.xsession" "$X/xsettings.xml" "$X/xfwm4.xml" "$X/keyboard-layout.xml" \
         "$X/xfce4-power-manager.xml" "$X/xfce4-terminal.xml" "$HOME/.kshrc" \
         /etc/login.conf.d/desktop /etc/hostname.iwm0 /etc/X11/xenodm/Xsetup_0; do
	if [ -e "$f" ]; then bom; else ruim "arquivo $f"; fi
done
for a in chatgpt claude discord teams whatsapp zoom; do
	f="$HOME/.local/share/applications/webapp-$a.desktop"
	if [ -e "$f" ]; then bom; else ruim "atalho web $a"; fi
done

echo "== Usuário e sessão"
if id -Gn | tr ' ' '\n' | grep -qx _shutdown; then bom; else ruim "grupo _shutdown (desligar pelo menu)"; fi
if [ "$(userinfo "$(id -un)" 2>/dev/null | awk '$1=="class"{print $2}')" = "desktop" ]; then bom
else ruim "classe de login 'desktop' (limite de memória)"; fi
if grep -q noatime /etc/fstab; then bom; else ruim "noatime em /etc/fstab"; fi
if grep -q '/dev/video0' /etc/X11/xenodm/GiveConsole 2>/dev/null; then bom; else ruim "webcam para o usuário (GiveConsole)"; fi
if grep -q 'setxkbmap' "$HOME/.xsession" 2>/dev/null; then bom; else ruim "teclado internacional em ~/.xsession"; fi
if grep -q 'Wheel Emulation' "$HOME/.xsession" 2>/dev/null; then bom; else ruim "rolagem do TrackPoint em ~/.xsession"; fi
n="$(sysctl -n hw.ncpuonline 2>/dev/null)"
if [ "$n" = "4" ]; then bom; else ruim "threads ativos: $n (esperado 4)"; fi
if ifconfig egress 2>/dev/null | grep -q 'inet '; then bom; else ruim "rede sem endereço"; fi

echo
echo "Resultado: $ok itens certos, $falta faltando."
