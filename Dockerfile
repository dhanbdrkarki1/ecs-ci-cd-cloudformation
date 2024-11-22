FROM public.ecr.aws/docker/library/node:20.18.0-alpine3.19

WORKDIR /usr/src/app

COPY package*.json ./
RUN npm install

COPY . .
# HEALTHCHECK --interval=5m --timeout=3s \
#   CMD curl -f http://localhost:3000/ || exit 1
  
EXPOSE 3000
CMD ["npm", "start"]
