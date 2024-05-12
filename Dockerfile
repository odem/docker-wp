FROM debian

RUN apt update -y \
    && apt upgrade -y \
    && apt install -y wordpress vim curl apache2 mariadb-server

RUN mysql_secure_installation


