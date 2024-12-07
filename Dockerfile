FROM cypress/factory AS first

COPY . /opt/app
WORKDIR /opt/app
RUN npm install cypress --save-dev
RUN npx cypress install

FROM first AS second

RUN apt-get update
RUN apt-get install chromium=130.0.6723.91-1~deb12u1 chromium-common=130.0.6723.91-1~deb12u1 -y
