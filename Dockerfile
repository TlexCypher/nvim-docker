# Build stage
FROM --platform=linux/amd64 archlinux:latest as builder

WORKDIR /home

# NOTE: Install necessary packages
# -S (--sync): Synchronize packages
# -y (--refresh): Refresh package databases
# -u (--sysupgrade): Upgrade all installed packages
# base-devl: Base development tools for Arch
RUN pacman -Syu --noconfirm git base-devel sudo

RUN useradd -m -G wheel builduser
RUN echo "builduser ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
USER builduser
WORKDIR /home/builduser

# Install yay for install AUR packages
RUN git clone https://aur.archlinux.org/yay.git

WORKDIR /home/builduser/yay

RUN makepkg -si --noconfirm

# Main stage
FROM --platform=linux/amd64 archlinux:latest

COPY --from=builder /usr/bin/yay /usr/bin/yay

RUN pacman -Syu --noconfirm curl git tmux neovim cmake fzf which unzip base-devel go npm nodejs python sudo

RUN useradd -m -G wheel appuser

RUN echo "appuser ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

USER appuser
RUN git clone --branch nvim-docker https://github.com/TlexCypher/init.lua.git ~/.config/nvim
RUN yay -S python314 --noconfirm

WORKDIR /home/appuser

CMD ["bash"]
