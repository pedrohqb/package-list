# package-list

Listas dos pacotes instalados nas minhas distros, para reinstalar tudo rapidamente depois de uma instalação limpa. Cada distro tem sua própria pasta.

| Pasta | Distro | Conteúdo |
|---|---|---|
| [`cachyos/`](cachyos/) | CachyOS (KDE Plasma) | pacman, AUR e Flatpak |

Os comandos abaixo funcionam tanto no **fish** quanto no **bash**, salvo onde indicado.

---

## CachyOS

### Arquivos

| Arquivo | O que contém | Comando que gerou |
|---|---|---|
| `pacman.txt` | Pacotes instalados explicitamente a partir de repositórios (Arch, CachyOS **e Chaotic-AUR**) | `pacman -Qqen` |
| `aur.txt` | Pacotes fora de qualquer repositório configurado (AUR compilado localmente) | `pacman -Qqem` |
| `flatpak.txt` | Aplicativos Flatpak (sem runtimes) | `flatpak list --app --columns=application` |
| `flatpak-remotes.txt` | Remotes do Flatpak | `flatpak remotes --columns=name,url` |

> **Atenção:** vários pacotes do `pacman.txt` vêm do **Chaotic-AUR** (por exemplo `brave-origin-bin`, `claude-desktop`, `chatgpt-desktop-bin`, `pje-office`, `serproid`, `safesignidentityclient`, `softplan-websigner`, `lacuna-webpki`, `spotify`, `zoom`, `onlyoffice-bin`, `ventoy-bin`). Como o pacman os enxerga como pacotes de repositório, eles aparecem no `pacman.txt`, e não no `aur.txt`. Por isso o Chaotic-AUR precisa ser configurado **antes** da restauração (passo 2).

### Restauração

#### 1. Instalar o CachyOS e clonar este repositório

Faça a instalação normal do CachyOS (KDE Plasma) e, depois do primeiro boot:

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

O `--needed` pula o que já veio com a instalação (kernel, pacotes base do CachyOS etc.).

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

Só é necessário se o `aur.txt` não estiver vazio. O CachyOS já traz o `paru`; o `yay` também está no `pacman.txt`.

```sh
paru -S --needed - < aur.txt
```

#### 5. Instalar os Flatpaks

```sh
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
xargs -a flatpak.txt flatpak install -y flathub
```

Se o `flatpak-remotes.txt` listar remotes além do Flathub, adicione-os com `flatpak remote-add` antes de instalar.

### Observações

- **Hardware:** a lista inclui drivers da máquina atual (Intel: `intel-ucode`, `vulkan-intel`, `intel-media-sdk`; AMD: `vulkan-radeon`, `xf86-video-amdgpu`). Em outro hardware, retire do `pacman.txt` o que não se aplica.
- **Boot e sistema de arquivos:** `limine`, `limine-mkinitcpio-hook`, `limine-snapper-sync`, `snapper`, `cachyos-snapper-support` e `btrfs-assistant` pressupõem Limine + Btrfs. Se a nova instalação usar outro bootloader (ex.: systemd-boot) ou outro sistema de arquivos, retire essas linhas antes do passo 3.
- **Serviços:** a lista só reinstala pacotes. Serviços (`libvirtd`, `ufw`, `bluetooth`, `cups` etc.) e configurações precisam ser habilitados/restaurados à parte.

### Atualizar as listas

Na máquina atual, dentro do clone do repositório:

```sh
cd cachyos
pacman -Qqen > pacman.txt
pacman -Qqem > aur.txt
flatpak list --app --columns=application | sort -u > flatpak.txt
flatpak remotes --columns=name,url > flatpak-remotes.txt
cd ..
git add -A
git commit -m "CachyOS: atualiza listas de pacotes"
git push
```

---

## Licença

[CC0 1.0 Universal](LICENSE): domínio público. Use à vontade.
