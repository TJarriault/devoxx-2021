FROM gcr.io/distroless/nodejs:14
WORKDIR /usr/src/app
COPY package*.json world.js ./
ENV PORT 3000
EXPOSE $PORT
CMD ["world.js"]
