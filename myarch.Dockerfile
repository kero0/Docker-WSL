FROM archlinux:base-devel

# I'm fine with an unsecure password because it's already locked behind my windows login
ARG password=k

ENV user kirolsb
ENV name "Kirols Bakheat"
ENV packages base-devel \
    git        \
    emacs      \
    fish       \
    vim        

ENV HOME /home/${user}

WORKDIR /tmp

COPY wsl.conf /etc/wsl.conf

RUN pacman -Syu --noconfirm fish                            && \
    useradd -ms /bin/fish -c "${name}" -G wheel ${user}     && \
    chown -R ${user} ${HOME}                                && \
    echo ${user}:${password} | chpasswd                     && \
    echo "${user} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

USER ${user}
WORKDIR ${HOME}

RUN sudo pacman -Syu --needed --noconfirm ${packages}   && \
    git clone https://aur.archlinux.org/paru-bin.git    && \
    cd paru-bin && makepkg -csi --noconfirm
