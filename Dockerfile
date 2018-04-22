FROM debian:testing

# set noninteractive frontend for apt-get etc.
ENV DEBIAN_FRONTEND="noninteractive"


###########################
# args
###########################
ARG USER_NAME="dev"
ARG USER_UTILS_PATH="utils"
ARG RIPGREP_VERSION="0.8.1"

###########################
# system
###########################

# utilities
RUN apt-get update && apt-get install -y \
    composer \
    curl \
    gawk \
    git \
    locales \
    neovim \
    python3 \
    python3-pip \
    ranger \
    stow \
    tmux \
    universal-ctags \
    zsh

# ripgrep
RUN curl -LO https://github.com/BurntSushi/ripgrep/releases/download/${RIPGREP_VERSION}/ripgrep_${RIPGREP_VERSION}_amd64.deb \
    && dpkg -i ripgrep_${RIPGREP_VERSION}_amd64.deb \
    && rm ripgrep_${RIPGREP_VERSION}_amd64.deb

# locale
ENV LANG="en_NZ.UTF-8"
ENV LANGUAGE="en_NZ:en"
ENV LC_ALL="en_NZ.UTF-8"
RUN sed -i -e 's/# en_NZ.UTF-8 UTF-8/en_NZ.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen


###########################
# user setup
###########################

# create user (manually mkdir so we don't get files from /etc/skel)
RUN useradd -s /bin/zsh $USER_NAME --no-log-init \
    && mkdir /home/$USER_NAME \
    && chown -R $USER_NAME:$USER_NAME /home/$USER_NAME 


################################################## end of root user ##################################################

USER $USER_NAME


###########################
# user config
###########################

ENV HOME="/home/$USER_NAME"
ENV SHELL="/bin/zsh"
ENV TERM="xterm-256color"
ENV XDG_CONFIG_HOME="$HOME/.config"
ENV UTILS="$HOME/$USER_UTILS_PATH"

# create dirs (with current user, or WORKDIR will create as root)
RUN mkdir -p $XDG_CONFIG_HOME $UTILS

# config files
WORKDIR $HOME
RUN mkdir .dotfiles
COPY dotfiles .dotfiles
RUN cd .dotfiles \
    && stow --no-folding asdf git neovim ranger tmux zsh


###########################
# zsh
###########################

ENV ZPLUG_HOME="$UTILS/zplug"

WORKDIR $UTILS
# open interactive shell to install zplug plugins
RUN git clone --depth 1 https://github.com/zplug/zplug \
    && $SHELL -c "source $XDG_CONFIG_HOME/zsh/.zshrc" < /dev/null


###########################
# asdf
###########################

ENV ASDF_DIR="$UTILS/asdf"
ENV PATH="$PATH:$ASDF_DIR/bin"

WORKDIR $UTILS
RUN git clone --depth 1 https://github.com/asdf-vm/asdf.git
RUN asdf plugin-add nodejs
    RUN ${ASDF_DIR}/plugins/nodejs/bin/import-release-team-keyring
    RUN asdf install


###########################
# tmux
###########################

WORKDIR $HOME
RUN mkdir -p .tmux/plugins
RUN cd .tmux/plugins \
    && git clone --depth 1 https://github.com/tmux-plugins/tpm \
    && ./tpm/bin/install_plugins
# TODO: move resurrect dir to host / persistent volume


###########################
# vim
###########################

WORKDIR $XDG_CONFIG_HOME
RUN mkdir -p nvim/autoload \
    && cd nvim/autoload \
    && curl -LO https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim \
    && pip3 install --user neovim \
    && nvim +PlugInstall +UpdateRemotePlugins +qall -


###########################
# tidy up
###########################

WORKDIR $HOME

# set interactive frontend for child images
ENV DEBIAN_FRONTEND="teletype"

ENTRYPOINT tmux
