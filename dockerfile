# Attempt to run cron in a dockerfile based on:
# https://stackoverflow.com/questions/37458287/how-to-run-a-cron-job-inside-a-docker-container
FROM ubuntu:16.04

# Run apt-get update and then install cron and the nano editor
RUN apt-get update && apt-get install cron -y

# Make directories to hold the Anaconda installer and the scripts from GIT
RUN mkdir /tmp/anaconda && mkdir /srv/scripts

# Change to the staging folder for the anaconda install and download the latest miniconda to it
WORKDIR /tmp/anaconda
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh miniconda.sh \
	&& chmod +x /tmp/anaconda/miniconda.sh \
	&& /tmp/anaconda/miniconda.sh -b -p \
	&& /root/miniconda3/condabin/conda init bash

# Change to the location where the scripts will live and copy in the scripts
WORKDIR /srv/scripts
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
