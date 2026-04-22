FROM debian:bookworm-slim

ARG USER=developer
ARG DEBIAN_FRONTEND=noninteractive

RUN apt update \
    && apt install -y --no-install-recommends \
    sudo git zsh curl wget ca-certificates \
    openssh-client python3 python3-pip jq unzip rsync make less \
    && apt clean \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /usr/bin/zsh ${USER} \
    && echo "${USER} ALL=(ALL) NOPASSWD: ALL" >/etc/sudoers.d/${USER} \
    && chmod 0440 /etc/sudoers.d/${USER} # hadolint ignore=SC2086

USER ${USER}
ARG HOME=/home/${USER}
ARG ZSH=${HOME}/.oh-my-zsh
ARG ZSH_CUSTOM=${ZSH}/custom
ENV PATH="${HOME}/.local/bin:${PATH}"
WORKDIR ${HOME}

RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended \
    && mkdir -p ${ZSH_CUSTOM} \
    && git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM}/plugins/zsh-autosuggestions \
    && git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting \
    && sed -i.bak 's/plugins=(\(.*\))/plugins=(\1 zsh-autosuggestions zsh-syntax-highlighting)/' ~/.zshrc

ARG SPACESHIP_REMOTE=https://github.com/spaceship-prompt/spaceship-prompt.git
RUN git clone --depth=1 ${SPACESHIP_REMOTE} ${ZSH_CUSTOM}/themes/spaceship-prompt \
    && ln -s ${ZSH_CUSTOM}/themes/spaceship-prompt/spaceship.zsh-theme ${ZSH_CUSTOM}/themes/spaceship.zsh-theme \
    && sed -i 's|ZSH_THEME="robbyrussell"|ZSH_THEME="spaceship"|g' .zshrc

RUN curl -LsSf https://astral.sh/uv/install.sh | sh \
    && echo 'eval "$(uv generate-shell-completion zsh)"' >> ~/.zshrc \
    && echo 'eval "$(uvx --generate-shell-completion zsh)"' >> ~/.zshrc
