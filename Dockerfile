# Attempt to run cron in a dockerfile based on:
# https://stackoverflow.com/questions/37458287/how-to-run-a-cron-job-inside-a-docker-container
FROM ubuntu:16.04

# Run apt-get update and then install cron and the nano editor
RUN apt-get update && apt-get install cron nano wget curl apt-transport-https -y \
        && curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
	&& curl https://packages.microsoft.com/config/ubuntu/16.04/prod.list | tee /etc/apt/sources.list.d/msprod.list \
	&& apt-get update \
	&& ACCEPT_EULA=Y apt-get install mssql-tools unixodbc-dev -y
# Make directories to hold the Anaconda installer and the scripts from GIT
RUN mkdir /tmp/anaconda && mkdir /srv/scripts

# Change to the staging folder for the anaconda install and download the latest miniconda to it
WORKDIR /tmp/anaconda
RUN wget -O miniconda.sh https://repo.anaconda.com/miniconda/Miniconda3-4.7.12.1-Linux-x86_64.sh \
	&& chmod +x /tmp/anaconda/miniconda.sh \
	&& /tmp/anaconda/miniconda.sh -b -p \
	&& /root/miniconda3/condabin/conda init bash \
	&& /root/miniconda3/condabin/conda install -y -c anaconda sqlalchemy pyodbc

# Change to the location where the scripts will live.  Remove the Anaconda installer, and then copy in the scripts.
WORKDIR /srv/scripts
RUN rm -rf /tmp/anaconda
COPY ./scripts/* /srv/scripts/

# Copy the cronfile to the cron.d directory
COPY cronfile /etc/cron.d/cronfile

# Give execution rights on the cronfile
RUN chmod 0644 /etc/cron.d/cronfile

# Apply cron job
RUN crontab /etc/cron.d/cronfile

# Create the log file to be able to run tail successfully 
RUN touch /var/log/cron.log

# Run the cron command on container startup
CMD ["cron", "-f"]

# comment
