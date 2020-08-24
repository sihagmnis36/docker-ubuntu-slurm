FROM ubuntu:16.04

RUN apt-get update -y
RUN apt-get install -y build-essential vim mariadb-server mariadb-client supervisor git wget curl

RUN \
    git clone https://github.com/SchedMD/slurm.git \
    && cd slurm \
    && git checkout tags/slurm-20-02-4-1 \
    && ./configure --enable-debug --enable-front-end --prefix=/usr \
       --sysconfdir=/etc/slurm --with-mysql_config=/usr/bin \
       --libdir=/usr/lib64 \
    && make install \
    && install -D -m644 etc/cgroup.conf.example /etc/slurm/cgroup.conf.example \
    && install -D -m644 etc/slurm.conf.example /etc/slurm/slurm.conf.example \
    && install -D -m644 etc/slurm.epilog.clean /etc/slurm/slurm.epilog.clean \
    && install -D -m644 etc/slurmdbd.conf.example /etc/slurm/slurmdbd.conf.example \
    && install -D -m644 contribs/slurm_completion_help/slurm_completion.sh /etc/profile.d/slurm_completion.sh \
    && cd .. \
    && rm -rf slurm \
    && groupadd -r slurm  \
    && useradd -r -g slurm slurm

RUN mkdir -p /etc/sysconfig/slurm \
        /var/spool/slurmd \
        /var/run/slurmd \        
        /var/lib/slurmd \
        /var/log/slurm \
	/var/run/supervisor \
	/var/run/munge

RUN chown slurm:root /var/spool/slurmd \
        /var/run/slurmd \
        /var/lib/slurmd \
        /var/log/slurm  \
    && chown munge:root /var/run/munge 

COPY slurm.conf /etc/slurm-llnl/slurm.conf
COPY slurmdbd.conf /etc/slurm-llnl/slurmdbd.conf
COPY supervisord.conf /etc/

VOLUME ["/var/lib/mysql", "/var/lib/slurmd", "/var/spool/slurmd", "/var/log/slurm"]

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["/bin/bash"]
