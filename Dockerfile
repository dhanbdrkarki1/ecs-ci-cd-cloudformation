FROM public.ecr.aws/docker/library/node:20.18.0-alpine3.19

WORKDIR /usr/src/app

COPY package*.json ./
RUN npm install

COPY . .

EXPOSE 3000
CMD ["npm", "start"]
