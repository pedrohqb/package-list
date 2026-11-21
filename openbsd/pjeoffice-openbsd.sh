#!/bin/sh
################################################################################
# PJeOffice Pro no OpenBSD (experimental)                                      #
#                                                                              #
# Baixa o .zip oficial do CNJ para Linux, descarta o Java embutido e o ffmpeg  #
# (que são para Linux) e roda o pjeoffice-pro.jar, sem alteração, no JDK 11 e  #
# com o ffmpeg do OpenBSD.                                                     #
#                                                                              #
# USO, com o usuário comum:  sh pjeoffice-openbsd.sh                           #
# Instala em ~/.local/share/pjeoffice-pro e cria um atalho no menu.            #
################################################################################
set -eu

VERSAO="2.5.16u"
URL="https://pje-office.pje.jus.br/pro/pjeoffice-pro-v${VERSAO}-linux_x64.zip"
SHA256="6087391759c7cba11fb5ef815fe8be91713b46a8607c12eb664a9d9a6882c4c7"
DESTINO="$HOME/.local/share/pjeoffice-pro"
JAVA="/usr/local/jdk-11/bin/java"

[ "$(uname -s)" = "OpenBSD" ] || { echo "Este script é para OpenBSD." >&2; exit 1; }
[ "$(id -u)" -ne 0 ] || { echo "Rode com o usuário comum, não como root." >&2; exit 1; }

if [ ! -x "$JAVA" ]; then
	echo "==> Instalando o JDK 11 (pede a senha do doas)"
	doas pkg_add 'jdk%11'
fi
[ -x "$JAVA" ] || { echo "Não achei $JAVA. Veja onde o JDK ficou: ls -d /usr/local/jdk-*" >&2; exit 1; }

FFMPEG="/usr/local/bin/ffmpeg"
if [ ! -x "$FFMPEG" ]; then
	echo "==> Instalando o ffmpeg (para as funções de vídeo)"
	doas pkg_add ffmpeg || echo "    AVISO: sem o ffmpeg, as funções de vídeo não vão funcionar."
fi

TMP="$(mktemp -d /tmp/pjeoffice.XXXXXX)"
trap 'rm -rf "$TMP"' EXIT

echo "==> Baixando o PJeOffice Pro $VERSAO do CNJ"
ftp -V -o "$TMP/pjeoffice.zip" "$URL"

echo "==> Conferindo o arquivo"
OBTIDO="$(sha256 -q "$TMP/pjeoffice.zip")"
if [ "$OBTIDO" != "$SHA256" ]; then
	echo "Soma SHA256 diferente da esperada. O CNJ pode ter publicado outra versão." >&2
	echo "  esperada: $SHA256" >&2
	echo "  obtida:   $OBTIDO" >&2
	exit 1
fi

echo "==> Instalando em $DESTINO"
unzip -q "$TMP/pjeoffice.zip" -d "$TMP/x"
ORIGEM="$(dirname "$(find "$TMP/x" -name pjeoffice-pro.jar | head -1)")"
[ -f "$ORIGEM/pjeoffice-pro.jar" ] || { echo "pjeoffice-pro.jar não veio no .zip." >&2; exit 1; }
rm -rf "$ORIGEM/jre"                      # Java embutido, só serve em Linux
rm -rf "$DESTINO"
mkdir -p "$(dirname "$DESTINO")"
mv "$ORIGEM" "$DESTINO"

# No Xfce, o PJeOffice recolhe a janela para a bandeja ao fechar ou minimizar,
# e o menu da bandeja sai em branco. No GNOME e no KDE isso não acontece, porque
# o Java não enxerga bandeja. Para ter o mesmo efeito aqui, o Java do PJeOffice
# (e só ele) recebe um substituto de java.awt.SystemTray que responde "não há
# bandeja". O .jar do CNJ não é alterado.
echo "==> Desativando a bandeja para o PJeOffice"
SEMB="$DESTINO/sem-bandeja"
mkdir -p "$SEMB/src/java/awt" "$SEMB/classes"
cat > "$SEMB/src/java/awt/SystemTray.java" <<'FIM'
package java.awt;

import java.beans.PropertyChangeListener;

/** Substituto de java.awt.SystemTray que declara que não há bandeja. */
public class SystemTray {
    private SystemTray() {}
    public static SystemTray getSystemTray() {
        throw new UnsupportedOperationException("Bandeja desativada.");
    }
    public static boolean isSupported() { return false; }
    static void checkSystemTrayAllowed() {}
    public void add(TrayIcon trayIcon) throws AWTException {
        throw new AWTException("Bandeja desativada.");
    }
    public void remove(TrayIcon trayIcon) {}
    public TrayIcon[] getTrayIcons() { return new TrayIcon[0]; }
    public Dimension getTrayIconSize() { return new Dimension(16, 16); }
    public synchronized void addPropertyChangeListener(String n, PropertyChangeListener l) {}
    public synchronized void removePropertyChangeListener(String n, PropertyChangeListener l) {}
    public synchronized PropertyChangeListener[] getPropertyChangeListeners(String n) {
        return new PropertyChangeListener[0];
    }
}
FIM
PATCH=""
if "${JAVA}c" --patch-module java.desktop="$SEMB/src" -d "$SEMB/classes" \
     "$SEMB/src/java/awt/SystemTray.java" 2>"$SEMB/javac.log" &&
   [ -f "$SEMB/classes/java/awt/SystemTray.class" ]; then
	PATCH="--patch-module java.desktop=$SEMB/classes"
else
	echo "    AVISO: não consegui compilar o substituto (veja $SEMB/javac.log)."
	echo "    O PJeOffice vai funcionar, mas recolhendo para a bandeja."
fi

# O .zip traz um ffmpeg de Linux com o nome ffmpeg.exe. O PJeOffice o procura
# por esse nome na pasta do programa, então ele vira um atalho para o do OpenBSD.
if [ -x "$FFMPEG" ] && [ -e "$DESTINO/ffmpeg.exe" ]; then
	echo "==> Trocando o ffmpeg de Linux pelo do OpenBSD"
	rm -f "$DESTINO/ffmpeg.exe"
	ln -s "$FFMPEG" "$DESTINO/ffmpeg.exe"
fi

# O corte por trechos abre um player à parte (cutplayer4jfx.jar), que o PJeOffice
# inicia pelo caminho fixo jre/bin/java e que precisa do JavaFX. O OpenBSD 8.0
# não tem o pacote openjfx, então este substituto de jre/bin/java avisa que a
# função não está disponível; se o openjfx e o JDK 21 existirem, tenta usá-los.
mkdir -p "$DESTINO/jre/bin"
cat > "$DESTINO/jre/bin/java" <<'FIM'
#!/bin/sh
FX=/usr/local/share/java/classes/21
JAVA21=/usr/local/jdk-21/bin/java
# Só os .jar "-openbsd" entram: os de mesmo nome sem o sufixo são marcadores vazios.
MP="$(ls "$FX"/javafx-*-openbsd.jar 2>/dev/null | tr '\n' ':')"
if [ -n "$MP" ] && [ -x "$JAVA21" ]; then
	exec "$JAVA21" --module-path "${MP%:}" \
		--add-modules javafx.base,javafx.graphics,javafx.controls,javafx.swing,javafx.media \
		"$@"
fi
MSG="O corte por trechos usa um player que precisa do JavaFX, e o OpenBSD 8.0
não tem o pacote openjfx.

Alternativas:
 - no PJeOffice: Dividir a cada 'n' minutos ou a cada 'n' MB;
 - no terminal:  ffmpeg -i video.mp4 -ss 00:01:30 -to 00:04:00 -c copy trecho.mp4"
if [ -x /usr/X11R6/bin/xmessage ]; then
	/usr/X11R6/bin/xmessage -center -title "PJeOffice Pro" "$MSG"
else
	echo "$MSG" >&2
fi
exit 1
FIM
chmod 755 "$DESTINO/jre/bin/java"

cat > "$DESTINO/pjeoffice-pro.sh" <<FIM
#!/bin/sh
# Inicia o PJeOffice Pro com o JDK 11 do OpenBSD.
# --patch-module troca a classe da bandeja pelo substituto em sem-bandeja/, e
# pjeoffice_desktop pede a janela ("Modo desktop"), como no GNOME e no KDE.
exec $JAVA $PATCH \\
  -XX:+UseG1GC -XX:MinHeapFreeRatio=3 -XX:MaxHeapFreeRatio=3 \\
  -Xms20m -Xmx2048m \\
  -Dpjeoffice_home="$DESTINO/" \\
  -Dffmpeg_home="$DESTINO/" \\
  -Dpjeoffice_desktop=true \\
  -Dpjeoffice_looksandfeels="Metal" \\
  -Dcutplayer4j_looksandfeels="Nimbus" \\
  -jar "$DESTINO/pjeoffice-pro.jar"
FIM
chmod 755 "$DESTINO/pjeoffice-pro.sh"

mkdir -p "$HOME/.local/share/icons" "$HOME/.local/share/applications"
unzip -p "$DESTINO/pjeoffice-pro.jar" 'images/pje-icon-pje-feather.png' \
	> "$HOME/.local/share/icons/pjeoffice.png" 2>/dev/null || true
cat > "$HOME/.local/share/applications/pjeoffice-pro.desktop" <<FIM
[Desktop Entry]
Type=Application
Name=PJeOffice Pro
Comment=Assinador digital do CNJ para o PJe
Exec=$DESTINO/pjeoffice-pro.sh
Icon=$HOME/.local/share/icons/pjeoffice.png
Categories=Office;
FIM

echo
echo "Pronto. Para ver as mensagens no primeiro teste, rode pelo terminal:"
echo "  $DESTINO/pjeoffice-pro.sh"
echo
echo "A janela não recolhe mais para a bandeja: minimizar a deixa na barra de"
echo "tarefas, e o menu do programa abre com o botão direito sobre a janela."
