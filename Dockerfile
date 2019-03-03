FROM node:slim

MAINTAINER James Spurin <james@spurin.com>

# Set the server port as an environmental
ENV HEXO_SERVER_PORT=4000

# Install requirements
RUN \
 apt-get update && \
 apt-get install git -y && \
 npm install -g hexo-cli

# Set workdir
WORKDIR /app

# Expose Server Port
EXPOSE ${HEXO_SERVER_PORT}

# Build a base blog if it doesnt exist, then start server
CMD \
  if [ "$(ls -A /app)" ]; then \
    echo "***** App directory exists and has content, continuing"; \
  else \
    echo "***** App directory is empty, initialising with hexo and hexo-admin *****" && \
    hexo init && \
    npm install && \
    npm install --save hexo-admin; \
  fi; \
  echo "***** Starting Server on port ${HEXO_SERVER_PORT}" && \
  hexo server -d -p ${HEXO_SERVER_PORT}
