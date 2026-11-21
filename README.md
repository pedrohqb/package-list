# package-list

Listas dos pacotes instalados nos meus sistemas, para reinstalar tudo rapidamente depois de uma instalação limpa. Cada sistema tem sua própria pasta.

| Pasta | Sistema | Conteúdo |
|---|---|---|
| [`cachyos/`](cachyos/) | CachyOS (KDE Plasma + Limine + Btrfs) | pacman, AUR e Flatpak |
| [`openbsd/`](openbsd/) | OpenBSD 8.0 (Xfce) no ThinkPad X230 | scripts de pós-instalação, de revisão e do PJeOffice Pro |

Na seção do CachyOS, os comandos funcionam tanto no **fish** quanto no **bash**, salvo onde indicado.

---

## CachyOS (KDE Plasma + Limine + Btrfs)

### Arquivos

| Arquivo | O que contém | Comando que gerou |
|---|---|---|
| `pacman.txt` | Pacotes instalados explicitamente a partir de repositórios (Arch, CachyOS **e Chaotic-AUR**), sem drivers | `pacman -Qqen \| grep -vxEf exclude.txt` |
| `exclude.txt` | Padrões (regex) que ficam fora do `pacman.txt`: o microcódigo, a base que o instalador do CachyOS sempre instala e todos os pacotes que o `chwd` instala conforme o hardware | — |
| `aur.txt` | Pacotes fora de qualquer repositório configurado (AUR compilado localmente) | `pacman -Qqem` |
| `flatpak.txt` | Aplicativos Flatpak (sem runtimes) e as extensões de driver do Tessera | ver [Atualizar as listas](#atualizar-as-listas) |

> **Atenção:** vários pacotes do `pacman.txt` vêm do **Chaotic-AUR** (por exemplo `brave-origin-bin`, `claude-desktop`, `chatgpt-desktop-bin`, `pje-office`, `serproid`, `safesignidentityclient`, `sac-core`, `softplan-websigner`, `lacuna-webpki`, `spotify`, `zoom`, `onlyoffice-bin`, `ventoy-bin`). Como o pacman os enxerga como pacotes de repositório, eles aparecem no `pacman.txt`, e não no `aur.txt`. Por isso o Chaotic-AUR precisa ser configurado **antes** da restauração (passo 2).

### Restauração

#### 1. Instalar o CachyOS e clonar este repositório

Instale o CachyOS com KDE Plasma, bootloader Limine e sistema de arquivos Btrfs (os padrões do instalador) e, depois do primeiro boot:

```sh
sudo pacman -Syu git
git clone https://github.com/pedrohqb/package-list.git
cd package-list/cachyos
```

#### 2. Configurar o Chaotic-AUR

Siga as instruções oficiais de instalação do Chaotic-AUR: <https://aur.chaotic.cx/docs>.

#### 3. Instalar os pacotes dos repositórios

```sh
sudo pacman -S --needed - < pacman.txt
```

O `--needed` pula o que já veio com a instalação (os grupos de pacotes marcados por padrão no instalador, por exemplo).

Se algum pacote tiver saído dos repositórios desde o backup, o pacman aborta tudo com `target not found`. Nesse caso, veja quais faltam e instale só os disponíveis:

```fish
# fish
comm -23 (sort pacman.txt | psub) (pacman -Slq | sort -u | psub)              # mostra os que faltam
sudo pacman -S --needed (comm -12 (sort pacman.txt | psub) (pacman -Slq | sort -u | psub))
```

```bash
# bash
comm -23 <(sort pacman.txt) <(pacman -Slq | sort -u)                          # mostra os que faltam
sudo pacman -S --needed $(comm -12 <(sort pacman.txt) <(pacman -Slq | sort -u))
```

#### 4. Instalar os pacotes do AUR

Só é necessário se o `aur.txt` não estiver vazio. O `yay` vem do `pacman.txt` (passo 3), então já estará instalado.

```sh
yay -S --needed - < aur.txt
```

#### 5. Instalar os Flatpaks

A lista mistura aplicativos do Flathub e do [FlatPark](https://flatpark.org/) (por exemplo, Tessera e PDFsam Basic), além das extensões de driver do Tessera (`io.github.pedrohqb.Tessera.Driver.*`), que o Flatpak trata como runtimes e por isso precisam estar na lista à parte dos apps. Adicione os dois remotes e instale sem indicar o remote: o Flatpak procura cada aplicativo nos remotes configurados.

```sh
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak remote-add --if-not-exists flatpark https://dl.flatpark.org/flatpark.flatpakrepo
xargs -a flatpak.txt flatpak install -y
```

### Observações

- **Drivers:** a lista não traz microcódigo nem nenhum dos pacotes dos perfis do [`chwd`](https://github.com/CachyOS/chwd/tree/master/profiles) (drivers de vídeo, Mesa, firmwares específicos, ferramentas de VM, de notebooks e portáteis, SDKs de IA), para servir em qualquer máquina. O instalador do CachyOS (via `chwd`) já instala os adequados ao hardware de cada computador. Os padrões excluídos estão em `exclude.txt`; para excluir outro pacote, acrescente uma linha ali.
- **Base, boot e sistema de arquivos:** a lista não traz a base que o [instalador](https://github.com/CachyOS/cachyos-calamares) sempre instala (`base`, kernels, keyrings e mirrorlists do CachyOS, ferramentas de sistemas de arquivos etc.) nem os pacotes que ele acrescenta conforme o bootloader e o sistema de arquivos escolhidos (Limine, GRUB, rEFInd ou systemd-boot; Btrfs com snapper, ZFS ou bcachefs). Assim a lista serve com qualquer combinação, e o instalador põe os pacotes certos para cada uma.
- **Serviços:** a lista só reinstala pacotes. Serviços (`libvirtd`, `ufw`, `bluetooth`, `cups` etc.) e configurações precisam ser habilitados/restaurados à parte.

### Atualizar as listas

Na máquina atual, dentro do clone do repositório:

```fish
# fish
cd cachyos
pacman -Qqen | grep -vxEf exclude.txt > pacman.txt
pacman -Qqem > aur.txt
begin; flatpak list --app --columns=application; flatpak list --runtime --columns=application | grep '^io.github.pedrohqb.Tessera.Driver.'; end | sort -u > flatpak.txt
cd ..
git add -A
git commit -m "CachyOS: atualiza listas de pacotes"
git push
```

```bash
# bash: igual, trocando a linha do flatpak.txt por
{ flatpak list --app --columns=application; flatpak list --runtime --columns=application | grep '^io.github.pedrohqb.Tessera.Driver.'; } | sort -u > flatpak.txt
```

O `flatpak list --app` não mostra as extensões do Tessera (para o Flatpak, são runtimes); a segunda parte do comando as acrescenta.

---

## OpenBSD 8.0 (Xfce) no ThinkPad X230

No OpenBSD não há só uma lista de pacotes: um script instala os programas e configura o sistema e a sessão. As listas ficam dentro do próprio script, por categoria e com a descrição de cada pacote, seguindo o `gnome.Brewfile` do repositório [brewfile](https://github.com/pedrohqb/brewfile) e os aplicativos que já vêm no Bluefin, com equivalentes para o que não existe no OpenBSD.

### Arquivos

| Arquivo | O que faz |
|---|---|
| `openbsd-x230.sh` | Pós-instalação: aplica correções e firmware, instala os pacotes e configura serviços, energia, desempenho, Wi-Fi, teclado, TrackPoint, tela de login, aparência do Xfce, terminal e atalhos de aplicativos web |
| `revisao-openbsd.sh` | Revisão: confere pacotes, serviços, ajustes e arquivos de configuração, sem alterar nada, e lista o que falta |
| `pjeoffice-openbsd.sh` | Instala o PJeOffice Pro do CNJ na pasta pessoal, rodando no JDK 11 do OpenBSD |

### Uso

#### 1. Instalar o OpenBSD

Grave o `install80.img` num pendrive com `dd` (o OpenBSD não inicia pelo Ventoy) e instale com o **cabo de rede ligado**, todos os conjuntos (inclusive os do X) e teclado `us`. O firmware do Wi-Fi e do vídeo é baixado no primeiro boot, por isso a rede cabeada.

#### 2. Rodar a pós-instalação

Como root (`su -`), já que o `doas` ainda não está configurado; troque `pedro` pelo seu usuário:

```sh
pkg_add git
git clone https://github.com/pedrohqb/package-list.git
sh package-list/openbsd/openbsd-x230.sh pedro
reboot
```

Antes de rodar, veja os **ajustes rápidos** no topo do script: rede Wi-Fi (`WIFI_SSID` e `WIFI_SENHA`), layout do painel (`LAYOUT`), tema, fontes, teclado, shell do terminal, Hyper-Threading e cache de disco. Depois de usar, apague a senha do Wi-Fi do arquivo e não a envie para o repositório.

O script pode ser executado mais de uma vez: pula os pacotes já instalados e guarda uma cópia `.orig` de cada arquivo de configuração antes da primeira alteração. Se a sessão do Xfce estiver aberta, saia dela antes, para o Xfce não sobrescrever o que o script grava.

#### 3. Conferir

Com o usuário comum, sem `doas`:

```sh
sh package-list/openbsd/revisao-openbsd.sh
```

#### 4. PJeOffice Pro (opcional)

Com o usuário comum; o script pede a senha do `doas` só para instalar o JDK 11:

```sh
sh package-list/openbsd/pjeoffice-openbsd.sh
```

O PJeOffice Pro é um programa Java, e o CNJ só o distribui para Linux, Windows e macOS. O script baixa o `.zip` de Linux do site do CNJ, confere a soma SHA256, descarta o Java embutido e o `ffmpeg` (que são para Linux) e roda o `pjeoffice-pro.jar`, sem alteração, no JDK 11 e com o `ffmpeg` do OpenBSD. Fica em `~/.local/share/pjeoffice-pro`, com atalho no menu.

Dois ajustes fazem a janela se comportar como no GNOME e no KDE:

- `-Dpjeoffice_desktop=true` pede o modo de janela, em vez do modo bandeja.
- `--patch-module` troca, só para o PJeOffice, a classe `java.awt.SystemTray` por um substituto que responde "não há bandeja". Sem isso, no Xfce a janela se recolhe para a bandeja ao ser fechada ou minimizada, e o menu da bandeja aparece em branco. O substituto é compilado na instalação e fica em `sem-bandeja/`.

As funções de vídeo usam um `ffmpeg` externo, que o PJeOffice procura na pasta do programa com o nome `ffmpeg.exe`. O script troca o binário de Linux por um atalho para `/usr/local/bin/ffmpeg`.

Situação no OpenBSD 8.0: o login no PJe e a assinatura funcionam com **certificado A1** (arquivo `.pfx`), e as funções de vídeo que só dependem do `ffmpeg` (dividir por tamanho e por duração e extrair áudio, testadas; converter e otimizar usam o mesmo caminho) também. O **corte por trechos não funciona**: ele abre um player que precisa do JavaFX, e o OpenBSD 8.0 não tem o pacote `openjfx`. No lugar dele, o script deixa um aviso com as alternativas, entre elas cortar pelo terminal com `ffmpeg -i video.mp4 -ss 00:01:30 -to 00:04:00 -c copy trecho.mp4`. **Token não foi testado**; o ePass2003 deve funcionar pelo OpenSC, indicando `/usr/local/lib/pkcs11/opensc-pkcs11.so` na configuração de certificado. Fechar a janela encerra o programa.

### O que o script configura

- **Sistema:** `syspatch`, `fw_update`, `doas` para o grupo `wheel`, grupo `_shutdown` (desligar pelo menu) e classe de login `desktop`, com limite de memória por processo de metade da RAM.
- **Energia e desempenho:** `apmd -A` (frequência automática e suspensão com 7% de bateria), suspensão ao fechar a tampa, escurecimento e desligamento da tela na bateria, `noatime`, cache de disco em 40% da RAM e Hyper-Threading ligado (`hw.blockcpu=L`).
- **Entrada:** teclado inglês internacional com teclas mortas (`us`, variante `intl`) na sessão gráfica, rolagem com o botão do meio do TrackPoint e toque para clicar no touchpad.
- **Janelas:** encaixe nas bordas e nos cantos ao arrastar, Super+setas para metades, maximizar e minimizar, e Super+Espaço para abrir o menu.
- **Aparência:** tema Greybird escuro, ícones Papirus, fontes Cantarell e JetBrains Mono, tela de login sem o console e sem bipe. Com `LAYOUT="gnome"`, o painel vira uma barra superior com dock.
- **Terminal:** o Terminal do Xfce abre o fish; o shell de login (console, SSH e root) continua sendo o ksh, com histórico e autocompletar no `~/.kshrc`.
- **Aplicativos web:** atalhos para ChatGPT, Claude, Discord, Teams, WhatsApp e Zoom, porque esses serviços não têm cliente para OpenBSD. Abrem no Chromium, em janela própria, menos o Teams e o Zoom, que abrem no Firefox por causa da webcam.
- **Microfone e webcam:** gravação de áudio e de vídeo liberada no sistema, e a webcam entregue ao usuário a cada login gráfico.
- **Discos externos:** `doas mount` e `doas umount` sem senha, mais o plugin de montagem do painel.

### Observações

- **Hardware:** o script foi feito e testado num ThinkPad X230 com placa Wi-Fi Intel trocada (driver `iwm`). A placa sem fio é detectada pelo sistema, não pelo nome; o que é próprio do X230 são a rolagem do TrackPoint e, no script de revisão, o nome `iwm0` e os 4 threads esperados.
- **Sem equivalente no OpenBSD 8.0:** Claude Code, ONLYOFFICE, PDFsam Basic, BibleTime, Wine, Tessera e os drivers SafeNet, SafeSign e SerproID, que dependem de Linux. O PJeOffice Pro roda pelo script próprio (passo 4). O token ePass2003 funciona pelo OpenSC: no Firefox, carregue `/usr/local/lib/pkcs11/opensc-pkcs11.so` em Dispositivos de segurança.
- **Pacotes com variantes ou mais de uma versão:** o `pkg_add` pergunta qual instalar. No script, `nome--variante` escolhe a variante (por exemplo `keepassxc--browser`) e `nome->=N` escolhe a versão (por exemplo `gimp->=3`). O script confere cada instalação com o `pkg_info` e lista no fim o que não instalou.
- **Pendrive no painel:** o plugin só lista o que está no `/etc/fstab`. Veja o nome do pendrive com `dmesg | tail` (por exemplo `sd3`, depois dos discos internos e do volume criptografado) e registre-o: `/dev/sd3i /home/pedro/usb msdos rw,noauto,nodev,nosuid 0 0`. Feche a janela do Thunar na pasta antes de desmontar.
- **Webcam:** funciona no Firefox e no comando `video`. No Chromium, a câmera é detectada, mas não chega imagem; por isso os atalhos do Teams e do Zoom usam o Firefox. No ThinkPad X230, a câmera entrega 30 quadros por segundo até 640×480 e 10 em 1280×720. O aplicativo Snapshot (Câmera do GNOME) não roda, por depender do PipeWire.
- **OneDrive:** o `onedrive-cli` não existe para OpenBSD; use `rclone config` e escolha "Microsoft OneDrive".
- **VPN WireGuard:** o WireGuard faz parte do sistema; o pacote `wireguard-tools` traz o `wg-quick`, que usa o mesmo arquivo `.conf` do Linux. Guarde-o como `/etc/wireguard/wg0.conf`, com dono `root` e permissão `600`, e use `doas wg-quick up wg0` e `doas wg-quick down wg0`; `doas wg show` mostra se o túnel subiu.
- **Pastas de rede (Samba):** com o `gvfs-smb`, o Thunar abre `smb://servidor/pasta` (Ctrl+L para digitar o endereço). Pela VPN, use o endereço IP do servidor. Se o endereço ficar vermelho logo após instalar o pacote, saia e entre na sessão.

---

## Licença

[CC0 1.0 Universal](LICENSE): domínio público. Use à vontade.
