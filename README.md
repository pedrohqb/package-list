# package-list

Listas dos pacotes instalados nos meus sistemas, para reinstalar tudo rapidamente depois de uma instalação limpa. Cada sistema tem sua própria pasta.

| Pasta | Sistema | Conteúdo |
|---|---|---|
| [`cachyos/`](cachyos/) | CachyOS (KDE Plasma + Limine + Btrfs) | pacman, AUR e Flatpak |

Os comandos funcionam tanto no **fish** quanto no **bash**, salvo onde indicado.

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

## Licença

[CC0 1.0 Universal](LICENSE): domínio público. Use à vontade.
