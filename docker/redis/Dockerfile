FROM redis:4.0.9

RUN apt-get update && \
    apt-get install -y \
      redis-tools \
      && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*