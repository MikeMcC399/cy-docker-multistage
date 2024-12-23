FROM cypress/factory AS first

COPY . /opt/app
WORKDIR /opt/app
RUN npm install cypress --save-dev
RUN npx cypress install

FROM first AS second

RUN apt-get update
RUN apt-get install chromium -y
