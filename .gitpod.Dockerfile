FROM gitpod/workspace-full

USER root

RUN ["apt-get", "update"]

RUN ["apt-get", "install", "-y", "zsh"]

USER gitpod

COPY . .

# Install Oh-My-Zsh glide and setup zsh 
RUN sudo chmod +x ./.gitpod/oh-my-zsh.sh && ./.gitpod/oh-my-zsh.sh && brew install glide

# start zsh
CMD ["zsh"]